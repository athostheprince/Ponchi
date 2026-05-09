const { Client } = require("pg");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const PHONE_RE = /^\+7\d{10}$/;
const CODE_RE = /^\d{4}$/;
const MIN_PASSWORD_LENGTH = 6;
const SESSION_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const PG_UNIQUE_VIOLATION = "23505";
const MAX_CODE_ATTEMPTS = 5;

function json(statusCode, payload) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  };
}

function createClient() {
  const ca = fs.readFileSync(path.join(__dirname, "root.crt"), "utf8");

  return new Client({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    ssl: { ca, rejectUnauthorized: true }
  });
}

module.exports.handler = async function (event) {
  let body;
  let client;
  let transactionStarted = false;

  try {
    body = JSON.parse(event.body || "{}");
  } catch {
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
    client = createClient();
    await client.connect();
    await client.query("BEGIN");
    transactionStarted = true;

    const existingUser = await client.query(
      "SELECT id FROM users WHERE phone = $1 LIMIT 1",
      [phone]
    );

    if (existingUser.rowCount > 0) {
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(409, { error: "USER_ALREADY_EXISTS" });
    }

    const codeResult = await client.query(
      `
      SELECT id, code, expires_at, attempts
      FROM sms_codes
      WHERE phone = $1 AND purpose = 'signup'
      ORDER BY created_at DESC
      LIMIT 1
      FOR UPDATE
      `,
      [phone]
    );

    if (codeResult.rowCount === 0) {
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(400, { error: "INVALID_CODE" });
    }

    const smsCode = codeResult.rows[0];

    if (new Date(smsCode.expires_at).getTime() < Date.now()) {
      await client.query("DELETE FROM sms_codes WHERE id = $1", [smsCode.id]);
      await client.query("COMMIT");
      transactionStarted = false;
      return json(400, { error: "CODE_EXPIRED" });
    }

    if (smsCode.attempts >= MAX_CODE_ATTEMPTS) {
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(429, { error: "TOO_MANY_ATTEMPTS" });
    }

    if (smsCode.code !== code) {
      await client.query(
        `
        UPDATE sms_codes
        SET attempts = attempts + 1
        WHERE id = $1
        `,
        [smsCode.id]
      );

      await client.query("COMMIT");
      transactionStarted = false;
      return json(400, { error: "INVALID_CODE" });
    }

    const userId = crypto.randomUUID();
    const passwordHash = await bcrypt.hash(password, 10);
    const accessToken = crypto.randomBytes(32).toString("hex");
    const sessionExpiresAt = new Date(Date.now() + SESSION_TTL_MS).toISOString();

    const userInsert = await client.query(
      `
      INSERT INTO users (id, phone, password_hash, name)
      VALUES ($1, $2, $3, $4)
      RETURNING id, phone, name, bonuses, avatar, created_at
      `,
      [userId, phone, passwordHash, name]
    );

    await client.query(
      `
      INSERT INTO sessions (token, user_id, expires_at)
      VALUES ($1, $2, $3)
      `,
      [accessToken, userId, sessionExpiresAt]
    );

    await client.query("DELETE FROM sms_codes WHERE id = $1", [smsCode.id]);

    await client.query("COMMIT");
    transactionStarted = false;

    return json(200, {
      access_token: accessToken,
      user: userInsert.rows[0]
    });
  } catch (error) {
    console.error("auth-verify-code failed", error);

    if (client && transactionStarted) {
      try {
        await client.query("ROLLBACK");
      } catch {}
    }

    if (error && error.code === PG_UNIQUE_VIOLATION) {
      return json(409, { error: "USER_ALREADY_EXISTS" });
    }

    return json(500, { error: "INTERNAL_ERROR" });
  } finally {
    if (client) {
      await client.end().catch(() => {});
    }
  }
};
