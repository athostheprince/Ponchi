import bcrypt from "npm:bcryptjs@2.4.3";
import {
  CODE_RE,
  createAccessToken,
  MAX_CODE_ATTEMPTS,
  MIN_PASSWORD_LENGTH,
  PHONE_RE,
  sessionExpiresAt,
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
  const name = String(body.name || "").trim();
  const password = String(body.password || "");

  if (!PHONE_RE.test(phone)) {
    return json(400, { error: "INVALID_PHONE" });
  }

  if (!CODE_RE.test(code)) {
    return json(400, { error: "INVALID_CODE" });
  }

  if (!name) {
    return json(400, { error: "INVALID_NAME" });
  }

  if (password.length < MIN_PASSWORD_LENGTH) {
    return json(400, { error: "WEAK_PASSWORD" });
  }

  try {
    return await sql.begin(async (tx) => {
      const existingUsers = await tx`
        SELECT id
        FROM users
        WHERE phone = ${phone}
        LIMIT 1
      `;

      if (existingUsers.length > 0) {
        return json(409, { error: "USER_ALREADY_EXISTS" });
      }

      const codeRows = await tx`
        SELECT id, code, expires_at, attempts
        FROM sms_codes
        WHERE phone = ${phone} AND purpose = 'signup'
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

      const userId = crypto.randomUUID();
      const passwordHash = await bcrypt.hash(password, 10);
      const accessToken = createAccessToken();

      const insertedUsers = await tx`
        INSERT INTO users (id, phone, password_hash, name)
        VALUES (${userId}, ${phone}, ${passwordHash}, ${name})
        RETURNING id, phone, name, bonuses, avatar, created_at
      `;

      await tx`
        INSERT INTO sessions (token, user_id, expires_at)
        VALUES (${accessToken}, ${userId}, ${sessionExpiresAt()})
      `;

      await tx`DELETE FROM sms_codes WHERE id = ${smsCode.id}`;

      return json(200, {
        access_token: accessToken,
        user: insertedUsers[0],
      });
    });
  } catch (error) {
    console.error("auth-verify-code failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  }
});
