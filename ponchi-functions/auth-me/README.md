# auth-me

Функция возвращает текущего пользователя по `Bearer`-токену из `sessions`.

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
cd ponchi-functions/auth-me
zip -r auth-me.zip index.js package.json root.crt
```

Затем загрузи архив в Yandex Cloud Functions как `ZIP-архив`.

## Проверка через curl

```bash
curl -X GET "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/me" \
  -H "Authorization: Bearer <access_token>"
```
