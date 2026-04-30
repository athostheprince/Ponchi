# UI и UX

tags: #ponchi #roadmap #ui #ux
updated: 2026-04-16

## Общая оценка

У Ponchi уже есть лицо.
Это твоя сильная сторона.

Сейчас проблема не в том, что UI “плохой”, а в том, что он пока не везде доведен до продуктового качества:

- часть экранов выглядит лучше, чем работает;
- часть экранов работает, но еще не ощущается законченной;
- есть несогласованность между сильными и слабыми зонами.

## Что уже сильное

- цветовая палитра и характер бренда;
- auth-screen как самостоятельный сценарий;
- motion и haptics;
- деталка товара визуально богаче среднего MVP;
- общий tone of product чувствуется.

## Где UI сейчас провисает

- профиль;
- заказы;
- auth UX;
- адаптивность;
- accessibility;
- единообразие состояний `loading / empty / error / success`.

## P0

### 1. Дополировать профиль

Проблемы:

- выбранный аватар не рендерится;
- “почта для чеков” и “напишите нам” не работают;
- выход есть, но delete account нет;
- редактирование профиля локальное и не связано с сервером.

Что сделать:

- завершить ветку `profileImage`;
- сделать работающий avatar picker или убрать его из релиза;
- добавить рабочее действие для support;
- добавить email receipts только если реально есть backend/use case;
- добавить entry point для account deletion.

Файлы:

- `Ponchi/Views/Screens/ProfileViews/UserView/PonchiProfileView.swift`
- `Ponchi/ViewModels/UserViewModel.swift`

### 2. Переделать экран заказов

Проблемы:

- локальный data source;
- нет пустого состояния под реальный серверный сценарий;
- нет ETA / pickup / подробностей / retry;
- визуально экран пока слабее меню и auth.

Что сделать:

- собрать более сильную карточку заказа;
- разделить состояния `loading / empty / active / completed / error`;
- добавить `repeat order` только если бизнес-логика готова;
- вывести статус как понятный визуальный chip.

Файлы:

- `Ponchi/Views/Screens/OrderViews/Orders/PonchiChequeView.swift`
- `Ponchi/Views/Screens/OrderViews/Components/OrderCellView.swift`
- `Ponchi/ViewModels/OrderViewModel.swift`

### 3. Доделать auth UX

Проблемы:

- формы не блокируются во время запроса;
- нет явного loading state;
- resend timer локальный, а не серверный;
- reset password UI отсутствует;
- ошибки показываются минимально.

Что сделать:

- ввести button disabled/loading;
- сделать единую presentation model ошибок;
- привязать resend к `retry_after`;
- добавить `forgot password`;
- аккуратно доработать copy и объяснения шагов.

Файлы:

- `Ponchi/Views/Screens/ProfileViews/Forms/LoginForm.swift`
- `Ponchi/Views/Screens/ProfileViews/Forms/SignUpForm.swift`
- `Ponchi/Views/Screens/ProfileViews/Forms/ConfirmCodeView.swift`
- `Ponchi/Views/Screens/ProfileViews/Forms/PonchiRegistrationView.swift`
- `Ponchi/ViewModels/UserViewModel.swift`

### 4. Убрать документированный, но отсутствующий search

Сейчас `README` и docs говорят о поиске, а в UI его нет.

Нужно выбрать одно:

- либо убрать search из документации и scope;
- либо реализовать реальный поиск по меню.

Для релиза я бы советовал:

- сделать простой local search по `ponchis`;
- встроить поле поиска в `PonchiMenuView`.

## P1

### 1. Адаптивность

Проблемы:

- `PonchiMenuScrollView` использует фиксированные `GridItem(.fixed(180))`;
- iPad и landscape формально поддерживаются, а UI под них системно не проверен.

Что сделать:

- выбрать portrait-only для iPhone как базовую релизную политику;
- пересчитать сетку на адаптивную ширину;
- пройтись по маленьким и большим экранам.

### 2. Accessibility pass

Что нужно минимум:

- `accessibilityLabel` для основных кнопок;
- читаемый contrast;
- крупные tap targets;
- работа с Dynamic Type там, где это не ломает бренд;
- понятные VoiceOver названия для заказа, профиля, корзины.

### 3. Причесать detail flow

Проблемы:

- комментарий не влияет на доменную модель;
- бонусный блок сейчас не интегрирован в основной сценарий;
- часть логики customizations живет прямо в detail UI.

Что сделать:

- оставить detail визуально сильным, но логически упростить;
- убрать или отложить неготовые элементы;
- сосредоточиться на надежных конфигурациях товара.

### 4. Launch и splash

Сейчас:

- есть `LaunchScreen.storyboard`;
- есть `LaunchScreenView`;
- есть legacy `SplashView` с видео.

Рекомендация:

- оставить launch статичным и минимальным;
- всю анимацию держать либо в одном runtime splash, либо совсем убрать из критического пути;
- удалить мертвый launch code после стабилизации.

## P2

### 1. Единый UI kit

- решить судьбу дублей вроде `TotalPriceButton`;
- убрать случайные `Color("brandColor")` там, где уже есть `StaticColorEx`;
- привести шрифты к одному слою доступа.

### 2. Дизайн-система релиза

Перед TestFlight полезно зафиксировать:

- primary / secondary кнопки;
- пустые состояния;
- error banners;
- карточки заказа;
- form fields;
- profile cards.

## Definition of done для UI

- главный flow выглядит цельно;
- на каждом основном экране есть понятные состояния;
- нет декоративных кнопок без поведения;
- нет сильных контрастов качества между menu/auth и profile/orders;
- пользователь не может “сломать” сценарий двойным тапом или пустым состоянием.

