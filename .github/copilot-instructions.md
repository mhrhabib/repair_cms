# Repair CMS - AI Agent Instructions

## Project Overview
Flutter mobile app for repair shop management with job tracking, quick tasks, customer management, and printing (Brother & Dymo printers).

## Critical Architecture Patterns

### 1. Dependency Injection & Registration Flow
All services follow a **strict 3-step registration** in `lib/set_up_di.dart` → `main.dart`:

```dart
// Step 1: Register in SetUpDI.init()
_getIt.registerLazySingleton<BrandRepository>(() => BrandRepositoryImpl());
_getIt.registerFactory<BrandCubit>(() => BrandCubit(brandRepository: _getIt<BrandRepository>()));

// Step 2: Add to MultiBlocProvider in main.dart
BlocProvider(create: (context) => BrandCubit(brandRepository: SetUpDI.getIt<BrandRepository>()))

// Step 3: Routes in AppRouter.router (lib/core/routes/router.dart)
GoRoute(path: RouteNames.brands, builder: (context, state) => BrandsScreen())
```

**Rule**: Repositories are `registerLazySingleton`, cubits are `registerFactory`. Missing any step breaks DI.

### 2. State File Pattern (Part-of Declaration)
States MUST be defined in separate files using part-of:

```dart
// brand_cubit.dart
part 'brand_state.dart';
class BrandCubit extends Cubit<BrandState> { ... }

// brand_state.dart
part of 'brand_cubit.dart';
abstract class BrandState {}
 # Repair CMS — Copilot / AI Agent Instructions

 Purpose: help an AI agent become productive quickly by describing the repo's essential structure, conventions, and concrete examples.

 Quick start commands
 - `flutter pub get`
 - `flutter run`
 - `flutter clean && flutter pub get`

 Core architecture (big picture)
 - Flutter app using Bloc/Cubit state management and a single DI container (`lib/set_up_di.dart`).
 - UI layers call Cubits → Cubits call Repositories → Repositories call `BaseClient` (HTTP) → backend at `https://api.repaircms.com`.

 Dependency injection (3-step rule)
 - Register repository as `registerLazySingleton` and cubits as `registerFactory` inside `lib/set_up_di.dart`.
 - Provide the cubit via `MultiBlocProvider` in `lib/main.dart` and expose routes in `lib/core/routes/router.dart`.
   Example: register `BrandRepository` in `SetUpDI`, add `BlocProvider` for `BrandCubit`, then add `GoRoute` for the screen.

 State & file patterns (must follow)
 - Cubit file pairs: keep state in a `part` file. E.g. `brand_cubit.dart` + `brand_state.dart` (`part 'brand_state.dart';` / `part of 'brand_cubit.dart';`).
 - Always emit Loading → Success/Error states in that order.

 Repository patterns
 - New features: use an abstract repository interface + `Impl` class (e.g., `BrandRepository` + `BrandRepositoryImpl`).
 - Legacy features (auth, profile, myJobs, quickTask, dashboard) are concrete classes — don't refactor these without direction.

 HTTP & API specifics
 - `BaseClient` (`lib/core/base/base_client.dart`) injects `Authorization: Bearer <token>` from `GetStorage` and logs requests with emoji-prefixed `debugPrint`.
 - Endpoints use placeholders in `lib/core/helpers/api_endpoints.dart` (e.g., `<id>`, `<userId>`, `<brandId>`). Use `.replaceAll('<id>', value)` before calling.
 - Response handling: repo code must handle both List and Map responses (check existing repositories for examples).

 Error handling & logging
 - Repositories throw domain-specific exceptions (e.g., `BrandException`) — cubits catch and emit typed error states.
 - Logging convention: emoji prefixes (🚀, ✅, ❌, 🌐, etc.) via `debugPrint`; replicate when adding logs.

 Storage & routing
 - Persistent values in `GetStorage` (see `lib/core/helpers/storage.dart`): `token`, `userId`, `email`, `fullName`, `userType`, `locationId`, `isLoggedIn`.
 - Routes are defined in `lib/core/routes/router.dart` and names in `lib/core/routes/route_names.dart`; navigation uses `context.go()` / `context.push()`.

 Project-specific constraints
 - NO code generation: do not add `freezed` / `json_serializable` / build_runner.
 - Models are manual `fromJson`/`toJson` and map Mongo `_id` → `sId`.

 Integration points & native
 - Printing integrations (Brother/Dymo) use platform-specific packages — native Pod/Gradle changes may be required.

 Where to look for examples
 - DI: `lib/set_up_di.dart`
 - App bootstrap & providers: `lib/main.dart`
 - HTTP client & logging: `lib/core/base/base_client.dart`
 - Endpoints: `lib/core/helpers/api_endpoints.dart`
 - Routes: `lib/core/routes/router.dart`

 When you modify code
 - Follow 3-step DI: register repo, add BlocProvider, add route.
 - Preserve legacy patterns unless changing an entire feature set.

 If anything's unclear or you want more detail (examples for a specific feature), tell me which feature and I'll expand.
