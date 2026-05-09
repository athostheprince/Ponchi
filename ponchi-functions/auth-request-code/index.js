const { Client } = require("pg");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const PHONE_RE = /^\+7\d{10}$/;
const ALLOWED_PURPOSES = new Set(["signup", "reset"]);
const CODE_TTL_MS = 5 * 60 * 1000;
const RESEND_COOLDOWN_SECONDS = 60;

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

async function sendSmsCode(phone, code) {
  if (process.env.SMS_MODE === "debug") {
    console.log(`Debug SMS code for ${phone}: ${code}`);
    return;
  }

  if (!process.env.SMS_API_KEY) {
    throw new Error("SMS_PROVIDER_NOT_CONFIGURED");
  }

  // Real SMS provider integration goes here.
  throw new Error("SMS_PROVIDER_NOT_IMPLEMENTED");
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

  let client;
  let insertedCodeId = null;

  try {
    client = createClient();
    await client.connect();

    const recent = await client.query(
      `
      SELECT created_at
      FROM sms_codes
      WHERE phone = $1 AND purpose = $2
      ORDER BY created_at DESC
      LIMIT 1
      `,
      [phone, purpose]
    );

    if (recent.rowCount > 0) {
      const createdAt = new Date(recent.rows[0].created_at).getTime();
      const secondsPassed = Math.floor((Date.now() - createdAt) / 1000);

      if (secondsPassed < RESEND_COOLDOWN_SECONDS) {
        return json(429, {
          error: "TOO_MANY_REQUESTS",
          retry_after: RESEND_COOLDOWN_SECONDS - secondsPassed
        });
      }
    }

    const code = String(Math.floor(1000 + Math.random() * 9000));
    const id = crypto.randomUUID();
    const expiresAt = new Date(Date.now() + CODE_TTL_MS).toISOString();
    insertedCodeId = id;

    await client.query(
      `
      DELETE FROM sms_codes
      WHERE phone = $1 AND purpose = $2
      `,
      [phone, purpose]
    );

    await client.query(
      `
      INSERT INTO sms_codes (id, phone, code, expires_at, purpose, attempts)
      VALUES ($1, $2, $3, $4, $5, 0)
      `,
      [id, phone, code, expiresAt, purpose]
    );

    try {
      await sendSmsCode(phone, code);
    } catch (error) {
      console.error("SMS send failed", error);

      await client.query(
        "DELETE FROM sms_codes WHERE id = $1",
        [insertedCodeId]
      );

      return json(500, { error: "SMS_SEND_FAILED" });
    }

    return json(200, { ok: true, retry_after: RESEND_COOLDOWN_SECONDS });
  } catch (error) {
    console.error("auth-request-code failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  } finally {
    if (client) {
      await client.end().catch(() => {});
    }
  }
};
