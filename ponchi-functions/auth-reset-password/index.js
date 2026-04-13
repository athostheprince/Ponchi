const { Client } = require("pg");
const bcrypt = require("bcryptjs");
const fs = require("fs");
const path = require("path");

const PHONE_RE = /^\+7\d{10}$/;
const CODE_RE = /^\d{4}$/;
const MIN_PASSWORD_LENGTH = 6;

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
    client = createClient();
    await client.connect();
    await client.query("BEGIN");
    transactionStarted = true;

    const codeResult = await client.query(
      `
      SELECT id, code, expires_at
      FROM sms_codes
      WHERE phone = $1 AND purpose = 'reset'
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
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(400, { error: "CODE_EXPIRED" });
    }

    if (smsCode.code !== code) {
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(400, { error: "INVALID_CODE" });
    }

    const userResult = await client.query(
      `
      SELECT id
      FROM users
      WHERE phone = $1
      LIMIT 1
      FOR UPDATE
      `,
      [phone]
    );

    if (userResult.rowCount === 0) {
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(400, { error: "INVALID_CODE" });
    }

    const userId = userResult.rows[0].id;
    const passwordHash = await bcrypt.hash(newPassword, 10);

    await client.query(
      `
      UPDATE users
      SET password_hash = $2
      WHERE id = $1
      `,
      [userId, passwordHash]
    );

    await client.query(
      "DELETE FROM sessions WHERE user_id = $1",
      [userId]
    );

    await client.query(
      "DELETE FROM sms_codes WHERE phone = $1 AND purpose = 'reset'",
      [phone]
    );

    await client.query("COMMIT");
    transactionStarted = false;

    return json(200, { ok: true });
  } catch (error) {
    console.error("auth-reset-password failed", error);

    if (client && transactionStarted) {
      try {
        await client.query("ROLLBACK");
      } catch {}
    }

    return json(500, { error: "INTERNAL_ERROR" });
  } finally {
    if (client) {
      await client.end().catch(() => {});
    }
  }
};
