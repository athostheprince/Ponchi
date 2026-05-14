# Supabase Edge Functions

Supabase replacement for the Yandex Cloud auth functions in `ponchi-functions/`.

## Functions

- `auth-request-code`
- `auth-verify-code`
- `auth-login`
- `auth-reset-password`
- `auth-me`

The functions keep the same response contract as the iOS client expects:

- `access_token`
- `retry_after`
- `created_at`
- `{ "error": "ERROR_CODE" }`

Auth functions also write non-blocking debug/audit events to `auth_events`. The helper catches logging failures so the user flow is not broken only because observability failed.

## Secrets

Supabase provides `SUPABASE_DB_URL` to Edge Functions automatically. Do not commit database URLs, service-role keys, or SMS credentials.

For local SMS testing:

```bash
supabase secrets set SMS_MODE=debug
```

For production SMS delivery, configure a webhook that accepts:

```json
{ "phone": "+79990000000", "code": "1234" }
```

Then set:

```bash
supabase secrets set SMS_WEBHOOK_URL="https://example.com/send-sms"
supabase secrets set SMS_WEBHOOK_TOKEN="secret-token"
```

`SMS_WEBHOOK_TOKEN` is optional. If neither `SMS_MODE=debug` nor `SMS_WEBHOOK_URL` is configured, `auth-request-code` returns `SMS_SEND_FAILED` and deletes the generated code.

## iOS base URL

For Supabase, set the app API base URL to:

```text
https://<project-ref>.supabase.co/functions/v1
```

and set `PONCHI_AUTH_BACKEND` to:

```text
supabase
```
