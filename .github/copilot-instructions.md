# Repair CMS - AI Agent Instructions

## Project Overview
Flutter mobile app for repair shop management with job tracking, quick tasks, customer management, and printing (Brother & Dymo printers).

## Critical Architecture Patterns

### 1. Dependency Injection & Registration Flow
All services follow a **strict 3-step registration** in `lib/set_up_di.dart` → `main.dart`:

```dart
# Repair CMS — Copilot / AI Agent Instructions

Purpose: concise, practical rules to help an AI coding agent be productive in this repo.

Quick start
- `flutter pub get`
- `flutter run` (or `flutter run -d <device>`)
- `flutter clean && flutter pub get`

Big picture
- Flutter mobile app using Bloc/Cubit for state; single DI container (`lib/set_up_di.dart`).
- Data flow: UI → `Cubit` → `Repository` → `BaseClient` (HTTP) → backend (api.repaircms.com).

Critical patterns (must follow)
- Dependency Injection (3-step):
  1. Register repository/cubit in `lib/set_up_di.dart` (`registerLazySingleton` for repos, `registerFactory` for cubits).
  2. Provide cubit in `lib/main.dart` via `MultiBlocProvider`.
  3. Add route in `lib/core/routes/router.dart` using `RouteNames`.
  Example: `_getIt.registerLazySingleton<BrandRepository>(() => BrandRepositoryImpl());`

- State files: cubits must `part` a separate state file (`my_cubit.dart` + `my_cubit_state.dart` with `part` / `part of`).
  Emit: Loading → Success/Error (consistent ordering expected by UI).

- Repositories: new features use interface + Impl (`FooRepository` + `FooRepositoryImpl`). Legacy concrete classes exist (auth, profile, myJobs, quickTask, dashboard) — do not refactor without direction.

HTTP / API specifics
- `BaseClient` (`lib/core/base/base_client.dart`) attaches `Authorization: Bearer <token>` from `GetStorage` and logs requests using emoji-prefixed `debugPrint`.
- Endpoints are defined in `lib/core/helpers/api_endpoints.dart` and contain placeholders like `<id>` / `<userId>`; replace with `.replaceAll('<id>', value)` before calling.
- Repositories must handle Map and List responses (see examples in `lib/core/repositories`).

Models & storage
- Manual `fromJson`/`toJson` models; map Mongo `_id` → `sId` (follow existing model implementations).
- Persistent keys (GetStorage) include: `token`, `userId`, `email`, `fullName`, `userType`, `locationId`, `isLoggedIn` (see `lib/core/helpers/storage.dart`).

Routing & navigation
- Routes: `lib/core/routes/router.dart`; names: `lib/core/routes/route_names.dart`.
- Use `context.go()` / `context.push()` consistently.

Platform / native notes
- Printing integrations (Brother / Dymo) use native plugins — changes may require Pod/Gradle updates. Test native flows on device/simulator.

Constraints & conventions
- NO code generation: do not add `freezed`, `json_serializable`, or run `build_runner`.
- Logging uses emoji prefixes (🚀, ✅, ❌, 🌐) via `debugPrint` — follow this for consistency.

Adding a new feature (checklist)
1. Create repository interface + Impl.
2. Register in `lib/set_up_di.dart` (`registerLazySingleton`/`registerFactory`).
3. Provide the cubit in `lib/main.dart` `MultiBlocProvider`.
4. Add route in `lib/core/routes/router.dart` and `RouteNames`.
5. Implement UI screen and wire to cubit.

Files to inspect first
- `lib/set_up_di.dart`, `lib/main.dart`, `lib/core/base/base_client.dart`, `lib/core/helpers/api_endpoints.dart`, `lib/core/helpers/storage.dart`, `lib/core/routes/router.dart`, `lib/core/routes/route_names.dart`.

If something is unclear or you want examples for a specific feature, tell me which feature and I will expand or add code snippets.
 - Repositories throw domain-specific exceptions (e.g., `BrandException`) — cubits catch and emit typed error states.
