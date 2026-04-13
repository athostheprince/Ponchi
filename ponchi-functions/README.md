# Ponchi Cloud Functions

Локальные исходники серверлесс-функций для Yandex Cloud.

## Зачем это нужно

Редактор в консоли удобен только для быстрых правок. Для реального проекта лучше:

- хранить код функций в git;
- деплоить функции из локальной папки через `ZIP-архив`;
- переиспользовать один и тот же `root.crt` для всех функций, работающих с Managed PostgreSQL.

## Что такое `root.crt`

`root.crt` не генерируется вручную и не является секретом приложения.
Это корневой CA-сертификат Yandex Cloud для проверки TLS-соединения с Managed PostgreSQL.

Для новой функции просто:

1. Скопируй `root.crt` из уже рабочей функции `auth-request-code`.
2. Или скачай CA-файл из документации Yandex Cloud и сохрани под именем `root.crt`.

Один и тот же файл можно использовать в:

- `auth-request-code`
- `auth-verify-code`
- `auth-login`
- `auth-reset-password`

## Рекомендуемая структура

Каждая функция хранится в своей папке:

- `index.js`
- `package.json`
- `root.crt`

Опционально:

- `package-lock.json`

## Как деплоить

Пример для одной функции:

```bash
cd ponchi-functions/auth-verify-code
zip -r auth-verify-code.zip index.js package.json root.crt
```

Дальше в Yandex Cloud Functions:

1. Создай функцию или открой существующую.
2. Выбери `ZIP-архив`.
3. Загрузить `auth-verify-code.zip`.
4. Entry point: `index.handler`.
5. Runtime: `Node.js 22`.
6. Добавь те же env vars, что и в `auth-request-code`:
   `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, `DB_NAME`.

Если у рабочей функции включены дополнительные настройки сети или сервисный аккаунт, скопируй их и сюда.
