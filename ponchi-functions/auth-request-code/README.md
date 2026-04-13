# auth-request-code

Функция создает SMS-код для регистрации или сброса пароля.

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
