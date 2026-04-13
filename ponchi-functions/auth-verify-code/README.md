# auth-verify-code

Функция подтверждает SMS-код регистрации, создает пользователя и открывает сессию.

## Что положить в папку перед деплоем

- `index.js`
- `package.json`
- `root.crt`

`root.crt` возьми из рабочей функции `auth-request-code`.
Создавать новый сертификат не нужно.

## Что настроить в Yandex Cloud Function

- Runtime: `Node.js 22`
- Entry point: `index.handler`
- Env vars:
  - `DB_HOST`
  - `DB_PORT`
  - `DB_USER`
  - `DB_PASS`
  - `DB_NAME`

## Как загрузить

Вариант 1, рекомендуемый:

```bash
cd ponchi-functions/auth-verify-code
zip -r auth-verify-code.zip index.js package.json root.crt
```

Затем в консоли выбери источник кода `ZIP-архив` и загрузи архив.

Вариант 2:

Использовать встроенный редактор и вручную создать там три файла:

- `index.js`
- `package.json`
- `root.crt`

## Проверка через curl

```bash
curl -X POST "https://d5dv0tsfdqg45rj2b9i8.4b4k4pg5.apigw.yandexcloud.net/v1/auth/verify_code" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+79990001122","code":"1234","name":"Мария","password":"secret123"}'
```
