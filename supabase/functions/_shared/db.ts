import postgres from "npm:postgres@3.4.5";

const databaseUrl = Deno.env.get("SUPABASE_DB_URL");

if (!databaseUrl) {
  throw new Error("SUPABASE_DB_URL is missing");
}

export const sql = postgres(databaseUrl, {
  max: 3,
  prepare: false,
});
