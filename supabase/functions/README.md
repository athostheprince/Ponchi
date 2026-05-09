# Supabase Edge Functions

This directory is reserved for the future migration from Yandex Cloud Functions to Supabase Edge Functions.

The current production functions remain in `ponchi-functions/` because they use the Yandex/Node.js handler shape:

- `module.exports.handler`
- CommonJS `require`
- Node packages such as `pg` and `bcryptjs`
- `root.crt` for Yandex Managed PostgreSQL TLS

Supabase Edge Functions run on the Deno-based Edge Runtime. Move each function here only after porting it to `Deno.serve(...)`, replacing Node-specific imports, and configuring any required secrets in Supabase.

Suggested migration order:

1. `auth-me`
2. `auth-login`
3. `auth-request-code`
4. `auth-verify-code`
5. `auth-reset-password`

After a function is ported, add its per-function settings to `supabase/config.toml`.
