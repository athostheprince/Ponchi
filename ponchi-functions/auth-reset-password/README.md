# auth-reset-password

Функция проверяет SMS-код восстановления, меняет пароль пользователя и удаляет старые сессии.

## Что должно лежать в папке

- `index.js`
- `package.json`
- `root.crt`

## Настройки Cloud Function

- Runtime: `Node.js 22`
- Entry point: `index.handler`
- Env vars:
  - `DB_HOST`
  - `DB_PORT`
  - `DB_USER`
  - `DB_PASS`
  - `DB_NAME`

## Как загрузить

```bash
cd ponchi-functions/auth-reset-password
zip -r auth-reset-password.zip index.js package.json root.crt
```

Затем загрузи архив в Yandex Cloud Functions как `ZIP-архив`.

## Проверка через curl

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/reset_password" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","code":"1234","new_password":"newsecret123"}'
```
