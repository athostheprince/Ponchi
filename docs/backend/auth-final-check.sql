-- Ponchi auth final verification
-- Run these queries in DBeaver against the same PostgreSQL database
-- that is used by Cloud Functions.

-- 1) Make sure the required tables exist.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('users', 'sms_codes', 'sessions')
ORDER BY table_name;

-- 2) Verify columns required by auth functions.
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
    (table_name = 'users' AND column_name IN ('id', 'phone', 'password_hash', 'name', 'bonuses', 'avatar', 'created_at'))
    OR
    (table_name = 'sms_codes' AND column_name IN ('id', 'phone', 'code', 'expires_at', 'purpose', 'created_at'))
    OR
    (table_name = 'sessions' AND column_name IN ('token', 'user_id', 'expires_at', 'created_at'))
  )
ORDER BY table_name, ordinal_position;

-- 3) Verify important uniqueness constraints by checking duplicates.
SELECT phone, COUNT(*)
FROM users
GROUP BY phone
HAVING COUNT(*) > 1;

SELECT token, COUNT(*)
FROM sessions
GROUP BY token
HAVING COUNT(*) > 1;

-- 4) Inspect the latest auth-related rows.
SELECT id, phone, name, bonuses, avatar, created_at
FROM users
ORDER BY created_at DESC
LIMIT 10;

SELECT id, phone, code, purpose, expires_at, created_at
FROM sms_codes
ORDER BY created_at DESC
LIMIT 10;

SELECT token, user_id, expires_at, created_at
FROM sessions
ORDER BY created_at DESC
LIMIT 10;

-- 5) Clean manual test data for one phone, if needed.
-- Replace the phone number before executing.
-- DELETE FROM sessions
-- WHERE user_id IN (SELECT id FROM users WHERE phone = '+79990001122');
--
-- DELETE FROM sms_codes
-- WHERE phone = '+79990001122';
--
-- DELETE FROM users
-- WHERE phone = '+79990001122';
