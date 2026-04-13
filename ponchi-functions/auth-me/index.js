const { Client } = require("pg");
const fs = require("fs");
const path = require("path");

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

function getBearerToken(headers = {}) {
  const authorization = headers.Authorization || headers.authorization;

  if (!authorization) {
    return null;
  }

  const [scheme, token] = String(authorization).trim().split(/\s+/, 2);

  if (scheme !== "Bearer" || !token) {
    return null;
  }

  return token;
}

module.exports.handler = async function (event) {
  const token = getBearerToken(event.headers || {});

  if (!token) {
    return json(401, { error: "INVALID_TOKEN" });
  }

  let client;

  try {
    client = createClient();
    await client.connect();

    const result = await client.query(
      `
      SELECT
        u.id,
        u.phone,
        u.name,
        u.bonuses,
        u.avatar,
        u.created_at
      FROM sessions s
      JOIN users u ON u.id = s.user_id
      WHERE s.token = $1
        AND s.expires_at > NOW()
      LIMIT 1
      `,
      [token]
    );

    if (result.rowCount === 0) {
      return json(401, { error: "INVALID_TOKEN" });
    }

    return json(200, result.rows[0]);
  } catch (error) {
    console.error("auth-me failed", error);
    return json(500, { error: "INTERNAL_ERROR" });
  } finally {
    if (client) {
      await client.end().catch(() => {});
    }
  }
};
