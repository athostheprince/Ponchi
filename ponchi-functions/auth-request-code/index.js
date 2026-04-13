const { Client } = require("pg");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const PHONE_RE = /^\+7\d{10}$/;
const ALLOWED_PURPOSES = new Set(["signup", "reset"]);

function json(statusCode, payload) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json"
    },
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

  try {
    body = JSON.parse(event.body || "{}");
  } catch {
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

  const code = String(Math.floor(1000 + Math.random() * 9000));
  const id = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();

  let client;

  try {
    client = createClient();
    await client.connect();

    await client.query(
      `
      INSERT INTO sms_codes (id, phone, code, expires_at, purpose)
      VALUES ($1, $2, $3, $4, $5)
      `,
      [id, phone, code, expiresAt, purpose]
    );

    return json(200, { ok: true, retry_after: 60 });
  } catch (error) {
    console.error("auth-request-code failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  } finally {
    if (client) {
      await client.end().catch(() => {});
    }
  }
};
