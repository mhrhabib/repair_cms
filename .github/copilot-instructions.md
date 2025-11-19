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
class BrandLoading extends BrandState {}
```

### 3. Repository Pattern Evolution
**New features (jobBooking onwards)**: Abstract interface + Impl class:
```dart
abstract class BrandRepository {
  Future<List<BrandModel>> getBrandsList({required String userId});
}
class BrandRepositoryImpl implements BrandRepository { ... }
```

**Legacy features** (auth, profile, myJobs, quickTask, dashboard): Concrete classes without interfaces. Don't refactor these without explicit request.

### 4. API Integration Critical Details
**BaseClient** in `lib/core/base/base_client.dart` auto-injects Bearer token from GetStorage:

```dart
dio.Response response = await BaseClient.get(
  url: ApiEndpoints.brandsListUrl.replaceAll('<id>', userId) // MUST use .replaceAll for placeholders
);
```

**Endpoints** in `lib/core/helpers/api_endpoints.dart` use template placeholders:
- `<id>`, `<userId>`, `<brandId>`, `<jobId>` → Replace with `.replaceAll('<id>', actualValue)`
- Base URL: `https://api.repaircms.com` (hardcoded, no env switching)

**Response handling pattern**:
```dart
if (response.statusCode == 200) {
  // Handle both List and Map responses with nested data keys
  if (response.data is List) return (response.data as List).map(...).toList();
  if (response.data is Map && data.containsKey('brands')) return (data['brands'] as List).map(...).toList();
}
```

### 5. Error Handling Architecture
Repositories throw **custom domain exceptions** (not generic Exception):

```dart
class BrandException implements Exception {
  final String message;
  final int? statusCode;
  BrandException({required this.message, this.statusCode});
}

// In repository:
} on DioException catch (e) {
  throw BrandException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
}
```

Cubits catch these and emit typed error states: `emit(BrandError(message: e.message))`

### 6. Debug Logging Convention
Use emoji-prefixed `debugPrint` (not `print`) throughout:
- 🚀 Method start
- ✅ Success
- ❌ Error
- 📊 Data/response
- 👤 User context
- 💥 Unexpected errors
- 🌐 Network calls

Example: `debugPrint('🚀 [BrandCubit] Fetching brands for user: $userId');`

## Key Technical Patterns

### State Management Flow
```dart
// In cubit methods:
emit(BrandLoading());
try {
  final data = await repository.method();
  emit(BrandLoaded(brands: data));
} on CustomException catch (e) {
  emit(BrandError(message: e.message));
}

// In UI:
context.read<BrandCubit>().getBrands(userId: userId);  // Trigger action
BlocBuilder<BrandCubit, BrandState>(builder: (context, state) { ... })
```

### Model Serialization (Manual, No Codegen)
```dart
class BrandModel {
  String? sId;  // MongoDB _id field
  String? name;
  
  BrandModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];  // Note underscore prefix
    name = json['name'];
  }
  
  Map<String, dynamic> toJson() => {'_id': sId, 'name': name};
}
```

### Storage Keys (GetStorage)
Access via `final storage = GetStorage()` from `lib/core/helpers/storage.dart`:
- `token` - JWT bearer token
- `userId`, `email`, `fullName`, `userType`, `locationId`
- `isLoggedIn` - boolean flag

Initialize in `main()`: `await GetStorage.init();` before `runApp()`

### Routing & Navigation
```dart
// Define in lib/core/routes/route_names.dart:
static const String brands = '/brands';

// Register in AppRouter.router:
GoRoute(path: RouteNames.brands, builder: (context, state) => BrandsScreen())

// Navigate:
context.go(RouteNames.brands);
context.push(RouteNames.detail, extra: brandObject);
```

## Development Workflows

### Adding a Complete Feature
1. Create `lib/features/<feature>/` with `models/`, `repository/`, `cubits/`, `screens/`, `widgets/`
2. Build model with `fromJson`/`toJson` (nullable fields, handle MongoDB `_id` → `sId`)
3. Create repository interface + impl (throw custom exceptions)
4. Build cubit with `part 'cubit_state.dart'` (emit Loading → Success/Error)
5. Register in `SetUpDI.init()` (repo lazy, cubit factory)
6. Add `BlocProvider` to `main.dart` MultiBlocProvider
7. Add routes to `AppRouter.router` and `RouteNames`
8. Build UI with `BlocBuilder`/`BlocListener`

### Common Commands
```bash
flutter pub get                    # Install dependencies
flutter run                        # Run app
flutter run --release             # Release build
flutter clean && flutter pub get  # Fix dependency issues
```

### Debugging API Issues
1. Check `BaseClient` logs in console (🌐 emoji)
2. Verify token in GetStorage: `debugPrint(storage.read('token'))`
3. Confirm endpoint placeholder replacement: `.replaceAll('<id>', value)`
4. Check response structure (List vs Map with nested keys)

## Project-Specific Conventions

**UI Design System**:
- Screen size: `ScreenUtilInit(designSize: Size(375, 812))` - use `.w`, `.h`, `.sp`
- Colors: `AppColors` in `lib/core/constants/app_colors.dart`
- Typography: `AppTypography` (SF Pro Text via Google Fonts)
- Common imports: `lib/core/app_exports.dart` barrel file

**Toasts**: `showCustomToast(message, isError: bool)` from `lib/core/helpers/show_toast.dart`

**Printer Integration**:
- Brother: `another_brother` package
- Dymo: `escp_printer` package

**File Uploads**: Use `jobFileUpload` or `uploadProfileAvatar` endpoints with userId/jobId parameters

**Date Picker**: `syncfusion_flutter_datepicker` (commercial license implied)

## Important Gotchas

1. **Never** use code generation (no `freezed`, `json_serializable`)
2. **Always** emit states in order: Loading → Success/Error (check `brand_cubit.dart` for reference)
3. **Repository registration**: Lazy singleton only (not factory) - prevents multiple HTTP client instances
4. **State preservation**: See `BrandCubit.addBrand()` for pattern of preserving state during optimistic updates
5. **Test coverage**: Minimal (only `widget_test.dart`). No TDD enforced.
6. **iOS/Android native**: Printer setup requires native configuration (see Podfile, build.gradle)
