# Auth Final Checklist

Этот чеклист нужен перед iOS-интеграцией, чтобы убедиться, что:

- таблицы в PostgreSQL соответствуют ожиданиям функций;
- все 4 auth-функции собраны корректно;
- gateway маршрутизирует запросы в правильные функции;
- полный auth-flow работает через `curl`.

## 1. Что уже проверено локально

Локально проверены:

- синтаксис `auth-request-code`
- синтаксис `auth-verify-code`
- синтаксис `auth-login`
- синтаксис `auth-reset-password`
- валидность YAML-файла OpenAPI
- состав ZIP-архивов для функций

Это значит, что исходники согласованы между собой.
Но это еще не доказывает, что удаленная БД и gateway настроены правильно.

## 2. Что должно быть задеплоено в Yandex Cloud

У тебя должно быть 4 функции:

- `auth-request-code`
- `auth-verify-code`
- `auth-login`
- `auth-reset-password`

Для каждой:

- Runtime: `Node.js 22`
- Entry point: `index.handler`
- одинаковые env vars:
  - `DB_HOST`
  - `DB_PORT`
  - `DB_USER`
  - `DB_PASS`
  - `DB_NAME`

## 3. Что должно быть в gateway

Должны существовать 4 маршрута:

- `POST /v1/auth/request_code`
- `POST /v1/auth/verify_code`
- `POST /v1/auth/login`
- `POST /v1/auth/reset_password`

Актуальный локальный шаблон OpenAPI:

- `/Users/maryromanova/Developer/Ponchi/docs/api/gateway-auth.yaml`

Важно:

- для `reset_password` нужно подставить реальный `function_id` вместо `REPLACE_WITH_AUTH_RESET_PASSWORD_FUNCTION_ID`

## 4. Проверка схемы БД в DBeaver

Открой и выполни:

- [auth-final-check.sql](/Users/maryromanova/Developer/Ponchi/docs/backend/auth-final-check.sql)

Функции ожидают такие таблицы и поля:

### `users`

- `id`
- `phone`
- `password_hash`
- `name`
- `bonuses`
- `avatar`
- `created_at`

### `sms_codes`

- `id`
- `phone`
- `code`
- `expires_at`
- `purpose`
- `created_at`

### `sessions`

- `token`
- `user_id`
- `expires_at`
- `created_at`

Минимально желательно:

- `users.phone` уникален
- `sessions.token` уникален

## 5. Полный smoke-test

Для теста удобно взять один номер, например:

`+79990001122`

### Шаг 0. Очистить тестовые данные

Выполни вручную в DBeaver:

```sql
DELETE FROM sessions
WHERE user_id IN (SELECT id FROM users WHERE phone = '+79990001122');

DELETE FROM sms_codes
WHERE phone = '+79990001122';

DELETE FROM users
WHERE phone = '+79990001122';
```

### Шаг 1. Signup code

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/request_code" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","purpose":"signup"}'
```

Ожидаемо:

- ответ `200`
- тело `{ "ok": true, "retry_after": 60 }`

Проверка в БД:

```sql
SELECT id, phone, code, purpose, expires_at, created_at
FROM sms_codes
WHERE phone = '+79990001122'
ORDER BY created_at DESC
LIMIT 1;
```

Ожидаемо:

- есть новая строка
- `purpose = 'signup'`

### Шаг 2. Verify code

Подставь реальный код из БД:

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/verify_code" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","code":"1234","name":"Мария","password":"secret123"}'
```

Ожидаемо:

- ответ `200`
- приходит `access_token`
- приходит `user`

Проверка в БД:

```sql
SELECT id, phone, name, bonuses, avatar, created_at
FROM users
WHERE phone = '+79990001122';

SELECT token, user_id, expires_at, created_at
FROM sessions
ORDER BY created_at DESC
LIMIT 3;

SELECT *
FROM sms_codes
WHERE phone = '+79990001122' AND purpose = 'signup';
```

Ожидаемо:

- пользователь создан
- новая сессия создана
- signup-код удален

### Шаг 3. Login

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","password":"secret123"}'
```

Ожидаемо:

- ответ `200`
- приходит новый `access_token`

Проверка в БД:

```sql
SELECT token, user_id, expires_at, created_at
FROM sessions
WHERE user_id = (SELECT id FROM users WHERE phone = '+79990001122')
ORDER BY created_at DESC;
```

Ожидаемо:

- у пользователя стало как минимум 2 сессии:
  - одна после `verify_code`
  - одна после `login`

### Шаг 4. Reset code

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/request_code" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","purpose":"reset"}'
```

Проверка в БД:

```sql
SELECT id, phone, code, purpose, expires_at, created_at
FROM sms_codes
WHERE phone = '+79990001122' AND purpose = 'reset'
ORDER BY created_at DESC
LIMIT 1;
```

### Шаг 5. Reset password

Подставь reset-код из БД:

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/reset_password" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","code":"1234","new_password":"newsecret123"}'
```

Ожидаемо:

- ответ `200`
- тело `{ "ok": true }`

Проверка в БД:

```sql
SELECT *
FROM sms_codes
WHERE phone = '+79990001122' AND purpose = 'reset';

SELECT token, user_id, expires_at, created_at
FROM sessions
WHERE user_id = (SELECT id FROM users WHERE phone = '+79990001122');
```

Ожидаемо:

- reset-коды удалены
- старые сессии удалены
- у пользователя `0` активных строк в `sessions`

### Шаг 6. Login with old password must fail

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","password":"secret123"}'
```

Ожидаемо:

- ответ `401`
- `{ "error": "INVALID_CREDENTIALS" }`

### Шаг 7. Login with new password must succeed

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","password":"newsecret123"}'
```

Ожидаемо:

- ответ `200`
- новый `access_token`
- в `sessions` снова появилась 1 запись

## 6. Что считать успехом

Перед iOS-интеграцией auth можно считать готовым, если:

1. все 4 маршрута отвечают через gateway;
2. таблицы содержат именно те поля, которые ждут функции;
3. регистрация создает `users` и `sessions`;
4. логин создает новую сессию;
5. reset меняет пароль и удаляет старые сессии;
6. старый пароль перестает работать;
7. новый пароль работает.

## 7. Что я не мог проверить отсюда

Я не могу из локальной среды подтвердить:

- что функции уже задеплоены именно с этим кодом;
- что gateway обновлен последней версией spec;
- что удаленная PostgreSQL реально содержит нужную схему;
- что env vars в Yandex Cloud везде одинаковые.

Поэтому финальный truth source для этого этапа:

- DBeaver
- Cloud Functions logs
- `curl` через gateway
