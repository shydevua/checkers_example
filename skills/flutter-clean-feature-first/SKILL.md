---
name: "flutter-clean-feature-first"
description: "Use for any work on Vlad's Flutter app: feature-first strict Clean Architecture, bloc, get_it+injectable, go_router, typed exceptions, smooth-UI rules, mocktail/bloc_test and dart_mutant."
---

# Flutter: feature-first strict Clean Architecture

This skill is the single source of truth for building and changing this project.
Follow it for every task: new feature, change, bug fix, refactor, test, review.
If a request conflicts with a rule here, say so and ask before breaking the rule.

## 1. Stack (fixed — do not substitute)

| Concern | Choice |
|---|---|
| Repo layout | Dart **pub workspaces** (root `pubspec.yaml` with `workspace:`; members use `resolution: workspace`) |
| SDK | Dart `^3.11.0` (required by dart_mutant), matching Flutter stable |
| State | `bloc`, `flutter_bloc`, `bloc_concurrency` |
| Equality | `equatable` (no `freezed` in domain — domain has zero codegen) |
| Errors | standard `try` / `on X catch` + own typed exceptions (no Result/Either types, no dartz / fpdart) |
| DI | `get_it` + `injectable` (+ `injectable_generator`), micro-packages |
| Network | `dio` + `retrofit` (+ `retrofit_generator`), `json_serializable` for DTOs |
| Navigation | `go_router` |
| Lints | `very_good_analysis` |
| Tests | `test` / `flutter_test`, `mocktail`, `bloc_test` |
| Mutation testing | `dart_mutant` (global tool: `dart pub global activate dart_mutant`) |

Use the latest stable versions from pub.dev; never pin from memory.

## 2. Repository structure

Each feature is a vertical slice (feature-first) made of **three packages**, one per layer.
Shared code lives in **one** package `core`, split into folders with three public entry points.

```
<repo>/
  pubspec.yaml                 # workspace root (lists every member)
  analysis_options.yaml        # include: package:very_good_analysis/analysis_options.yaml
  app/                         # Flutter app = the ONLY composition root
    lib/
      main_dev.dart, main_prod.dart
      di/injection.dart        # @InjectableInit + generated injection.config.dart
      router/app_router.dart   # composes feature routes
      observers/app_bloc_observer.dart
      app.dart                 # MaterialApp.router, theme from core
  core/                        # package `core`
    lib/
      domain.dart              # entry point: pure Dart only (exports src/domain)
      data.dart                # entry point: infrastructure (exports src/data)
      ui.dart                  # entry point: Flutter UI (exports src/ui)
      src/
        domain/                # AppException, UseCase, StreamUseCase, NoParams
        data/                  # network/ (Dio factory, interceptors), storage/, config/
        ui/                    # theme/, widgets/ (design system), navigation/app_paths.dart, l10n/
        di/                    # @module + @InjectableInit.microPackage() for core
  features/
    <feature>/
      domain/        -> package <feature>_domain        (pure Dart)
      data/          -> package <feature>_data          (Dart; Flutter only if a plugin forces it)
      presentation/  -> package <feature>_presentation  (Flutter)
```

Inside each feature package, public API goes through one barrel `lib/<package>.dart`; everything else is in `lib/src/`.

```
<feature>_domain/lib/src/
  entities/        # immutable business objects (Equatable, final class)
  value_objects/   # validated wrappers (Email, Money...): factory constructor validates and throws
  exceptions/      # sealed <Feature>Exception hierarchy
  repositories/    # abstract interface classes ONLY
  usecases/        # one class per use case, single call()

<feature>_data/lib/src/
  dto/             # @JsonSerializable DTOs (+ .g.dart)
  datasources/     # remote/ (retrofit APIs), local/
  mappers/         # DTO <-> entity
  repositories/    # <X>RepositoryImpl implements domain interface, translates exceptions
  di/              # @module for APIs + @InjectableInit.microPackage()

<feature>_presentation/lib/src/
  bloc/<screen>/   # <screen>_bloc.dart, <screen>_event.dart, <screen>_state.dart (separate libraries, no `part`)
  pages/           # one file per route: the page widget only (and its State)
    widgets/       # every other widget of the feature: one public widget class per file
  routes/          # <feature>_routes.dart: List<RouteBase>
  di/              # @module registering use cases + @InjectableInit.microPackage()
```

Tests mirror `lib/` exactly: `lib/src/usecases/sign_in.dart` -> `test/src/usecases/sign_in_test.dart`.
This is required: dart_mutant finds a file's tests by this path, and a mutated file with no test fails the run.

## 3. Dependency Rule (hard)

### Between packages

| Package | pubspec may list | Imports allowed from `core` | Must NOT depend on |
|---|---|---|---|
| `core` | flutter, dio, equatable, meta, injectable, get_it, go_router | — | any feature |
| `<f>_domain` | `core`, `equatable`, `meta` (**never** flutter) | `package:core/domain.dart` only | Flutter, dio, json, injectable, get_it, any data/presentation, any other feature |
| `<f>_data` | `<f>_domain`, `core`, dio, retrofit, json_annotation, injectable | `domain.dart`, `data.dart` | `<f>_presentation`, Flutter UI, other features |
| `<f>_presentation` | `<f>_domain`, `core`, flutter_bloc, go_router, injectable, get_it | `domain.dart`, `ui.dart` | `<f>_data`, other features |
| `app` | everything | everything | — |

### Inside `core`

- `src/domain/` imports only `dart:core`/`dart:async`/`dart:collection`, `equatable`, `meta`. Never `src/data`, `src/ui`, Flutter, dio.
- `src/data/` may import `src/domain/`; never `src/ui/` or Flutter widgets.
- `src/ui/` may import `src/domain/`; never `src/data/`.
- Nobody outside `core` imports `package:core/src/...` (the `implementation_imports` lint must stay on).

Why this matters: `core` depends on Flutter, so the compiler alone no longer keeps domain pure. The import rules
and the checks below are what keep it pure. Treat a violation as a build failure.

### General rules

- Features never import other features. Shared business concepts go to `core/lib/src/domain/`.
- Cross-feature navigation uses path constants in `core` (`AppPaths`, exported from `ui.dart`), never a feature import.
- Presentation talks to use cases only. It never sees repository impls, DTOs, Dio or data sources.
- Every operation the UI needs goes through a use case, even a pass-through one.

Boundary check (run before finishing any task; every command must print nothing):
```bash
grep -ln "sdk: flutter" features/*/domain/pubspec.yaml
grep -rn "package:flutter\|package:dio\|package:core/data.dart\|package:core/ui.dart" features/*/domain/lib
grep -rn "package:core/ui.dart\|package:flutter/widgets\|package:flutter/material" features/*/data/lib
grep -rn "package:core/data.dart\|package:dio\|DioException" features/*/presentation/lib
grep -rln "_data:" features/*/presentation/pubspec.yaml
grep -rn "src/data/\|src/ui/\|package:flutter\|package:dio" core/lib/src/domain
grep -rn "src/ui/" core/lib/src/data
grep -rn "src/data/" core/lib/src/ui
grep -rn "package:core/src/" features app
```
Also check that no feature's pubspec lists another feature's package.

## 4. Class modifiers (important for mocking)

- Entities, value objects, DTOs, exceptions, events, states: `final class` (or `sealed` for hierarchies).
- Anything mocked in tests — **use cases, blocs/cubits, data sources, APIs** — plain `class` or `abstract interface class`.
  `final`/`base` classes cannot be `implements`-ed from the test library, so mocktail mocks would not compile.
- Repositories in domain: `abstract interface class`.

## 5. Error handling (hard rules)

The model: **each layer throws its own typed exceptions; boundaries translate; only the layer that can react catches.**

| Layer | Throws | Catches |
|---|---|---|
| data sources / APIs | raw infrastructure exceptions (`DioException`, `CheckedFromJsonException`, plugin exceptions) | nothing |
| mappers | domain exceptions (e.g. payload violates a value object -> `<F>UnknownException`) | domain validation exceptions they trigger themselves |
| repository impls | **only** `<F>Exception` subtypes | every infrastructure exception, translated via `Error.throwWithStackTrace` |
| value objects / use cases | `<F>Exception` subtypes | nothing (they let repository exceptions propagate) |
| blocs | nothing on purpose | `on <F>Exception catch (e)` -> error state; everything else propagates |
| app | — | global handlers: `Bloc.observer.onError`, `FlutterError.onError`, `PlatformDispatcher.instance.onError` (log/crash report) |

Rules:
- All custom exceptions extend `AppException` from `package:core/domain.dart`, are `const`, `Equatable` and named `...Exception`.
- Each feature has one `sealed class <F>Exception extends AppException` with `final class` subtypes in the same library,
  so UI code can `switch` exhaustively.
- Infrastructure exceptions never leave the data package. Data-only exceptions (e.g. `CacheMissException`) also stay in data.
- Translate with `Error.throwWithStackTrace(mapped, stackTrace)` to keep the original stack trace.
- Re-throw unchanged with `rethrow`, never `throw e`.
- Always catch a specific type: `on DioException catch (e, st)`. Bare `catch (e)`, `on Object`, `on Exception` are forbidden
  outside the global handlers in `app`.
- Never catch `Error` subclasses (`TypeError`, `StateError`, `ArgumentError`...): they are bugs and must crash loudly in dev and reach crash reporting in prod.
- Never swallow: every `catch` either emits a state, throws a translated exception, or `rethrow`s.
- Every public method that can throw documents it: `/// Throws [InvalidEmailException] if ...`. This doc is the contract.
- Programmer errors (wrong arguments from our own code) use `ArgumentError` / `StateError` / `assert`, not `AppException`.

## 6. Core building blocks (`core/lib/src/domain`, exported by `package:core/domain.dart`)

```dart
// src/domain/exceptions/app_exception.dart
abstract class AppException extends Equatable implements Exception {
  const AppException();
  @override
  List<Object?> get props => [];
}

// src/domain/usecases/use_case.dart
abstract interface class UseCase<T, P> {
  Future<T> call(P params);
}

abstract interface class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

final class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
```

`package:core/data.dart` exports the Dio factory, interceptors, storage wrappers and env config.
`package:core/ui.dart` exports theme, design-system widgets, `AppPaths`, l10n helpers.
`core/lib/src/di/` holds `@module` classes for Dio etc. and `@InjectableInit.microPackage()` (generates `CorePackageModule`).

## 7. Domain layer (`<f>_domain`)

```dart
import 'package:core/domain.dart';

// exceptions/auth_exception.dart
sealed class AuthException extends AppException {
  const AuthException();
}
final class InvalidEmailException extends AuthException { const InvalidEmailException(); }
final class WeakPasswordException extends AuthException { const WeakPasswordException(); }
final class InvalidCredentialsException extends AuthException { const InvalidCredentialsException(); }
final class AuthConnectionException extends AuthException { const AuthConnectionException(); }
final class AuthUnknownException extends AuthException { const AuthUnknownException(); }

// value_objects/email.dart
final class Email extends Equatable {
  /// Throws [InvalidEmailException] if [raw] is not a valid e-mail address.
  factory Email(String raw) {
    final trimmed = raw.trim();
    if (!_pattern.hasMatch(trimmed)) throw const InvalidEmailException();
    return Email._(trimmed);
  }

  const Email._(this.value);
  final String value;

  static final _pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  List<Object?> get props => [value];
}

// entities/user.dart
final class User extends Equatable {
  const User({required this.id, required this.email, required this.name});
  final String id;
  final Email email;
  final String name;
  @override
  List<Object?> get props => [id, email, name];
}

// repositories/auth_repository.dart
abstract interface class AuthRepository {
  /// Throws [InvalidCredentialsException], [AuthConnectionException] or [AuthUnknownException].
  Future<User> signIn({required Email email, required String password});
}

// usecases/sign_in.dart
final class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

class SignIn implements UseCase<User, SignInParams> {
  const SignIn(this._repository);
  final AuthRepository _repository;

  static const minPasswordLength = 8;

  /// Throws [InvalidEmailException], [WeakPasswordException], or any [AuthException] from [AuthRepository.signIn].
  @override
  Future<User> call(SignInParams params) async {
    final email = Email(params.email);
    if (params.password.length < minPasswordLength) throw const WeakPasswordException();
    return _repository.signIn(email: email, password: params.password);
  }
}
```

Domain rules:
- Imports only `package:core/domain.dart`, `equatable`, `meta`, Dart SDK (`dart:isolate` allowed for heavy computation).
- No DI annotations, no JSON, no codegen, no `dart:io`, no Flutter. Pure business logic.
- Business rules (validation, limits, calculations) live here, in value objects and use cases — not in blocs.
- One use case = one class = one public `call`. More than one argument -> an Equatable `Params` class.
- Use cases are registered in DI by the presentation package (section 9), never annotated here.

## 8. Data layer (`<f>_data`)

```dart
import 'package:core/data.dart';
import 'package:core/domain.dart';

// dto/user_dto.dart
@JsonSerializable(createToJson: false, checked: true)
final class UserDto {
  const UserDto({required this.id, required this.email, required this.name});
  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  final String id;
  final String email;
  final String name;
}

// dto/sign_in_request_dto.dart — request DTOs are Equatable so tests can match exact arguments
@JsonSerializable(createFactory: false)
final class SignInRequestDto extends Equatable {
  const SignInRequestDto({required this.email, required this.password});
  final String email;
  final String password;
  Map<String, dynamic> toJson() => _$SignInRequestDtoToJson(this);
  @override
  List<Object?> get props => [email, password];
}

// mappers/user_mapper.dart
extension UserDtoMapper on UserDto {
  /// Throws [AuthUnknownException] if the payload violates domain rules.
  User toDomain() {
    try {
      return User(id: id, email: Email(email), name: name);
    } on InvalidEmailException catch (_, st) {
      Error.throwWithStackTrace(const AuthUnknownException(), st);
    }
  }
}

// datasources/remote/auth_api.dart
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @POST('/auth/sign-in')
  Future<UserDto> signIn(@Body() SignInRequestDto body);
}

// repositories/auth_repository_impl.dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api);
  final AuthApi _api;

  @override
  Future<User> signIn({required Email email, required String password}) async {
    final UserDto dto;
    try {
      dto = await _api.signIn(SignInRequestDto(email: email.value, password: password));
    } on DioException catch (e, st) {
      Error.throwWithStackTrace(_mapDioException(e), st);
    } on CheckedFromJsonException catch (_, st) {
      Error.throwWithStackTrace(const AuthUnknownException(), st);
    }
    return dto.toDomain();
  }

  AuthException _mapDioException(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          const AuthConnectionException(),
        DioExceptionType.badResponse when e.response?.statusCode == 401 => const InvalidCredentialsException(),
        _ => const AuthUnknownException(),
      };
}

// di/auth_data_module.dart
@module
abstract class AuthDataModule {
  @lazySingleton
  AuthApi authApi(Dio dio) => AuthApi(dio);
}

// di/auth_data_di.dart
@InjectableInit.microPackage()
void initAuthDataPackage() {}
```

Data rules:
- DTOs never leave the data package. Repositories return domain entities.
- Keep `try` blocks minimal: wrap only the call that throws infrastructure exceptions, map outside.
- Large payloads (big lists, heavy JSON) are decoded off the UI isolate with `Isolate.run` inside the repository/data source.
- Mappers are pure functions and always tested.
- Repository impls: `@LazySingleton(as: <Interface>)`. Data sources and APIs: `@lazySingleton`.

## 9. Presentation layer (`<f>_presentation`)

```dart
import 'package:core/domain.dart';
import 'package:core/ui.dart';

// bloc/sign_in/sign_in_event.dart
sealed class SignInEvent extends Equatable {
  const SignInEvent();
  @override
  List<Object?> get props => [];
}
final class SignInSubmitted extends SignInEvent {
  const SignInSubmitted({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

// bloc/sign_in/sign_in_state.dart
sealed class SignInState extends Equatable {
  const SignInState();
  @override
  List<Object?> get props => [];
}
final class SignInInitial extends SignInState { const SignInInitial(); }
final class SignInInProgress extends SignInState { const SignInInProgress(); }
final class SignInSuccess extends SignInState {
  const SignInSuccess(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}
final class SignInError extends SignInState {
  const SignInError(this.exception);
  final AuthException exception;
  @override
  List<Object?> get props => [exception];
}

// bloc/sign_in/sign_in_bloc.dart
@injectable
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc(this._signIn) : super(const SignInInitial()) {
    on<SignInSubmitted>(_onSubmitted, transformer: droppable());
  }

  final SignIn _signIn;

  Future<void> _onSubmitted(SignInSubmitted event, Emitter<SignInState> emit) async {
    emit(const SignInInProgress());
    try {
      final user = await _signIn(SignInParams(email: event.email, password: event.password));
      emit(SignInSuccess(user));
    } on AuthException catch (e) {
      emit(SignInError(e));
    }
    // Anything else is a bug: it propagates to Bloc.observer.onError.
  }
}

// pages/sign_in_page.dart — exception -> user text lives in UI (l10n)
String _message(BuildContext context, AuthException e) => switch (e) {
      InvalidEmailException() => context.l10n.invalidEmail,
      WeakPasswordException() => context.l10n.weakPassword,
      InvalidCredentialsException() => context.l10n.invalidCredentials,
      AuthConnectionException() => context.l10n.noConnection,
      AuthUnknownException() => context.l10n.somethingWentWrong,
    };

// routes/auth_routes.dart
List<RouteBase> authRoutes() => [
      GoRoute(
        path: AppPaths.signIn,
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.I<SignInBloc>(),
          child: const SignInPage(),
        ),
      ),
    ];

// di/auth_use_cases_module.dart  (keeps domain free of DI annotations)
@module
abstract class AuthUseCasesModule {
  @lazySingleton
  SignIn signIn(AuthRepository repository) => SignIn(repository);
}

// di/auth_presentation_di.dart
@InjectableInit.microPackage()
void initAuthPresentationPackage() {}
```

Presentation rules:
- Blocs depend on use cases only. No `BuildContext`, no widgets, no navigation inside a bloc.
- Blocs catch only their feature's `<F>Exception`. Never catch generic types in a bloc.
- Events and states are sealed `Equatable` hierarchies, each in its own library (no `part`).
- Error states carry the typed exception; widgets map it to text with an exhaustive `switch` (no `default`).
- Blocs are `@injectable` (factory) — never singletons. Created only in route builders through `BlocProvider`.
- `GetIt.I` is used **only** in `routes/`. Widgets receive everything via constructor or `context.read`.
- Navigation and snackbars: `BlocListener` in the page. Rendering: see section 10 for how to scope rebuilds.
- Pick a concurrency transformer for every event handler (`droppable`, `restartable`, `sequential`).
- Cubit is fine for a simple screen with no event semantics; the same rules apply.
- **A page file holds only the page.** `pages/<name>_page.dart` contains the page widget (and its `State`
  if it is stateful) — nothing else. Every other widget lives in `pages/widgets/`, **one widget per file**,
  as a public class named after its role (`GameStatusLine`, `StatsTable`, `UndoMoveButton`), file name in
  snake_case (`game_status_line.dart`). No private `_Widget` classes in a page file.
  - Helpers used by a single widget (a private enum, a formatting function) stay private in that widget's file.
  - Feature-wide helpers that are not widgets (painters, exception -> text functions) also go to
    `pages/widgets/`, one concern per file.
  - Widgets shared by several features go to `core/` (design system), never to another feature.
  - Every new widget gets a `const` constructor with `super.key`.
- **Every page builds on the shared layout** `AppPageLayout` from core (`Scaffold` + `AppBar` with title and
  actions + `SafeArea`, optional `maxContentWidth` to centre and cap the body). Feature code never builds its own
  `Scaffold` / `SafeArea`; a new kind of frame is added to core, not to a feature.

## 10. UI performance (smooth on low-end devices)

Target: no dropped frames in main flows on the **reference low-end Android device** (2–3 GB RAM, 60 Hz).
Budget: build + layout + paint under 16 ms per frame on both UI and raster threads (8 ms on 120 Hz screens).
Judge performance only in **profile mode on a real device** (`flutter run --profile` + DevTools Performance). Never in debug or on an emulator.

### 10.1 Rebuild as little as possible
- Never wrap a whole page in one `BlocBuilder`. Rebuild the smallest widget that shows the changed data.
- Use `BlocSelector` / `context.select` to subscribe to one field; use `buildWhen` / `listenWhen` on builders and listeners.
- States are `Equatable`, so equal states do not rebuild. Do not emit a new state object when nothing changed.
- Split UI into small **widget classes**, never helper methods returning `Widget` (`_buildHeader()`): classes can be `const` and rebuild independently.
  Each such class gets its own file in `pages/widgets/` (section 9).
- `const` constructors everywhere possible (`prefer_const_constructors` and friends from very_good_analysis stay on).
- Subscribe to precise inherited data: `MediaQuery.sizeOf(context)`, `MediaQuery.paddingOf(context)`, not `MediaQuery.of(context)`.
- High-frequency transient state (drag offset, scroll position, animation progress, text field draft) stays local in the widget
  (`StatefulWidget`, `ValueNotifier` + `ValueListenableBuilder`). Blocs hold business state only and never emit per frame.

```dart
class _UserName extends StatelessWidget {
  const _UserName();

  @override
  Widget build(BuildContext context) {
    final name = context.select((ProfileBloc b) => switch (b.state) {
          ProfileLoaded(:final profile) => profile.name,
          _ => '',
        });
    return Text(name);
  }
}
```

### 10.2 Keep `build` cheap and pure
- No work in `build`: no sorting, filtering, formatting, parsing, `DateFormat`/`NumberFormat` creation or object graphs.
  The bloc emits **view-ready** state (already sorted, formatted, grouped).
- Controllers (`AnimationController`, `ScrollController`, `TextEditingController`, `FocusNode`) are created in `initState`
  and disposed in `dispose`. Never in `build`.
- No `async` calls or `Future`s started from `build`.

### 10.3 Lists and scrolling
- Always lazy builders for unbounded or long lists: `ListView.builder`, `GridView.builder`, `SliverList.builder`.
- Give fixed-height items `itemExtent` or `prototypeItem`.
- Never `shrinkWrap: true` inside another scrollable and never nested scroll views of the same axis: use one `CustomScrollView` with slivers.
- List items get stable keys (`ValueKey(item.id)`).
- No `IntrinsicHeight` / `IntrinsicWidth` inside list items.
- Paginate network lists; never load thousands of items into one state.

### 10.4 Painting: avoid expensive layers
- Avoid `Opacity` for animation or static fades: use `FadeTransition` / `AnimatedOpacity`, or a color with alpha.
- Avoid `saveLayer` triggers in lists and animations: `ShaderMask`, `ColorFilter`, `BackdropFilter` (blur), `Opacity` with children.
  `BackdropFilter` is banned in scrolling content.
- Prefer `DecoratedBox` / `BoxDecoration(borderRadius: ...)` over `ClipRRect`. If you must clip, use `Clip.hardEdge`, not `antiAliasWithSaveLayer`.
- Keep `BoxShadow` blur small and few shadows per list item.
- Wrap regions that repaint often and independently (timers, progress, game board, animated pieces) in `RepaintBoundary`.
  Do not sprinkle it everywhere; verify with the DevTools repaint highlighting.

### 10.5 Animations
- Use implicit animations (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedPositioned`) or transitions (`SlideTransition`, `FadeTransition`, `ScaleTransition`).
- With `AnimatedBuilder`, pass the static subtree as `child` so only the transform rebuilds.
- Animate `transform` and `opacity`; avoid animating layout (size, padding) of large subtrees.
- Durations from the design system tokens in `core` (ui); respect `MediaQuery.disableAnimationsOf(context)`.

```dart
AnimatedBuilder(
  animation: _controller,
  child: const _ExpensiveStaticPart(),
  builder: (context, child) => Transform.rotate(angle: _controller.value * 2 * pi, child: child),
)
```

### 10.6 Heavy work off the UI isolate
- Anything that can take more than ~4 ms (large JSON decode, sorting thousands of items, image processing, game AI search)
  runs in `Isolate.run`. The layer that owns the work calls it: repository/data source for parsing, use case for domain computation.
- Arguments and results passed to isolates must be immutable plain data.

```dart
final move = await Isolate.run(() => engine.bestMove(board));
```

### 10.7 Images, fonts, startup
- Decode images at display size: `cacheWidth` / `cacheHeight` (or `ResizeImage`) computed from layout size x `MediaQuery.devicePixelRatioOf(context)`.
- `precacheImage` for images on the first visible screen.
- Ship optimized assets (WebP, correct resolution variants). Bundle fonts as assets; no runtime font downloads.
- Fast first frame: `runApp` as early as possible; only critical registrations before it. Everything else is lazy (`@lazySingleton`)
  or initialized after the first frame. Use a native splash screen.

### 10.8 Verification for UI work
- For every new or changed screen: run its main flow in profile mode on the reference device and check DevTools for jank frames
  and unexpected rebuilds (rebuild stats / "Highlight repaints").
- Report in the task summary what was checked and on which device. If no device was available, say so explicitly.

## 10A. Accessibility and semantics (hard rules)

Every screen must be fully usable with TalkBack / VoiceOver, large text and reduced motion.
Semantics are part of the feature, not polish: a screen without them is not done.

### 10A.1 Labels
- Every interactive element has an accessible name: `IconButton.tooltip`, `Image.semanticLabel`,
  `Semantics(label:)` for custom controls. Text buttons are labelled by their text.
- All labels, hints and announcements come from l10n (ARB), never hard-coded strings.
  Build composite labels with ARB placeholders (`"{square}, {content}"`), not string concatenation in widgets.
- Never convey state by colour alone: selected / disabled / "can move here" / errors are also in the label,
  in `selected:` / `enabled:` / `button:` flags, or in a hint.
- Decorative graphics are excluded: `ExcludeSemantics`, `Semantics(excludeSemantics: true)`,
  `Image(excludeFromSemantics: true)`.

### 10A.2 Custom painting and gestures
- `CustomPaint` content that the user reads or taps exposes one node per item through
  `CustomPainter.semanticsBuilder` (`CustomPainterSemantics` with `rect`, `label`, `hint`, `button`, `selected`,
  `onTap`) and implements `shouldRebuildSemantics`.
- Every labelled `SemanticsProperties` in a painter sets `textDirection` (take it from `Directionality.of(context)`);
  without it the framework asserts as soon as a screen reader is on.
- A `GestureDetector` that covers items with their own nodes sets `excludeFromSemantics: true`,
  otherwise screen readers see one unlabeled button over the whole area.
- Group related nodes in a container: `Semantics(container: true, explicitChildNodes: true, label: ...)`.

### 10A.3 Announcements
- Text that changes without user focus (whose turn, progress, results, errors) is wrapped in
  `Semantics(liveRegion: true)`. Use `SemanticsService.announce` only for events that have no visible text.
- What the user can see (e.g. the opponent's last move) is also available as text, not only as a highlight.

### 10A.4 Size, text, motion
- Tap targets at least 48x48 dp (Android) / 44x44 pt (iOS).
- Text scales: no fixed heights around text (`ConstrainedBox(minHeight:)` instead of `SizedBox(height:)`),
  layouts survive 200% text.
- Contrast: text meets WCAG AA (4.5:1, 3:1 for large text).
- Respect `MediaQuery.disableAnimationsOf(context)`: skip or shorten animations.

### 10A.5 Tests (required for every page and custom widget)
```dart
testWidgets('accessibility guidelines', (tester) async {
  final handle = tester.ensureSemantics();
  await pumpPage(tester);
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
});

testWidgets('large text (200%) -> no overflow', (tester) async {
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await pumpPage(tester);
  expect(tester.takeException(), isNull);
});
```
- Custom-painted items: assert labels with `find.semantics.byLabel('c3, white man, can move')` and drive them
  with `tester.semantics.tap(...)` — this proves a screen-reader user can complete the flow.
- Live regions: assert `liveRegion` on status texts.
- Reduced motion: a test with `MediaQueryData(disableAnimations: true)` proves no animation runs.

## 11. Dependency injection and app bootstrap

- `core` and every feature data and presentation package is an injectable **micro-package** (`@InjectableInit.microPackage()`),
  which generates `<PackageName>PackageModule` (`CorePackageModule`, `AuthDataPackageModule`, ...).
- `app/lib/di/injection.dart` is the only composition root:

```dart
final getIt = GetIt.instance;

@InjectableInit(
  externalPackageModulesBefore: [
    ExternalModule(CorePackageModule),
    ExternalModule(AuthDataPackageModule),
    ExternalModule(AuthPresentationPackageModule),
  ],
)
Future<void> configureDependencies(String environment) async => getIt.init(environment: environment);
```

```dart
// main_dev.dart — global handlers are the ONLY place allowed to catch everything
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) { /* log + crash report */ };
  PlatformDispatcher.instance.onError = (error, stack) { /* log + crash report */ return true; };
  Bloc.observer = const AppBlocObserver(); // onError -> log + crash report
  await configureDependencies(Environment.dev);
  runApp(const App());
}
```

- Environments: injectable `@dev` / `@prod` (and `@test` if needed).
- Scopes: lazy singletons for repositories, data sources, use cases; factories for blocs.
- After changing annotations or constructors, run in the affected package: `dart run build_runner build -d`.
- Never edit generated files (`*.g.dart`, `*.config.dart`, `*.module.dart`).

## 12. Testing

Unit tests never touch GetIt: construct the class under test directly and pass mocks through the constructor.

| Layer | What must be tested |
|---|---|
| domain | every use case (every throw path + happy path), every value object (valid, invalid, boundaries), entity equality |
| data | every mapper (valid + throwing), every repository impl: success + **each** infrastructure exception -> exact domain exception |
| presentation | every bloc/cubit handler with `blocTest`: success, each expected exception -> error state, unexpected error is NOT swallowed; pages with widget tests using `MockBloc` |

Rules that make tests survive mutation testing:
- Assert the **exact** exception with equality: `throwsA(const WeakPasswordException())`, not `throwsA(isA<AuthException>())`.
- For async code use `await expectLater(future, throwsA(...))`.
- Assert values, not only calls. Check the exact returned entity / emitted state list.
- Test both sides of every boundary (password length 7 -> throws, 8 -> repository called; status 401 vs 403).
- Verify exact arguments (`verify(() => repo.signIn(email: email, password: 'password1')).called(1)`).
- On throw paths verify the collaborator was **not** called (`verifyZeroInteractions` / `verifyNever`).
- In `blocTest`, `expect` lists the full state sequence including `InProgress`; use `errors:` to prove unexpected errors propagate.
- One behaviour per test; name it `<condition> -> <expected result>`. No logic in tests.

```dart
// test/src/usecases/sign_in_test.dart
class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late SignIn sut;
  final email = Email('a@b.co');
  final user = User(id: '1', email: email, name: 'Vlad');

  setUp(() {
    repository = _MockAuthRepository();
    sut = SignIn(repository);
  });

  test('invalid email -> InvalidEmailException, repository not called', () async {
    await expectLater(
      sut(const SignInParams(email: 'nope', password: 'password1')),
      throwsA(const InvalidEmailException()),
    );
    verifyZeroInteractions(repository);
  });

  test('password of 7 chars -> WeakPasswordException', () async {
    await expectLater(
      sut(const SignInParams(email: 'a@b.co', password: '1234567')),
      throwsA(const WeakPasswordException()),
    );
    verifyZeroInteractions(repository);
  });

  test('password of 8 chars -> delegates to repository and returns its user', () async {
    when(() => repository.signIn(email: email, password: '12345678')).thenAnswer((_) async => user);
    final result = await sut(const SignInParams(email: ' a@b.co ', password: '12345678'));
    expect(result, user);
    verify(() => repository.signIn(email: email, password: '12345678')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('repository throws -> same exception propagates', () async {
    when(() => repository.signIn(email: email, password: '12345678'))
        .thenThrow(const InvalidCredentialsException());
    await expectLater(
      sut(const SignInParams(email: 'a@b.co', password: '12345678')),
      throwsA(const InvalidCredentialsException()),
    );
  });
}
```

```dart
// test/src/repositories/auth_repository_impl_test.dart (fragment)
DioException _dio(DioExceptionType type, {int? status}) => DioException(
      requestOptions: RequestOptions(),
      type: type,
      response: status == null ? null : Response(requestOptions: RequestOptions(), statusCode: status),
    );

test('401 -> InvalidCredentialsException', () async {
  when(() => api.signIn(request)).thenThrow(_dio(DioExceptionType.badResponse, status: 401));
  await expectLater(sut.signIn(email: email, password: 'p'), throwsA(const InvalidCredentialsException()));
});

test('403 -> AuthUnknownException', () async {
  when(() => api.signIn(request)).thenThrow(_dio(DioExceptionType.badResponse, status: 403));
  await expectLater(sut.signIn(email: email, password: 'p'), throwsA(const AuthUnknownException()));
});
```

```dart
// test/src/bloc/sign_in/sign_in_bloc_test.dart
class _MockSignIn extends Mock implements SignIn {}

void main() {
  late _MockSignIn signIn;
  const params = SignInParams(email: 'a@b.co', password: 'password1');
  const submitted = SignInSubmitted(email: 'a@b.co', password: 'password1');

  setUp(() => signIn = _MockSignIn());

  blocTest<SignInBloc, SignInState>(
    'success -> [InProgress, Success]',
    setUp: () => when(() => signIn(params)).thenAnswer((_) async => user),
    build: () => SignInBloc(signIn),
    act: (bloc) => bloc.add(submitted),
    expect: () => [const SignInInProgress(), SignInSuccess(user)],
    verify: (_) => verify(() => signIn(params)).called(1),
  );

  blocTest<SignInBloc, SignInState>(
    'AuthException -> [InProgress, Error(exception)]',
    setUp: () => when(() => signIn(params)).thenThrow(const InvalidCredentialsException()),
    build: () => SignInBloc(signIn),
    act: (bloc) => bloc.add(submitted),
    expect: () => [const SignInInProgress(), const SignInError(InvalidCredentialsException())],
  );

  blocTest<SignInBloc, SignInState>(
    'unexpected error -> not swallowed',
    setUp: () => when(() => signIn(params)).thenThrow(StateError('bug')),
    build: () => SignInBloc(signIn),
    act: (bloc) => bloc.add(submitted),
    expect: () => [const SignInInProgress()],
    errors: () => [isA<StateError>()],
  );
}
```

Widget tests: `class _MockSignInBloc extends MockBloc<SignInEvent, SignInState> implements SignInBloc {}`,
stub with `whenListen` / `when(() => bloc.state)`, wrap the page in `BlocProvider.value`.

## 13. Mutation testing with dart_mutant

Facts about the tool (v0.2.x):
- Install once: `dart pub global activate dart_mutant`. Needs Dart 3.11+ and a resolved workspace (`dart pub get` at the root).
- Usage: `dart_mutant run [options] <file or glob>... [-- <test command>]`. Quote globs.
- Tests for `lib/a/b.dart` are found at `test/a/b_test.dart` (or `lib/a/b_test.dart`). A target file without a test fails the run.
- Default test command: `dart test` when the package's own pubspec has no Flutter SDK dependency, `flutter test --no-pub` otherwise.
  With FVM: `-- fvm flutter test --no-pub`.
- No score threshold and no exclusions: **exit code 1 if any mutant survives**. `Timeout` and `CompileError` do not fail the run.
- Useful flags: `--html <path>` (browser report), `--report <path>` (JSON, default `reports/mutation/mutation.json`), `--jobs <n>`, `--only <file>`, `--force` (ignore cached results), `--shard i/n` + `merge`.
- Unchanged results are reused between runs automatically; cache `reports/mutation/` in CI. Add `reports/` to `.gitignore`.
- No built-in "changed files only" mode: pass the changed files explicitly.

What to mutate (only files that have logic and a mirrored test; never DTOs, generated files, barrels, interfaces, exception classes, events, states, widgets):

```bash
# domain (own pubspec has no Flutter -> dart test, fast)
cd features/<f>/domain
dart_mutant run 'lib/src/usecases/**.dart' 'lib/src/value_objects/**.dart' 'lib/src/entities/**.dart' \
  --html reports/mutation/index.html
# if `dart test` cannot run here because `core` pulls Flutter into resolution, append: -- flutter test --no-pub

# data
cd features/<f>/data
dart_mutant run 'lib/src/mappers/**.dart' 'lib/src/repositories/**.dart' --html reports/mutation/index.html

# presentation (Flutter -> slower; only blocs/cubits)
cd features/<f>/presentation
dart_mutant run 'lib/src/bloc/**/*_bloc.dart' 'lib/src/bloc/**/*_cubit.dart' --html reports/mutation/index.html
```

Policy:
- Target: **zero surviving mutants** in domain, mappers, repository impls and blocs.
- For each survivor: open the HTML report, add or tighten the test that should have killed it, then re-run.
- If a survivor is an equivalent mutant (the change does not alter behaviour), simplify the production code so
  the equivalence disappears. If that is impossible, report it to Vlad explicitly in the summary; never weaken or delete tests to hide it.
- On a PR, mutate the changed `lib/src/**` files that fall under the globs above, passing them as explicit arguments.

## 14. Workflow for a new feature

1. Create the three packages under `features/<f>/` and add them to the root `workspace:` list; `dart pub get` at root.
2. Domain: exceptions -> value objects -> entities -> repository interface (with `/// Throws` docs) -> use cases. Tests alongside each file.
3. Run `dart test` and dart_mutant on domain. Reach zero survivors before moving on.
4. Data: DTOs -> API/data sources -> mappers -> repository impl (exception translation) -> DI module + micro-package init. `build_runner`. Tests. Mutation.
5. Presentation: events/states -> bloc -> page/widgets (exception -> l10n text, rebuild scoping per section 10) -> routes -> use-case DI module + micro-package init. `build_runner`. bloc tests, widget tests. Mutation on blocs.
6. App: add `ExternalModule(...)` entries to `injection.dart`, add feature routes to the router, add paths to `AppPaths` in `core/lib/src/ui/navigation/`. `build_runner` in `app`.
7. Verify: `dart format .`, `dart analyze` (zero issues), all tests green, boundary checks from section 3 clean, profile-mode check from section 10.8.

## 15. Definition of done (check before saying a task is finished)

- [ ] Dependency Rule respected; every boundary check prints nothing; no feature-to-feature imports.
- [ ] Domain imports only `package:core/domain.dart` from core; no Flutter/IO/JSON/DI imports; no codegen.
- [ ] No infrastructure exception escapes a repository; every throwing public method has `/// Throws` docs.
- [ ] No bare `catch`, `on Object`, `on Exception`, caught `Error`s or swallowed exceptions outside `app` global handlers.
- [ ] UI follows section 10: scoped rebuilds, cheap `build`, lazy lists, no expensive layers, heavy work in isolates.
- [ ] Accessibility follows section 10A: labels and hints from l10n, custom paint exposes semantics nodes, live regions for status, guideline and 200%-text tests pass.
- [ ] Every new `lib/src` file with logic has a mirrored test.
- [ ] `dart analyze` clean with `very_good_analysis`; code formatted.
- [ ] Tests green in every touched package.
- [ ] dart_mutant: zero survivors in touched domain/mapper/repository/bloc files (or survivors reported with reasons).
- [ ] Generated code regenerated, never hand-edited.
- [ ] Summary to Vlad lists packages touched, tests added, mutation results and the performance check done.

## 16. Anti-patterns (reject in review)

Architecture:
- Bloc calling a repository directly, or importing anything from `<f>_data`.
- Domain importing `package:core/data.dart`, `package:core/ui.dart`, Flutter or dio.
- Anyone importing `package:core/src/...`; `core/src/domain` importing `src/data` or `src/ui`.
- DTO, `DioException`, `CheckedFromJsonException` or `Map<String, dynamic>` reaching domain or presentation.
- `GetIt.I` / `getIt<...>()` inside widgets' `build`, blocs, use cases or repositories.
- Bloc registered as a singleton; one bloc shared between unrelated screens.
- Business validation inside a bloc or widget instead of a value object / use case.
- `final` modifier on a class that tests need to mock; `part`/`part of` for bloc events and states.

Errors:
- `catch (e)` / `on Object` / `on Exception` / catching `Error` outside the app's global handlers.
- `throw e` instead of `rethrow`; translating without `Error.throwWithStackTrace`.
- Empty catch blocks, logging-and-continuing, or returning `null` to signal an error.
- `throw Exception('message')` or throwing strings — always a typed `AppException` subtype.
- Mapping exceptions to user text inside a bloc instead of the widget layer.

Accessibility:
- Interactive element without an accessible name; state shown by colour only; hard-coded labels.
- `CustomPaint` with tappable content but no `semanticsBuilder`; painter semantics without `textDirection`.
- Full-area `GestureDetector` left in the semantics tree over items that have their own nodes.
- Status or result text that changes without `liveRegion`; fixed heights around text; ignoring disabled animations.
- A page without the guideline and large-text tests.

Structure:
- A page file with more than the page widget (private `_Widget` classes, several widgets in one file).
- A widget file with more than one public widget.
- A page building its own `Scaffold` / `SafeArea` instead of `AppPageLayout`.

UI performance:
- One `BlocBuilder` around a whole page; helper methods returning widgets instead of widget classes.
- Sorting, filtering, formatting or creating controllers inside `build`.
- `ListView(children: [...])` for long lists; `shrinkWrap: true` in nested scrollables; `IntrinsicHeight` in list items.
- `Opacity` / `ShaderMask` / `BackdropFilter` / `ClipRRect` with `antiAliasWithSaveLayer` in lists or animations.
- Bloc emitting per-frame state (drag, scroll, animation progress).
- Heavy computation or big JSON decode on the UI isolate.
- Full-resolution image decode for thumbnails.
- Performance judged in debug mode or on an emulator.

Tests:
- Tests that only `verify` calls, or assert `isA<AuthException>()` instead of the exact exception; tests with logic.
- Weakening, skipping or deleting a test to make a mutant or CI pass.