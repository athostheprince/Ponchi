# Ponchi API Contract (v1 draft)

Документ описывает минимальный контракт между iOS‑клиентом и бэкендом.
Цель — зафиксировать, какие запросы есть, какие поля ожидаются и какие ответы возвращаются.

Base URL: `https://api.ponchi.app`
Version: `/v1`

## Общие правила
- Формат данных: JSON.
- Авторизация: `Authorization: Bearer <access_token>`.
- Временные метки: ISO 8601 (например: `2026-03-12T12:00:00Z`).
- Телефон: формат `+7XXXXXXXXXX`.

## 1) Auth (телефон + SMS)

### 1.1 Запросить SMS‑код
`POST /v1/auth/request_code`

Запрос:
```json
{
  "phone": "+79990001122"
}
```

Ответ:
```json
{
  "ok": true,
  "retry_after": 60
}
```

Ошибки:
- `400 INVALID_PHONE`
- `429 TOO_MANY_REQUESTS`

### 1.2 Подтвердить код и создать/войти
`POST /v1/auth/verify_code`

Запрос:
```json
{
  "phone": "+79990001122",
  "code": "1234",
  "password": "secret123"
}
```

Ответ:
```json
{
  "access_token": "token",
  "user": {
    "id": "uuid",
    "phone": "+79990001122",
    "created_at": "2026-03-12T12:00:00Z"
  }
}
```

Ошибки:
- `400 INVALID_CODE`
- `400 CODE_EXPIRED`
- `400 WEAK_PASSWORD`

### 1.3 Сброс пароля через SMS
`POST /v1/auth/reset_password`

Запрос:
```json
{
  "phone": "+79990001122",
  "code": "1234",
  "new_password": "newsecret"
}
```

Ответ:
```json
{
  "ok": true
}
```

Ошибки:
- `400 INVALID_CODE`
- `400 CODE_EXPIRED`

## 2) Menu

### 2.1 Получить меню
`GET /v1/menu`

Ответ:
```json
{
  "categories": [
    { "id": 1, "name": "Кофе" }
  ],
  "items": [
    {
      "id": 101,
      "category_id": 1,
      "name": "Капучино",
      "description": "…",
      "price": 220,
      "image_url": "https://…",
      "is_available": true
    }
  ],
  "updated_at": "2026-03-12T12:00:00Z"
}
```

## 3) Orders

### 3.1 Создать заказ
`POST /v1/orders`

Headers:
- `Authorization: Bearer <access_token>`

Запрос:
```json
{
  "items": [
    { "menu_id": 101, "qty": 2, "size": "M", "toppings": ["сироп"] }
  ],
  "total": 440,
  "comment": "Без сахара",
  "pickup_time": "2026-03-12T13:30:00Z"
}
```

Ответ:
```json
{
  "order_id": "uuid",
  "status": "new"
}
```

Ошибки:
- `400 INVALID_MENU_ITEM`
- `400 PRICE_MISMATCH`

### 3.2 Получить мои заказы
`GET /v1/orders`

Headers:
- `Authorization: Bearer <access_token>`

Ответ:
```json
{
  "orders": [
    {
      "id": "uuid",
      "status": "new",
      "total": 440,
      "created_at": "2026-03-12T12:10:00Z"
    }
  ]
}
```

## 4) Профиль

### 4.1 Получить профиль
`GET /v1/me`

Headers:
- `Authorization: Bearer <access_token>`

Ответ:
```json
{
  "id": "uuid",
  "phone": "+79990001122",
  "bonus_points": 120
}
```

## 5) Admin (после релиза)

### 5.1 Создать позицию меню
`POST /v1/admin/menu`

Headers:
- `Authorization: Bearer <admin_token>`

Запрос:
```json
{
  "category_id": 1,
  "name": "Латте",
  "price": 240,
  "is_available": true
}
```

Ответ:
```json
{
  "id": 102
}
```
