const { Client } = require("pg");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const PHONE_RE = /^\+7\d{10}$/;
const SESSION_TTL_MS = 30 * 24 * 60 * 60 * 1000;

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
  const password = String(body.password || "");

  if (!PHONE_RE.test(phone)) {
    return json(400, { error: "INVALID_PHONE" });
  }

  if (!password) {
    return json(401, { error: "INVALID_CREDENTIALS" });
  }

  try {
    client = createClient();
    await client.connect();
    await client.query("BEGIN");
    transactionStarted = true;

    const userResult = await client.query(
      `
      SELECT id, phone, password_hash, name, bonuses, avatar, created_at
      FROM users
      WHERE phone = $1
      LIMIT 1
      `,
      [phone]
    );

    if (userResult.rowCount === 0) {
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(401, { error: "INVALID_CREDENTIALS" });
    }

    const user = userResult.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      await client.query("ROLLBACK");
      transactionStarted = false;
      return json(401, { error: "INVALID_CREDENTIALS" });
    }

    const accessToken = crypto.randomBytes(32).toString("hex");
    const sessionExpiresAt = new Date(Date.now() + SESSION_TTL_MS).toISOString();

    await client.query(
      `
      INSERT INTO sessions (token, user_id, expires_at)
      VALUES ($1, $2, $3)
      `,
      [accessToken, user.id, sessionExpiresAt]
    );

    await client.query("COMMIT");
    transactionStarted = false;

    return json(200, {
      access_token: accessToken,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        bonuses: user.bonuses,
        avatar: user.avatar,
        created_at: user.created_at
      }
    });
  } catch (error) {
    console.error("auth-login failed", error);

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
