import { PHONE_RE } from "../_shared/auth.ts";
import { logAuthEvent } from "../_shared/auth-events.ts";
import { sql } from "../_shared/db.ts";
import { json, readJson, requireMethod } from "../_shared/http.ts";
import { sendSmsCode } from "../_shared/sms.ts";

const ALLOWED_PURPOSES = new Set(["signup", "reset"]);
const CODE_TTL_MS = 5 * 60 * 1000;
const RESEND_COOLDOWN_SECONDS = 60;

Deno.serve(async (req) => {
  const methodError = requireMethod(req, "POST");
  if (methodError) return methodError;

  const body = await readJson(req);
  if (!body) {
    return json(400, { error: "INVALID_JSON" });
  }

  const phone = String(body.phone || "").trim();
  const purpose = String(body.purpose || "").trim();

  if (!PHONE_RE.test(phone)) {
    return json(400, { error: "INVALID_PHONE" });
  }

  if (!ALLOWED_PURPOSES.has(purpose)) {
    return json(400, { error: "INVALID_PURPOSE" });
  }

  let insertedCodeId: string | null = null;

  try {
    const users = await sql`
      SELECT id
      FROM users
      WHERE phone = ${phone}
      LIMIT 1
    `;

    if (purpose === "reset" && users.length === 0) {
      await logAuthEvent({
        eventType: "sms_code_request_rejected",
        phone,
        success: false,
        errorCode: "USER_NOT_FOUND",
        metadata: { purpose },
      });

      return json(404, { error: "USER_NOT_FOUND" });
    }

    if (purpose === "signup" && users.length > 0) {
      await logAuthEvent({
        eventType: "sms_code_request_rejected",
        phone,
        userId: users[0].id,
        success: false,
        errorCode: "USER_ALREADY_EXISTS",
        metadata: { purpose },
      });

      return json(409, { error: "USER_ALREADY_EXISTS" });
    }

    const recent = await sql`
      SELECT created_at
      FROM sms_codes
      WHERE phone = ${phone} AND purpose = ${purpose}
      ORDER BY created_at DESC
      LIMIT 1
    `;

    if (recent.length > 0) {
      const createdAt = new Date(recent[0].created_at).getTime();
      const secondsPassed = Math.floor((Date.now() - createdAt) / 1000);

      if (secondsPassed < RESEND_COOLDOWN_SECONDS) {
        await logAuthEvent({
          eventType: "sms_code_rate_limited",
          phone,
          success: false,
          errorCode: "TOO_MANY_REQUESTS",
          metadata: {
            purpose,
            retry_after: RESEND_COOLDOWN_SECONDS - secondsPassed,
          },
        });

        return json(429, {
          error: "TOO_MANY_REQUESTS",
          retry_after: RESEND_COOLDOWN_SECONDS - secondsPassed,
        });
      }
    }

    const code = String(Math.floor(1000 + Math.random() * 9000));
    const id = crypto.randomUUID();
    const expiresAt = new Date(Date.now() + CODE_TTL_MS).toISOString();
    insertedCodeId = id;

    await sql`
      DELETE FROM sms_codes
      WHERE phone = ${phone} AND purpose = ${purpose}
    `;

    await sql`
      INSERT INTO sms_codes (id, phone, code, expires_at, purpose, attempts)
      VALUES (${id}, ${phone}, ${code}, ${expiresAt}, ${purpose}, 0)
    `;

    try {
      await sendSmsCode(phone, code);
    } catch (error) {
      console.error("SMS send failed", error);

      if (insertedCodeId) {
        await sql`DELETE FROM sms_codes WHERE id = ${insertedCodeId}`;
      }

      await logAuthEvent({
        eventType: "sms_code_send_failed",
        phone,
        success: false,
        errorCode: "SMS_SEND_FAILED",
        metadata: { purpose },
      });

      return json(500, { error: "SMS_SEND_FAILED" });
    }

    await logAuthEvent({
      eventType: "sms_code_requested",
      phone,
      metadata: {
        purpose,
        expires_at: expiresAt,
        retry_after: RESEND_COOLDOWN_SECONDS,
        sms_mode: Deno.env.get("SMS_MODE") || "webhook",
      },
    });

    return json(200, { ok: true, retry_after: RESEND_COOLDOWN_SECONDS });
  } catch (error) {
    console.error("auth-request-code failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  }
});
