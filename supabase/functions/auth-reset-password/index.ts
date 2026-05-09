import bcrypt from "npm:bcryptjs@2.4.3";
import {
  CODE_RE,
  MAX_CODE_ATTEMPTS,
  MIN_PASSWORD_LENGTH,
  PHONE_RE,
} from "../_shared/auth.ts";
import { sql } from "../_shared/db.ts";
import { json, readJson, requireMethod } from "../_shared/http.ts";

Deno.serve(async (req) => {
  const methodError = requireMethod(req, "POST");
  if (methodError) return methodError;

  const body = await readJson(req);
  if (!body) {
    return json(400, { error: "INVALID_JSON" });
  }

  const phone = String(body.phone || "").trim();
  const code = String(body.code || "").trim();
  const newPassword = String(body.new_password || "");

  if (!PHONE_RE.test(phone)) {
    return json(400, { error: "INVALID_PHONE" });
  }

  if (!CODE_RE.test(code)) {
    return json(400, { error: "INVALID_CODE" });
  }

  if (newPassword.length < MIN_PASSWORD_LENGTH) {
    return json(400, { error: "WEAK_PASSWORD" });
  }

  try {
    return await sql.begin(async (tx) => {
      const codeRows = await tx`
        SELECT id, code, expires_at, attempts
        FROM sms_codes
        WHERE phone = ${phone} AND purpose = 'reset'
        ORDER BY created_at DESC
        LIMIT 1
        FOR UPDATE
      `;

      if (codeRows.length === 0) {
        return json(400, { error: "INVALID_CODE" });
      }

      const smsCode = codeRows[0];

      if (new Date(smsCode.expires_at).getTime() < Date.now()) {
        await tx`DELETE FROM sms_codes WHERE id = ${smsCode.id}`;
        return json(400, { error: "CODE_EXPIRED" });
      }

      if (smsCode.attempts >= MAX_CODE_ATTEMPTS) {
        return json(429, { error: "TOO_MANY_ATTEMPTS" });
      }

      if (smsCode.code !== code) {
        await tx`
          UPDATE sms_codes
          SET attempts = attempts + 1
          WHERE id = ${smsCode.id}
        `;

        return json(400, { error: "INVALID_CODE" });
      }

      const users = await tx`
        SELECT id
        FROM users
        WHERE phone = ${phone}
        LIMIT 1
        FOR UPDATE
      `;

      if (users.length === 0) {
        return json(400, { error: "INVALID_CODE" });
      }

      const passwordHash = await bcrypt.hash(newPassword, 10);
      const userId = users[0].id;

      await tx`
        UPDATE users
        SET password_hash = ${passwordHash}
        WHERE id = ${userId}
      `;

      await tx`DELETE FROM sessions WHERE user_id = ${userId}`;
      await tx`DELETE FROM sms_codes WHERE phone = ${phone} AND purpose = 'reset'`;

      return json(200, { ok: true });
    });
  } catch (error) {
    console.error("auth-reset-password failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  }
});
