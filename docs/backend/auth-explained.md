# Ponchi Auth Explained

Этот документ связывает три слоя проекта:

1. текущий iOS UI;
2. серверлесс-функции в Yandex Cloud;
3. эквивалентную реализацию на Vapor.

## 1. Как это устроено сейчас

Сейчас экран авторизации в iOS пока работает локально:

- форма регистрации собирает `name`, `phone`, `password`;
- форма входа собирает поля и сразу создает локальный `User`;
- `UserViewModel` сам кладет случайный токен в Keychain и считает пользователя залогиненным.

Это удобно для прототипа, но это не настоящий бэкенд:

- пользователь не создается в БД;
- пароль не проверяется на сервере;
- сессия не хранится в БД;
- другой телефон не сможет "увидеть" того же пользователя.

## 2. Как это должно работать после интеграции

### Регистрация

Поток такой:

1. iOS отправляет `POST /v1/auth/request_code` с `phone` и `purpose=signup`.
2. Gateway направляет запрос в Cloud Function `auth-request-code`.
3. Функция создает код в таблице `sms_codes`.
4. Пользователь вводит код в приложении.
5. iOS отправляет `POST /v1/auth/verify_code`.
6. Gateway вызывает `auth-verify-code`.
7. Функция:
   - проверяет код;
   - хэширует пароль;
   - создает `users`;
   - создает `sessions`;
   - возвращает `access_token` и `user`.
8. iOS сохраняет `access_token` в Keychain и переводит интерфейс в состояние "пользователь вошел".

### Вход

1. iOS отправляет `POST /v1/auth/login`.
2. Gateway вызывает `auth-login`.
3. Функция:
   - находит пользователя;
   - сравнивает пароль;
   - создает новую запись в `sessions`;
   - возвращает `access_token` и `user`.
4. iOS сохраняет токен и обновляет `UserViewModel`.

### Сброс пароля

1. iOS отправляет `POST /v1/auth/request_code` с `purpose=reset`.
2. Пользователь вводит SMS-код и новый пароль.
3. iOS отправляет `POST /v1/auth/reset_password`.
4. Gateway вызывает `auth-reset-password`.
5. Функция:
   - проверяет reset-код;
   - меняет `password_hash`;
   - удаляет старые сессии;
   - удаляет reset-коды;
   - возвращает `{ "ok": true }`.

## 3. Как это связано с твоим UI

Текущие Swift-файлы уже почти отображают нужные шаги, но пока без сети:

- `UserViewModel` хранит auth-состояние и поля формы.
- `SignUpForm` отвечает за регистрацию.
- `LoginForm` отвечает за вход.

То есть UI уже существует. Меняется не экран, а источник истины:

- раньше источник истины был локальный `UserViewModel`;
- теперь источником истины становится БД + функции.

На практике это означает:

- кнопка "Зарегистрироваться" больше не создает `User` прямо в Swift;
- кнопка "Войти" больше не генерирует случайный токен;
- вместо этого формы вызывают API;
- ответ API заполняет `user` и сохраняет реальный `access_token`.

Отдельно важно:

- для `login` бэкенду нужны только `phone` и `password`;
- значит на этапе iOS-интеграции поле `Имя` из формы входа нужно убрать;
- и проверка `isLoginFormValid` тоже должна перестать требовать имя.

## 4. Ментальная модель

Удобно думать так:

- API Gateway = роутер перед бэкендом;
- Cloud Function = один обработчик одного use case;
- PostgreSQL = постоянное хранилище пользователей, кодов и сессий;
- iOS = клиент, который только собирает данные и показывает результат.

То есть связка выглядит так:

`SwiftUI -> API Gateway -> Cloud Function -> PostgreSQL -> Cloud Function -> SwiftUI`

## 5. Чем это отличается от Vapor

По бизнес-логике почти ничем.

Разница только в способе запуска:

- в serverless каждая операция живет отдельной функцией;
- в Vapor все маршруты живут внутри одного сервера и одного приложения.

## 6. Как выглядел бы этот же auth на Vapor

Ниже не полный production-код, а понятный аналог того, что делают твои функции.

### routes.swift

```swift
import Vapor

func routes(_ app: Application) throws {
    let auth = app.grouped("v1", "auth")
    let controller = AuthController()

    auth.post("request_code", use: controller.requestCode)
    auth.post("verify_code", use: controller.verifyCode)
    auth.post("login", use: controller.login)
    auth.post("reset_password", use: controller.resetPassword)
}
```

### AuthController.swift

```swift
import Vapor
import Fluent

struct AuthController {
    func requestCode(req: Request) async throws -> RequestCodeResponse {
        let body = try req.content.decode(RequestCodeRequest.self)

        guard body.phone.range(of: #"^\+7\d{10}$"#, options: .regularExpression) != nil else {
            throw Abort(.badRequest, reason: "INVALID_PHONE")
        }

        guard body.purpose == "signup" || body.purpose == "reset" else {
            throw Abort(.badRequest, reason: "INVALID_PURPOSE")
        }

        let smsCode = SmsCode(
            id: UUID(),
            phone: body.phone,
            code: String(Int.random(in: 1000...9999)),
            purpose: body.purpose,
            expiresAt: Date().addingTimeInterval(300)
        )

        try await smsCode.save(on: req.db)
        return RequestCodeResponse(ok: true, retryAfter: 60)
    }

    func verifyCode(req: Request) async throws -> AuthSuccessResponse {
        let body = try req.content.decode(VerifyCodeRequest.self)

        guard body.password.count >= 6 else {
            throw Abort(.badRequest, reason: "WEAK_PASSWORD")
        }

        guard let smsCode = try await SmsCode.query(on: req.db)
            .filter(\.$phone == body.phone)
            .filter(\.$purpose == "signup")
            .sort(\.$createdAt, .descending)
            .first()
        else {
            throw Abort(.badRequest, reason: "INVALID_CODE")
        }

        guard smsCode.code == body.code else {
            throw Abort(.badRequest, reason: "INVALID_CODE")
        }

        guard smsCode.expiresAt > Date() else {
            throw Abort(.badRequest, reason: "CODE_EXPIRED")
        }

        let passwordHash = try Bcrypt.hash(body.password)
        let user = UserModel(
            id: UUID(),
            phone: body.phone,
            passwordHash: passwordHash,
            name: body.name
        )
        try await user.save(on: req.db)

        let token = SessionModel(
            token: [UInt8].random(count: 32).hex,
            userID: try user.requireID(),
            expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60)
        )
        try await token.save(on: req.db)

        try await SmsCode.query(on: req.db)
            .filter(\.$phone == body.phone)
            .filter(\.$purpose == "signup")
            .delete()

        return AuthSuccessResponse(
            accessToken: token.token,
            user: UserDTO(from: user)
        )
    }

    func login(req: Request) async throws -> AuthSuccessResponse {
        let body = try req.content.decode(LoginRequest.self)

        guard let user = try await UserModel.query(on: req.db)
            .filter(\.$phone == body.phone)
            .first()
        else {
            throw Abort(.unauthorized, reason: "INVALID_CREDENTIALS")
        }

        guard try Bcrypt.verify(body.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "INVALID_CREDENTIALS")
        }

        let session = SessionModel(
            token: [UInt8].random(count: 32).hex,
            userID: try user.requireID(),
            expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60)
        )
        try await session.save(on: req.db)

        return AuthSuccessResponse(
            accessToken: session.token,
            user: UserDTO(from: user)
        )
    }

    func resetPassword(req: Request) async throws -> OkResponse {
        let body = try req.content.decode(ResetPasswordRequest.self)

        guard body.newPassword.count >= 6 else {
            throw Abort(.badRequest, reason: "WEAK_PASSWORD")
        }

        guard let smsCode = try await SmsCode.query(on: req.db)
            .filter(\.$phone == body.phone)
            .filter(\.$purpose == "reset")
            .sort(\.$createdAt, .descending)
            .first()
        else {
            throw Abort(.badRequest, reason: "INVALID_CODE")
        }

        guard smsCode.code == body.code else {
            throw Abort(.badRequest, reason: "INVALID_CODE")
        }

        guard smsCode.expiresAt > Date() else {
            throw Abort(.badRequest, reason: "CODE_EXPIRED")
        }

        guard let user = try await UserModel.query(on: req.db)
            .filter(\.$phone == body.phone)
            .first()
        else {
            throw Abort(.badRequest, reason: "INVALID_CODE")
        }

        user.passwordHash = try Bcrypt.hash(body.newPassword)
        try await user.save(on: req.db)

        try await SessionModel.query(on: req.db)
            .filter(\.$user.$id == try user.requireID())
            .delete()

        try await SmsCode.query(on: req.db)
            .filter(\.$phone == body.phone)
            .filter(\.$purpose == "reset")
            .delete()

        return OkResponse(ok: true)
    }
}
```

## 7. Главное наблюдение

Если коротко:

- сейчас у тебя уже есть UI-поток;
- serverless-функции — это просто серверная реализация этого потока;
- Vapor потом будет делать ровно то же самое, только не в четырех отдельных функциях, а в одном приложении с роутами.

Поэтому ты уже строишь "настоящий" бэкенд-мышлением. Меняется только форма упаковки.
