-- Auth events helper script for DBeaver.
-- Use this to inspect auth activity while testing the iOS app.

-- 1) Make sure the journal table and activity view exist.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('auth_events', 'auth_activity')
ORDER BY table_name;

-- 2) One combined timeline: backend events + currently active SMS codes.
SELECT *
FROM public.auth_activity
ORDER BY event_time DESC
LIMIT 100;

-- 3) Timeline for one phone number.
-- Replace the phone before running.
SELECT *
FROM public.auth_activity
WHERE phone = '+79990001122'
ORDER BY event_time DESC
LIMIT 100;

-- 4) Backend events only.
SELECT
  created_at,
  event_type,
  success,
  error_code,
  phone,
  user_id,
  metadata
FROM public.auth_events
ORDER BY created_at DESC
LIMIT 100;

-- 5) Currently active SMS codes only.
-- Codes are deleted after successful signup/reset and also expire quickly.
SELECT
  phone,
  code,
  purpose,
  attempts,
  expires_at,
  created_at
FROM public.sms_codes
WHERE expires_at > NOW()
ORDER BY created_at DESC;

-- 6) Count events by type.
SELECT
  event_type,
  success,
  COUNT(*) AS count
FROM public.auth_events
GROUP BY event_type, success
ORDER BY count DESC, event_type;
