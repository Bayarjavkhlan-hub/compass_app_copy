# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A copy of the Flutter team's **Compass** sample app (trip itinerary builder/booking), taken from `flutter/samples` as the base for a **Maestro** (mobile UI testing) proof of concept. The Flutter project lives in `app/`; all Flutter commands run from there.

### Differences from upstream

The app was taken from `flutter/samples` `main` and changed to build standalone on **stable** Flutter (3.44 / Dart 3.12): it no longer uses the pub workspace (`resolution: workspace` and `analysis_defaults` were removed), the SDK constraint is `^3.9.0`, and imports use `package:flutter/material.dart` / `cupertino.dart` instead of the unreleased `material_ui` / `cupertino_ui` packages. Don't reintroduce those packages when pulling code from upstream.

The companion Dart server (`compass_app/server`) was **not** copied. The staging flavor and `integration_test/app_server_data_test.dart` (which runs `dart run bin/compass_server.dart` in `../server` on port 8080) won't work without it. Use the development flavor (local data) for Maestro.

## Commands (run from `app/`)

```bash
flutter pub get
flutter run --target lib/main_development.dart   # local JSON data, always logged in (lib/main.dart defaults to this)
flutter run --target lib/main_staging.dart       # remote HTTP server on :8080 (server not in this repo)

flutter analyze
flutter test                                     # unit + widget tests in test/
flutter test test/ui/booking/booking_screen_test.dart          # single file
flutter test test/utils/command_test.dart --plain-name "should" # filter by test name

# Integration tests: run each file on its own. `flutter test integration_test` (both together) fails, see flutter/flutter#101031
flutter test integration_test/app_local_data_test.dart

# Regenerate freezed / json_serializable code after editing annotated models
dart run build_runner build --delete-conflicting-outputs
```

The generated `*.freezed.dart` and `*.g.dart` files are committed. Don't edit them by hand.

## Architecture

This sample shows the layered MVVM architecture Flutter recommends. A feature normally touches every layer:

- **`lib/data/services/`**: raw data sources. `ApiClient` and `AuthApiClient` (HTTP to the server, with API models in `services/api/model/`), `LocalDataService` (reads `assets/*.json`) and `SharedPreferencesService`.
- **`lib/data/repositories/<name>/`**: one abstract `XRepository` per domain area, with interchangeable implementations: `*_local.dart` / `*_dev.dart` (local data) and `*_remote.dart` (API). Repositories turn API models into domain models.
- **`lib/domain/models/`**: immutable freezed domain models. **`lib/domain/use_cases/`** holds logic that spans several repositories (booking create/share).
- **`lib/ui/<feature>/view_models/` + `widgets/`**: each screen gets a `ChangeNotifier` ViewModel through its constructor. Shared widgets, theme and localization live in `lib/ui/core/`.

Patterns that span files:

- **Environment selection by DI.** `lib/config/dependencies.dart` defines `providersLocal` and `providersRemote` (lists of `provider` providers that bind abstract repositories to concrete ones). `main_development.dart` and `main_staging.dart` differ only in which list they pass to `MultiProvider`. To add a repository, register it in **both** lists.
- **ViewModels are built in the router.** `lib/routing/router.dart` creates each ViewModel in its `GoRoute` builder from `context.read()`, and sometimes triggers an initial load there (e.g. `BookingViewModel.createBooking.execute()`). ViewModels aren't providers. `AuthRepository` is a `ChangeNotifier` used as the router's `refreshListenable`, and `_redirect` sends unauthenticated users to `/login`. Route paths are in `routing/routes.dart`.
- **`Result<T>`** (`lib/utils/result.dart`): a sealed `Ok`/`Error` type that repositories, use cases and commands return in place of throwing. Consume it with an exhaustive `switch`.
- **`Command0` / `Command1`** (`lib/utils/command.dart`): ViewModel actions are wrapped in Commands, which expose `running`, `error` and `completed`, block re-entry, and notify listeners. Widgets listen to the command (e.g. `ListenableBuilder`) for loading and error UI, then call `clearResult()`.
- **`ItineraryConfigRepository`** (in-memory) carries the in-progress trip (continent, dates, guests, destination, activities) between the search → results → activities → booking screens.

## Testing

- `app/testing/` holds the shared test support code (outside `test/` so integration tests can use it too): fake repositories and services (`testing/fakes/`), fixture models (`testing/models/`), mocktail mocks (`testing/mocks.dart`), and `testApp()` (`testing/app.dart`), which pumps a widget inside a themed, localized `MaterialApp` with a mock `GoRouter` and mocked network images.
- The usual pattern is to build a real ViewModel on top of fake repositories and pump the screen with `testApp`.
- Integration tests find widgets by type and by `Key`s defined in the UI widgets. Maestro uses `TestIds` instead (see below).

## Maestro (`.maestro/` at repo root)

The Maestro flows are the PoC's main deliverable. See [.maestro/README.md](.maestro/README.md) for how to run them and for the known gotchas.

- Selectors use `TestIds` (`app/lib/ui/core/ui/test_ids.dart`), applied as `Semantics(container: true, identifier: ...)`. New interactive UI that the flows need should get an ID there. Never use Flutter `Key`s for this, because Maestro can't see them.
- Android `applicationId` was changed to `com.example.compassApp` to match the iOS bundle ID, so flows use a single `appId`. The Kotlin `namespace` is still `com.example.compass_app`.
- `HomeScreenContainer.didUpdateWidget` reloads bookings when the home route is rebuilt. This fixes an upstream bug, caught by flow 03, where a new booking didn't appear on home.
- Local emulator on this machine: the AVD hangs as "offline" unless it's started with `-gpu swiftshader_indirect` (hybrid NVIDIA/Intel GPU).

## Lints

`app/analysis_options.yaml` adds `prefer_relative_imports` (use relative imports inside `lib/`), `directives_ordering`, `combinators_ordering`, `omit_local_variable_types` and `prefer_final_locals`/`fields`/`in_for_each`. Files carry the Flutter BSD license header.
