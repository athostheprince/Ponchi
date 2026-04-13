# Ponchi Project Map

Этот документ нужен как "карта квартиры" проекта.
Его задача не в том, чтобы описать все до последней строчки, а в том, чтобы быстро ответить на вопросы:

- где у меня UI;
- где данные;
- где сеть;
- где auth;
- что уже работает;
- что пока только подготовлено;
- как лучше раскладывать новые файлы, чтобы не теряться.

## 1. Быстрая ментальная модель

Сейчас проект состоит из нескольких больших зон:

1. `Ponchi/Views`
   Это все, что пользователь видит.

2. `Ponchi/ViewModels`
   Это состояние экранов и UI-логика.

3. `Ponchi/Models`
   Это основные модели приложения: напитки, пользователь, заказ.

4. `Ponchi/Utilites`
   Это технические помощники: сеть, keychain, user defaults, preview, haptics, keyboard.

5. `docs`
   Это документы по API, backend и планам.

6. `ponchi-functions`
   Это отдельный backend на Yandex Cloud Functions.

Главная мысль:

- `Ponchi` = iOS-клиент.
- `docs` = описание контракта и схем.
- `ponchi-functions` = серверная часть auth.

## 2. Корень iOS-приложения

В корне папки `Ponchi/` лежат важные входные точки:

- `PonchiApp.swift`
  Точка входа в приложение.
  Здесь собирается `PonchiViewModel`, подключается меню, создается `Cart`, `OrderViewModel`, `UserViewModel`.

- `PonchiCustomTabBar.swift`
  Главный контейнер приложения после launch.
  Он переключает экран меню, корзину, чеки и показывает оверлеи вроде detail/profile.

- `Info.plist`
  Базовые настройки приложения.

- `Assets.xcassets`
  Все картинки и color assets.

## 3. Views: что и где

`Ponchi/Views` сейчас организован в целом понятно:

- `Views/Components`
  Общие переиспользуемые UI-элементы.

- `Views/Screens`
  Конкретные экраны приложения, разложенные по фичам.

### 3.1 `Views/Components`

Это "общий UI-набор".

#### `Views/Components/Buttons`

Сейчас здесь лежат:

- `CloseButton.swift`
- `CustomTabButton.swift`
- `GlassButton.swift`
- `IncreaseButton.swift`
- `MattePlusButton.swift`
- `PriceButtonView.swift`
- `TotalPriceButton.swift`

Проблема:
`TotalPriceButton.swift` есть и здесь, и отдельно в `DetailViews/Components`.
Это один из источников путаницы.

Правило на будущее:

- если компонент используется в нескольких фичах -> оставить в `Views/Components`
- если компонент нужен только detail-экрану -> держать его внутри `DetailViews/Components`

#### `Views/Components/Extentions`

Технические расширения и UI-токены:

- `ColorEx.swift`
- `StaticColorEx.swift`
- `FontEx.swift`
- `ArrayEx.swift`
- `DateExtention.swift`
- `HEXColor`

Это хорошее место для цветов и шрифтов.

#### `Views/Components/Shapes`

Фигуры и индикаторы:

- `LiquidPageIndicator.swift`
- `Shapes.swift`
- `WaveShape.swift`

#### `Views/Components/fonts`

Файлы шрифтов.
Это скорее ресурсы, чем Swift-код.

### 3.2 `Views/Screens`

Это уже фичи приложения:

- `CartViews`
- `DetailViews`
- `LaunchViews`
- `MenuViews`
- `OrderViews`
- `ProfileViews`

Это хороший паттерн: раскладывать UI по сценариям/экранам.

#### `MenuViews`

- `Main`
  Главные файлы экрана меню.
- `Components`
  Компоненты, которые нужны только меню.

#### `DetailViews`

- `PonchiDrinkDetailView.swift`
  Главный экран detail.
- `Main`
  Основные внутренние блоки detail.
- `Components`
  Локальные вспомогательные detail-компоненты.

#### `ProfileViews`

- `Forms`
  Логин и регистрация.
- `UserView`
  Основной профиль.
- `Components`
  Локальные компоненты профиля.

#### `CartViews`, `OrderViews`, `LaunchViews`

Тоже разложены по смыслу и в целом читаются нормально.

## 4. Models: доменные сущности

Сейчас `Ponchi/Models` плоская:

- `Ponchi.swift`
- `User.swift`
- `Order.swift`

Это базовые модели домена приложения.

Простыми словами:

- `Ponchi` = товар/напиток/позиция меню
- `User` = пользователь внутри приложения
- `Order` = заказ

Это не DTO и не view state.
Это именно "модели приложения".

## 5. ViewModels: состояние экранов

Сейчас `Ponchi/ViewModels` тоже плоская:

- `PonchiViewModel.swift`
- `UserViewModel.swift`
- `OrderViewModel.swift`
- `Cart.swift`

### Что делает каждый

- `PonchiViewModel`
  Управляет меню, detail, загрузкой товаров, категориями, офлайн-состоянием.

- `UserViewModel`
  Управляет auth-формами, профилем, редактированием, избранным, бонусами.

- `OrderViewModel`
  Управляет заказами.

- `Cart`
  По сути это тоже state-holder корзины.

Проблема:
файлы лежат в одной плоской папке, хотя относятся к разным фичам.

## 6. Utilities: самая важная зона путаницы

Сейчас у тебя папка называется `Utilites`.
Правильнее было бы `Utilities`.

Но главное даже не опечатка, а то, что внутри смешаны разные типы вещей:

- сеть;
- локальное хранение;
- preview;
- UI-хелперы.

### 6.1 `Utilites/Network`

Здесь лежит не только сеть, а "данные и инфраструктура".

Подпапки:

- `MenuData`
- `UserData`
- `LocalUserSettings`
- `Promo`

#### `MenuData`

Это сейчас самая зрелая часть data-layer на iOS.

Файлы:

- `NetworkService.swift`
  Базовый HTTP-клиент.

- `MenuRemoteDataSource.swift`
  Тянет меню из сети.

- `MenuLocalDataSource.swift`
  Достает локальное меню.

- `LocalMenuService.swift`
  Читает резервный `Ponchi.json` из bundle.

- `Repository.swift`
  Склеивает remote + local fallback.

- `LoadMenuUseCase.swift`
  Use case "загрузить меню".

- `MenuResult.swift`
  Объект результата загрузки: items/source/message.

Это уже настоящая архитектура:

`ViewModel -> UseCase -> Repository -> Remote/Local -> NetworkService`

Именно меню у тебя сейчас ближе всего к "чистой" структуре.

#### `UserData`

Сейчас это auth-зона, но пока не доведенная до конца на iOS.

Файлы:

- `AuthRequestModels.swift`
- `AuthResponseModels.swift`
- `SessionManager.swift`

Что важно:

- названия `AuthRequestModels` и `AuthResponseModels` сейчас перепутаны по содержимому;
- request DTO лежат в `AuthResponseModels.swift`;
- response DTO лежат в `AuthRequestModels.swift`.

То есть с точки зрения смысла эту папку лучше позже причесать.

#### `LocalUserSettings`

Это не сеть.
Это локальная инфраструктура.

Файлы:

- `AppSettings.swift`
  Обертка над `UserDefaults`.

- `KeychainService.swift`
  Обертка над Keychain.

По смыслу это лучше бы лежало не в `Network`, а в чем-то вроде:

- `Infrastructure/Persistence`
или
- `Data/Local`

#### `Promo`

Тут лежит `PromoItem.swift`.
Это вообще не сеть и не infrastructure.
Это просто модель для promo UI.

То есть эта папка сейчас названа не по сути.

### 6.2 `Utilites/UI`

Здесь лежат UI-хелперы:

- `HapticManager.swift`
- `KeyboardResponder.swift`
- `PositionPrefernceKey.swift`
- `PromoManager.swift`

Это нормальная техпапка, но `PromoManager` возможно лучше относить к фиче, если он не общий.

### 6.3 `Utilites/Preview`

Сейчас есть и:

- `Utilites/Preview`
- `Utilites/Preview `

То есть в проекте есть дублирующая папка с пробелом в конце.
Это технический мусор, который очень мешает ориентироваться.

## 7. Что уже реально работает по сети

### Работает сейчас

1. Меню загружается из удаленного JSON на Yandex Cloud Storage.
2. Есть общий `NetworkService`.
3. Есть fallback на локальный `Ponchi.json`.
4. `PonchiViewModel` умеет показывать офлайн-баннер и использовать резервные данные.

### Не подключено в iOS, но уже подготовлено

1. Auth API contract в `docs/api`.
2. Backend auth в `ponchi-functions`.
3. DTO для auth на стороне iOS.

### Пока остается локальным

1. Логин/регистрация в SwiftUI.
2. Создание `User` прямо в iOS без запроса в backend.
3. Генерация "сессии" через локальный UUID.

Именно поэтому auth сейчас ощущается самым мутным местом:
часть уже серверная, а часть еще прототипная.

## 8. Как сейчас устроен auth

### На backend уже есть

В `ponchi-functions`:

- `auth-request-code`
- `auth-verify-code`
- `auth-login`
- `auth-reset-password`
- `auth-me`

Плюс API Gateway:

- `docs/api/gateway-auth.yaml`

Плюс контракт:

- `docs/api/contract.md`

### На iOS уже есть

- auth-формы в `ProfileViews/Forms`
- `UserViewModel`
- DTO-модели в `Utilites/Network/UserData`
- Keychain

### На iOS еще не хватает

- `AuthService`
- `AuthRemoteDataSource`
- `AuthRepository`
- реального вызова `/v1/auth/...`

То есть auth в iOS пока не дошел до той же зрелости, что меню.

## 9. Где у тебя сейчас основные источники путаницы

1. `Utilites/Network` содержит не только сеть.
2. `AuthRequestModels` и `AuthResponseModels` названы наоборот.
3. `PromoItem` лежит в `Network`, хотя это не сеть.
4. Есть две папки `Preview` и `Preview `.
5. Есть дубли вроде `TotalPriceButton`.
6. `ViewModels` и `Models` плоские, без разбиения по доменам.
7. Auth пока частично локальный, частично уже backend-driven.

Это не значит, что проект плохой.
Это значит, что он вырос, и теперь ему нужен второй этап организации.

## 10. Как я бы разложила проект

Я бы не делала сразу сверхсложную enterprise-структуру.
Для тебя сейчас лучше всего подойдет структура "по фичам + общий core".

### Целевая структура

```text
Ponchi
├── App
│   ├── PonchiApp.swift
│   └── PonchiCustomTabBar.swift
├── Core
│   ├── UI
│   │   ├── HapticManager.swift
│   │   ├── KeyboardResponder.swift
│   │   └── PositionPreferenceKey.swift
│   ├── DesignSystem
│   │   ├── Colors
│   │   ├── Fonts
│   │   ├── Buttons
│   │   └── Shapes
│   ├── Extensions
│   └── Storage
│       ├── AppSettings.swift
│       └── KeychainService.swift
├── Features
│   ├── Menu
│   │   ├── Views
│   │   ├── ViewModel
│   │   ├── Models
│   │   └── Data
│   │       ├── Remote
│   │       ├── Local
│   │       ├── Repository
│   │       └── UseCases
│   ├── Auth
│   │   ├── Views
│   │   ├── ViewModel
│   │   ├── Models
│   │   └── Data
│   │       ├── DTO
│   │       ├── Remote
│   │       ├── Repository
│   │       └── Session
│   ├── Profile
│   ├── Cart
│   ├── Orders
│   └── Detail
├── Models
├── Assets.xcassets
└── Resources
```

Это не значит, что надо завтра все физически переносить.
Это значит, что у проекта должен появиться понятный "направляющий скелет".

## 11. Самый реалистичный порядок наведения порядка

Если делать это без боли, я бы шла в таком порядке:

### Шаг 1. Почистить явный шум

- убрать дублирующую папку `Utilites/Preview `
- проверить лишние `.DS_Store`
- проверить дубли компонентов

### Шаг 2. Навести порядок в названиях

- `Utilites` -> `Utilities`
- `Extentions` -> `Extensions`
- `DateExtention` -> `DateExtension`
- `PositionPrefernceKey` -> `PositionPreferenceKey`

### Шаг 3. Разделить "сеть" и "локальное хранение"

Из `Network` вынести:

- `KeychainService`
- `AppSettings`

Потому что это не HTTP и не API.

### Шаг 4. Выделить auth как отдельную фичу

Сейчас auth размазан между:

- `ProfileViews/Forms`
- `UserViewModel`
- `Utilites/Network/UserData`
- `docs`
- `ponchi-functions`

Его стоит сделать отдельной фичей хотя бы ментально, а потом и по папкам.

### Шаг 5. Причесать DTO и сервисы

Сделать ясные зоны:

- `Auth/DTO`
- `Auth/Remote`
- `Auth/Repository`
- `Auth/Session`

### Шаг 6. Потом уже физически переносить экраны по фичам

Это уже второй этап, когда тебе станет спокойнее.

## 12. Что я бы не трогала прямо сейчас

Не трогала бы сразу:

- `Views/Screens` как идею
- `MenuData` архитектуру
- `PonchiViewModel` загрузку меню
- `docs`
- `ponchi-functions`

Потому что это как раз уже достаточно устойчивые части.

## 13. Самое важное коротко

Если одной фразой:

Сейчас у тебя не "хаос", а проект, который вырос быстрее, чем успела выровняться структура.

То, что уже хорошо:

- меню;
- общий HTTP-клиент;
- fallback на локальные данные;
- backend auth;
- документация;
- разбиение экранов по фичам.

То, что больше всего просит порядка:

- `Utilities/Network`;
- auth в iOS;
- названия папок и файлов;
- дубли и технический мусор.

## 14. Следующий лучший шаг

Если наводить порядок постепенно, самым разумным следующим шагом будет:

1. переименовать технические папки и убрать дубли;
2. вынести local storage из `Network`;
3. выделить `Auth` как отдельную понятную зону.

И только потом уже делать глубокий рефакторинг файлов.
