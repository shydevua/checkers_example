# Шашки

Русские шашки против компьютера на трёх уровнях сложности. Flutter, один
пакет, feature-first Clean Architecture, bloc.

## Возможности

- Полные правила русских шашек: дамки ходят на всю диагональ, обязательное
  взятие с выбором любой цепочки, обязательное продолжение взятия, «турецкий
  удар», превращение в дамку посреди взятия.
- Ничьи: 15 ходов одними дамками без взятий, троекратное повторение
  позиции, три дамки против одной не выиграли за 15 ходов.
- Компьютер: negamax с alpha-beta, таблица транспозиций (Zobrist),
  итеративное углубление с лимитом времени; поиск идёт в `Isolate.run`.
- Выбор цвета, отмена хода, анимация хода по всему пути, ход компьютера в
  нотации (`c3-d4`, `c3:e5:g7`).
- Статистика побед, поражений и ничьих по уровням.
- Доступность: каждая клетка доски — узел для TalkBack/VoiceOver с
  названием, состоянием и действием; статус хода и результат объявляются
  (live region); учитываются крупный шрифт и отключённые анимации.
- Русский и английский интерфейс (`flutter gen-l10n`, ARB, `plural`/`select`).

| Уровень | Поиск | Случайные ходы |
|---|---|---|
| Лёгкий | 1 полуход | 50 % |
| Средний | 4 полухода | 10 % |
| Сложный | до 10 полуходов, не дольше 1,2 с | нет |

Начатые взятия всегда досчитываются до конца, поэтому даже «Лёгкий» не
отдаёт шашки под очевидный размен.

## Запуск

```bash
flutter pub get
flutter run                              # окружение dev
flutter run --dart-define=ENV=prod       # окружение prod; неизвестное ENV — ошибка при старте
```

Проверки:

```bash
flutter analyze
flutter test --exclude-tags golden       # юнит, блоки, виджеты, архитектура
flutter test --tags golden               # пиксельные снимки доски (эталоны сняты на macOS)
```

Полная партия на устройстве или симуляторе (на хосте этот тест пропускается):

```bash
flutter drive --driver=test/integration/driver.dart \
  --target=test/integration/app_test.dart -d <устройство>
```

После изменения DI или DTO: `dart run build_runner build -d`.
Строки: `lib/core/l10n/arb/app_ru.arb` (шаблон) и `app_en.arb`;
код генерируется при `flutter pub get`, `flutter run` или `flutter gen-l10n`.
Иконка и splash (`tool/` — генератор ассетов, а не тест: он только
запускается через `flutter test`, чтобы рисовать на Flutter-`Canvas`):
`flutter test tool/render_icon.dart`, затем `dart run flutter_launcher_icons`
и `dart run flutter_native_splash:create`.

## Структура

```
lib/
  main.dart                      единственная точка входа
  app/                           сборка приложения: его не импортирует никто
    bootstrap.dart, app.dart     запуск, MaterialApp.router
    di/                          ВСЕ регистрации DI (modules/), окружение
    router/                      маршруты всех фич + ScreenViewObserver
    observers/                   глобальные обработчики ошибок, BlocObserver
  core/                          общий технический код, по темам
    analytics/  monitoring/      порты Analytics и ErrorReporter, no-op реализации
    storage/                     KeyValueStorage + SharedPreferences
    exceptions/  usecases/       AppException, UseCase, NoParams
    l10n/  navigation/           строки (ARB), пути и имена экранов
    theme/  widgets/             токены дизайна, тема, AppButton
  features/
    shared/game_results/         общие бизнес-понятия фич (shared kernel, не фича):
                                 Difficulty, GameOutcome, GameResult, LevelStats,
                                 порт GameResultRecorder
    menu/presentation            выбор цвета и уровня
    game/domain, presentation    правила, ИИ, use cases, GameBloc, доска
    statistics/domain, data, presentation
test/                            повторяет lib/ файл в файл + architecture_test.dart
  integration/                   партия на устройстве (flutter drive)
  reports/                       отчёты мутационного тестирования (не в git)
tool/                            генератор иконки и splash
```

Фичи не импортируют друг друга. Игра передаёт результат партии через порт
`GameResultRecorder` из `features/shared/`; фича статистики его реализует, а
`app/di/modules/statistics_module.dart` связывает их.

### Правила импортов (проверяет `test/architecture_test.dart`)

| Папка | Может импортировать |
|---|---|
| `core/analytics`, `exceptions`, `monitoring`, `usecases` | только чистый Dart и друг друга |
| `core/storage` | плагины платформы, чистые папки core; не UI |
| `core/l10n`, `navigation`, `theme`, `widgets` | Flutter, чистые папки core; не `storage` |
| `features/shared/` | чистый Dart, `core/exceptions`, `core/usecases` |
| `features/<f>/domain` | чистый Dart, `core/exceptions`, `core/usecases`, `features/shared/`, свой домен |
| `features/<f>/data` | то же + `core/storage`, свой data; без Flutter |
| `features/<f>/presentation` | всё из core, кроме `storage`; `features/shared/`, свой домен и presentation |

Кроме того: `core` не видит фичи и `app`; фичи не видят друг друга, только `features/shared`; `injectable` — только
в `app/di`; `GetIt` — только в `routes/` и `app/di`; у каждого файла с
логикой есть зеркальный тест. Новая папка в `core` без группы роняет тест.

## Аналитика и мониторинг ошибок

`Analytics` и `ErrorReporter` — порты в `core/`. Сейчас они привязаны к
`NoopAnalytics` и `NoopErrorReporter`, всё уходит в пустоту. Чтобы
подключить продукт, добавьте адаптер рядом с портом и поменяйте одну строку
в `app/di/modules/core_module.dart`:

```dart
@lazySingleton
Analytics analytics(FirebaseAnalytics firebase) =>
    FirebaseAnalyticsAdapter(firebase);
```

События: `game_started {difficulty, color}`, `game_finished {difficulty,
outcome}`, `move_undone {difficulty}`, `stats_reset`, просмотры экранов
`home` / `game` / `statistics`. Ошибки: всё, что дошло до
`FlutterError.onError`, `PlatformDispatcher.onError` и
`Bloc.observer.onError`; обработчики ставятся до инициализации DI, поэтому
сбой при старте не теряется.

## Тестирование

- Домен, data-слой, блоки, страницы, маршруты, DI — юнит- и виджет-тесты.
- Поведение ИИ, а не его константы: глубокий поиск находит жертву с
  последующим взятием, которую пропускает поиск на один полуход;
  «Средний» выигрывает у «Лёгкого» в большинстве партий.
- Доступность на каждой странице: `meetsGuideline` (подписи, размер целей
  нажатия, контраст) и вёрстка при шрифте 200 %; ход на доске можно
  сделать через семантику, как это делает скринридер.
- Golden-снимки доски, integration-тест партии на устройстве.
- Мутационное тестирование (`dart pub global activate dart_mutant`):

```bash
dart_mutant run lib/features/shared/game_results/game_result.dart lib/features/shared/game_results/level_stats.dart \
  lib/core/analytics/analytics_event.dart lib/core/analytics/track_event.dart \
  'lib/features/*/domain/usecases/**.dart' 'lib/features/*/domain/value_objects/**.dart' \
  'lib/features/*/domain/entities/**.dart' 'lib/features/*/domain/services/**.dart' \
  'lib/features/*/data/mappers/**.dart' 'lib/features/*/data/repositories/**.dart' \
  'lib/features/*/data/datasources/**.dart' 'lib/features/*/presentation/bloc/**/*_bloc.dart' \
  --report test/reports/mutation/mutation.json --html test/reports/mutation/index.html
```

## Компромиссы и что я бы упростил в продакшене

- **Сквозные use cases** (`MakeMove`, `SaveGameResult`, `TrackEvent`)
  ничего не добавляют к логике. Они есть, потому что правило проекта —
  UI работает только через use cases. В маленьком приложении я бы
  разрешил блоку вызывать доменный сервис напрямую.
- **Порт `GameResultRecorder`** между игрой и статистикой окупается, только
  если фичи живут отдельно. Слить их в одну фичу — тоже честный вариант.
- **Мутанты отсечения alpha-beta**, таблицы транспозиций и упорядочивания
  ходов эквивалентны: они меняют скорость поиска, но не результат, поэтому
  тестами на результат их не убить.
- **Сила «Сложного»** ограничена простой оценкой позиции (материал,
  продвижение, центр, защита последнего ряда). Следующие шаги — оценка
  мобильности и структуры, база окончаний, обдумывание во время хода
  человека.
- **Нет** сетевой игры, сохранения незаконченной партии и полной записи
  партии (виден только последний ход компьютера).
- **Golden-тесты** платформозависимы, поэтому в CI они идут на macOS
  отдельно от остальных.
