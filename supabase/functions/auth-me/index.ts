import { logAuthEvent } from "../_shared/auth-events.ts";
import { sql } from "../_shared/db.ts";
import { getBearerToken, json, requireMethod } from "../_shared/http.ts";

Deno.serve(async (req) => {
  const methodError = requireMethod(req, "GET");
  if (methodError) return methodError;

  const token = getBearerToken(req);

  if (!token) {
    return json(401, { error: "INVALID_TOKEN" });
  }

  try {
    const result = await sql`
      SELECT
        u.id,
        u.phone,
        u.name,
        u.bonuses,
        u.avatar,
        u.created_at
      FROM sessions s
      JOIN users u ON u.id = s.user_id
      WHERE s.token = ${token}
        AND s.expires_at > NOW()
      LIMIT 1
    `;

    if (result.length === 0) {
      await logAuthEvent({
        eventType: "session_restore_failed",
        success: false,
        errorCode: "INVALID_TOKEN",
      });

      return json(401, { error: "INVALID_TOKEN" });
    }

    await logAuthEvent({
      eventType: "session_restore_success",
      phone: result[0].phone,
      userId: result[0].id,
    });

    return json(200, result[0]);
  } catch (error) {
    console.error("auth-me failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  }
});
