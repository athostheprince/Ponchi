# App Store релиз

tags: #ponchi #roadmap #appstore #release
updated: 2026-04-16

## Что уже видно по проекту

- у приложения есть основной target и рабочая сборочная база;
- bundle id сейчас задан, но выглядит как временный;
- нет тестовых target-ов;
- нет privacy manifest;
- нет релизного юридического пакета;
- нет crash reporting;
- нет оформленного TestFlight-пайплайна.

## Цель

Собрать не просто “архив, который можно отправить”, а App Store-ready пакет:

- стабильная сборка;
- заполненные метаданные;
- юридическая и privacy часть;
- account deletion;
- screenshots;
- smoke-tested поведение на чистой установке.

## P0

### 1. Release-конфиг

Нужно:

- окончательно утвердить `Bundle Identifier`;
- выровнять deployment target;
- зафиксировать orientation policy;
- проверить, что `Debug` и `Release` различаются только там, где это задумано;
- собрать `Release` локально из Xcode.

Проблемные точки:

- `PRODUCT_BUNDLE_IDENTIFIER = come.ponchi.app`
- `Podfile` на `iOS 13.0`, target на `17.0`
- `YandexMapsMobile` только в `Release`
- `workspace` нужно перепроверить прямо в Xcode

### 2. Privacy и legal

Нужно:

- `Privacy Policy URL`
- `Support URL`
- честно заполненный `App Privacy` в App Store Connect
- account deletion внутри приложения
- terms / privacy screens или web pages
- `PrivacyInfo.xcprivacy`, если проект использует API, требующие privacy manifest / required reason

### 3. Account deletion

Это отдельный hard requirement для приложений с аккаунтами.

Для Ponchi это означает:

- в профиле должна быть явная точка входа;
- на сервере должен быть delete/anonymize flow;
- пользователь не должен писать в поддержку “удалите меня вручную”, если аккаунт создается внутри приложения.

### 4. App Review ready build

Нужно:

- убрать явно временные и декоративные вещи;
- убедиться, что core flow проходит до конца;
- подготовить заметки для App Review;
- при необходимости дать demo account / тестовый номер.

## P1

### 1. QA и тесты

Минимум:

- unit-tests на `PhoneNumberFormatter`, `Cart`, auth error mapping, menu decoding;
- UI smoke test на `login -> menu -> detail -> cart -> order`;
- ручной smoke script на чистой установке.

### 2. Crash reporting и логирование

Без этого TestFlight становится слишком слепым.

Минимум:

- crashes;
- auth failures;
- order failures;
- menu load failures.

### 3. Ассеты и лицензии

Нужно:

- проверить AppIcon;
- проверить launch assets;
- провести аудит шрифтов;
- избавиться от `PERSONALUSE` ресурсов до коммерческого релиза.

## P2

### 1. CI / release checklist automation

Желательно:

- отдельный release checklist;
- сборка на CI;
- быстрый smoke pipeline;
- tagged builds.

### 2. Очистка repo перед релизом

Нужно убрать или изолировать:

- `Ponchi-clean/`
- `docs/.DS_Store`
- `fonts/.DS_Store`
- архивы `ponchi-functions/*.zip`
- legacy/stale files

## App Store checklist для Ponchi

- [ ] `Release` собирается без локальных костылей
- [ ] Профиль не содержит пустых UI-веток
- [ ] Заказ проходит end-to-end
- [ ] `Delete account` доступен из приложения
- [ ] `Privacy Policy URL` готов
- [ ] `Support URL` готов
- [ ] `App Privacy` заполнен
- [ ] `PrivacyInfo.xcprivacy` добавлен при необходимости
- [ ] Подготовлены screenshots
- [ ] Подготовлен TestFlight build
- [ ] Пройден ручной smoke test

## Связанные заметки

- [[01 - Apple требования]]
- [[01 - План релиза на 8 недель]]
- [[02 - Критические проблемы]]

