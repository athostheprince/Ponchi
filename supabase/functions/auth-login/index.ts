import bcrypt from "npm:bcryptjs@2.4.3";
import { createAccessToken, PHONE_RE, sessionExpiresAt } from "../_shared/auth.ts";
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
  const password = String(body.password || "");

  if (!PHONE_RE.test(phone)) {
    return json(400, { error: "INVALID_PHONE" });
  }

  if (!password) {
    return json(401, { error: "INVALID_CREDENTIALS" });
  }

  try {
    return await sql.begin(async (tx) => {
      const users = await tx`
        SELECT id, phone, password_hash, name, bonuses, avatar, created_at
        FROM users
        WHERE phone = ${phone}
        LIMIT 1
      `;

      if (users.length === 0) {
        return json(401, { error: "INVALID_CREDENTIALS" });
      }

      const user = users[0];
      const isPasswordValid = await bcrypt.compare(password, user.password_hash);

      if (!isPasswordValid) {
        return json(401, { error: "INVALID_CREDENTIALS" });
      }

      const accessToken = createAccessToken();

      await tx`
        INSERT INTO sessions (token, user_id, expires_at)
        VALUES (${accessToken}, ${user.id}, ${sessionExpiresAt()})
      `;

      return json(200, {
        access_token: accessToken,
        user: {
          id: user.id,
          phone: user.phone,
          name: user.name,
          bonuses: user.bonuses,
          avatar: user.avatar,
          created_at: user.created_at,
        },
      });
    });
  } catch (error) {
    console.error("auth-login failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  }
});
