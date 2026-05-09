# Supabase migration

This document tracks the safe migration from Yandex Cloud Functions to Supabase Edge Functions.

## What is already in the repo

- `supabase/config.toml`
- `supabase/migrations/20260509192000_auth_initial_schema.sql`
- `supabase/migrations/20260509193000_auth_week_2.sql`
- `supabase/functions/auth-request-code`
- `supabase/functions/auth-verify-code`
- `supabase/functions/auth-login`
- `supabase/functions/auth-reset-password`
- `supabase/functions/auth-me`

The old Yandex functions stay in `ponchi-functions/` until Supabase is verified in production.

The initial schema enables Row Level Security on auth tables and does not add public policies. The mobile app should not access these tables directly; it should call Edge Functions only.

## GitHub integration settings

Because `supabase/` is at the repository root:

- Working directory: `.`
- Production branch: `master` if production deploys should happen only after merging to `master`
- Preview branches: optional; useful when the Supabase plan supports branching

## Required Supabase setup

1. Connect the GitHub repository in Supabase Dashboard.
2. Make sure the latest branch containing `supabase/` is pushed.
3. Apply migrations through Supabase GitHub integration or the CLI.
4. Deploy the Edge Functions through GitHub integration or the CLI.
5. Configure SMS delivery.

For local SMS testing:

```bash
supabase secrets set SMS_MODE=debug
```

For production SMS:

```bash
supabase secrets set SMS_WEBHOOK_URL="https://example.com/send-sms"
supabase secrets set SMS_WEBHOOK_TOKEN="secret-token"
```

`SMS_WEBHOOK_TOKEN` is optional. The webhook must accept:

```json
{ "phone": "+79990000000", "code": "1234" }
```

## iOS switch

When Supabase is ready, update the app build settings:

```text
PONCHI_AUTH_BACKEND = supabase
PONCHI_API_BASE_URL = https://<project-ref>.supabase.co/functions/v1
```

Do this after the functions are deployed and tested. Until then, keep:

```text
PONCHI_AUTH_BACKEND = yandex
```

## Smoke tests

Replace `<project-ref>` before running.

```bash
curl -X POST "https://<project-ref>.supabase.co/functions/v1/auth-request-code" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990000000","purpose":"signup"}'
```

Then use the code from the SMS webhook or debug logs:

```bash
curl -X POST "https://<project-ref>.supabase.co/functions/v1/auth-verify-code" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990000000","code":"1234","name":"Test","password":"123456"}'
```

Use the returned `access_token`:

```bash
curl "https://<project-ref>.supabase.co/functions/v1/auth-me" \
  -H "Authorization: Bearer <access_token>"
```
