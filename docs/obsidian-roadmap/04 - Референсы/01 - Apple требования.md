# Apple требования

tags: #ponchi #appstore #apple #references
updated: 2026-04-16

Эта заметка фиксирует официальные Apple-ссылки, на которые стоит опираться при подготовке Ponchi к релизу.

## 1. App Privacy и Privacy Policy

Источник:

- [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy)

Для Ponchi это значит:

- нужна `Privacy Policy`;
- нужен `Privacy Policy URL`;
- нужно честно описать, какие данные собираются и зачем;
- нужно заполнить App Privacy в App Store Connect.

## 2. Удаление аккаунта внутри приложения

Источник:

- [Apps that support account creation must also let users initiate deletion from within the app](https://developer.apple.com/news/?id=i71db0mv)

Для Ponchi это значит:

- если пользователь создает аккаунт в приложении, удаление аккаунта тоже должно инициироваться из приложения;
- для этого нужен и UI-entry point, и backend flow.

## 3. Скриншоты и app previews

Источник:

- [Upload app previews and screenshots](https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots)

Для Ponchi это значит:

- заранее подготовить набор экранов;
- продумать локализацию метаданных;
- не оставлять screenshots на последний день.

## 4. Export compliance

Источник:

- [Provide export compliance information for beta builds](https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-export-compliance-information-for-beta-builds/)

Для Ponchi это значит:

- при загрузке TestFlight/build submission нужно быть готовой ответить на export compliance вопросы.

## 5. App Review Guidelines

Источник:

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

Особенно важно для Ponchi:

- privacy;
- account management;
- working functionality;
- honesty of metadata;
- отсутствие broken/demo-like behavior в основном flow.

## 6. Privacy manifests и required reason APIs

Источник:

- [Describing data use in privacy manifests](https://developer.apple.com/documentation/bundleresources/describing-data-use-in-privacy-manifests)

Для Ponchi это значит:

- проверить собственный app target;
- проверить сторонние зависимости;
- убедиться, нужен ли `PrivacyInfo.xcprivacy` уже сейчас;
- особенно внимательно смотреть на SDK-интеграции перед релизом.

## Как использовать эту заметку

- перед TestFlight пройтись по каждому пункту;
- все обязательные требования перенести в [[04 - App Store релиз]];
- не опираться на старые статьи и пересказы, когда речь идет о submission.

