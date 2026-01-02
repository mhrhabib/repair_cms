# Repair CMS — AI Agent Instructions

**Purpose:** Concise, actionable rules to help AI agents be immediately productive in this Flutter repair shop management app.

## Quick Start
```bash
flutter pub get
flutter run  # or flutter run -d <device>
flutter clean && flutter pub get  # if build issues
```

## Architecture Overview

**Data Flow:** `UI → Cubit → Repository → BaseClient → API (staging-api.repaircms.com)`

```
lib/
├── main.dart                    # App entry, MultiBlocProvider setup
├── set_up_di.dart              # GetIt DI container (single source of truth)
├── core/
│   ├── base/base_client.dart   # HTTP client with auth & emoji logging
│   ├── helpers/
│   │   ├── api_endpoints.dart  # API URLs with <id> placeholders
│   │   └── storage.dart        # GetStorage keys (token, userId, etc)
│   ├── routes/
│   │   ├── router.dart         # GoRouter definitions
│   │   └── route_names.dart    # Route constants
│   └── services/               # Socket, notifications, biometric
└── features/                   # Feature modules (auth, jobBooking, etc)
    └── [feature]/
        ├── cubits/             # State management
        ├── repository/         # Data layer
        └── models/             # Data models
```

## Critical Patterns (MUST Follow)

### 1. Dependency Injection (3-Step Registration)
All new features follow this exact sequence:

**Step 1:** Register in `lib/set_up_di.dart`
```dart
// Repositories: registerLazySingleton
_getIt.registerLazySingleton<BrandRepository>(() => BrandRepositoryImpl());

// Cubits: registerFactory (creates new instance per request)
_getIt.registerFactory<BrandCubit>(() => BrandCubit(
  brandRepository: _getIt<BrandRepository>()
));
```

**Step 2:** Provide in `lib/main.dart` `MultiBlocProvider`
```dart
BlocProvider(create: (context) => BrandCubit(
  brandRepository: SetUpDI.getIt<BrandRepository>()
)),
```

**Step 3:** Add route in `lib/core/routes/router.dart` + `route_names.dart`
```dart
// route_names.dart
static const String brands = '/brands';

// router.dart
GoRoute(path: RouteNames.brands, builder: (context, state) => BrandsScreen())
```

### 2. Cubit State Structure
**Required:** Cubits MUST use `part`/`part of` for state files.

```dart
// brand_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
part 'brand_state.dart';

class BrandCubit extends Cubit<BrandState> {
  final BrandRepository brandRepository;
  BrandCubit({required this.brandRepository}) : super(BrandInitial());
  
  Future<void> fetchBrands() async {
    emit(BrandLoading());  // Always emit Loading first
    try {
      final brands = await brandRepository.fetchBrands();
      emit(BrandLoaded(brands: brands));  // Success
    } on BrandException catch (e) {
      emit(BrandError(message: e.message));  // Typed error
    } catch (e) {
      emit(BrandError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}

// brand_state.dart
part of 'brand_cubit.dart';

abstract class BrandState extends Equatable {
  const BrandState();
  @override
  List<Object> get props => [];
}

class BrandInitial extends BrandState {}
class BrandLoading extends BrandState {}
class BrandLoaded extends BrandState {
  final List<Brand> brands;
  const BrandLoaded({required this.brands});
  @override
  List<Object> get props => [brands];
}
class BrandError extends BrandState {
  final String message;
  const BrandError({required this.message});
  @override
  List<Object> get props => [message];
}
```

**State Emission Order:** Loading → Success/Error (UI expects this sequence)

### 3. Repository Pattern
**New features:** Use interface + implementation pattern.
```dart
// Abstract interface
abstract class BrandRepository {
  Future<List<Brand>> fetchBrands();
}

// Implementation with domain exception
class BrandException implements Exception {
  final String message;
  final int? statusCode;
  BrandException({required this.message, this.statusCode});
  @override
  String toString() => 'BrandException: $message';
}

class BrandRepositoryImpl implements BrandRepository {
  @override
  Future<List<Brand>> fetchBrands() async {
    debugPrint('🚀 [BrandRepository] Fetching brands');
    try {
      final url = ApiEndpoints.brandsListUrl.replaceAll('<id>', userId);
      final response = await BaseClient.get(url: url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return (data as List).map((e) => Brand.fromJson(e)).toList();
      }
      throw BrandException(
        message: 'Failed to load brands',
        statusCode: response.statusCode
      );
    } catch (e) {
      throw BrandException(message: e.toString());
    }
  }
}
```

**Legacy repositories (DO NOT refactor without approval):**
- `AuthRepository`, `ProfileRepository`, `JobRepository`, `QuickTaskRepository`, `DashboardRepository` — these use concrete classes without interfaces.

### 4. HTTP & API Integration
**BaseClient** (`lib/core/base/base_client.dart`):
- Auto-attaches `Authorization: Bearer <token>` from GetStorage
- Logs all requests with emoji prefixes (🚀, ✅, ❌, 🌐) via custom `LoggingInterceptor`
- Returns raw `Response` — repositories must parse JSON

**API Endpoints** (`lib/core/helpers/api_endpoints.dart`):
- Contains placeholders: `<id>`, `<userId>`, `<jobId>`, `<brandId>`
- **Always replace before calling:**
  ```dart
  final url = ApiEndpoints.getJobById.replaceAll('<id>', jobId);
  ```
- Base URL: `https://staging-api.repaircms.com`

**Response Handling:**
- Repositories parse JSON: `jsonDecode(response.data)`
- Handle both `Map` (single object) and `List` (array) responses
- Check status codes explicitly:
  ```dart
  if (response.statusCode == 200) { /* success */ }
  else { throw CustomException(...); }
  ```

### 5. Models & Storage
**Models:** Manual `fromJson`/`toJson` (NO code generation).
- Map MongoDB `_id` to Dart `sId`:
  ```dart
  class Brand {
    final String? sId;
    Brand({this.sId});
    
    factory Brand.fromJson(Map<String, dynamic> json) => Brand(
      sId: json['_id'] as String?,
    );
    
    Map<String, dynamic> toJson() => {'_id': sId};
  }
  ```

**GetStorage Keys** (`lib/core/helpers/storage.dart`):
- `token`, `userId`, `email`, `fullName`, `userType`, `locationId`, `isLoggedIn`
- Access via: `GetStorage().read('token')`

### 6. Routing & Navigation
- **Routes:** `lib/core/routes/router.dart` (GoRouter)
- **Route names:** `lib/core/routes/route_names.dart`
- **Navigation:** Use `context.go()` / `context.push()` consistently
- Example:
  ```dart
  context.push(RouteNames.brands);
  ```

### 7. Logging Convention
**ALWAYS use emoji-prefixed `debugPrint`:**
- 🚀 Start of operation
- ✅ Success
- ❌ Error
- 🌐 Network request
- 📊 Response data
- 🔐 Auth/security
- 🏢 Business logic
- 💥 Unexpected error

```dart
debugPrint('🚀 [BrandRepository] Fetching brands');
debugPrint('✅ [BrandCubit] Brands loaded successfully');
debugPrint('❌ [BrandCubit] Error: ${e.message}');
```

## Platform-Specific Features

### Printing
- **Brother printers** (TD-2D, TD-4D): `brother_printer: ^0.2.6` package
- **Dymo printers:** `escp_printer: ^1.0.2` package
- Services: `lib/features/moreSettings/printerSettings/service/`
  - `BrotherPrinterService` (singleton)
  - `DymoPrinterService` (singleton)
  - `PrinterServiceFactory` for abstraction
- **Native dependencies:** Changes require `pod install` (iOS) or Gradle sync (Android)
- **Testing:** Must test on physical device/simulator — emulators may not work

### Real-Time Features
- **Socket.IO:** `lib/core/services/socket_service.dart`
  - Connects to backend with auth token
  - Joins user room on connect
  - Used for messaging & notifications
- **Local Notifications:** `lib/core/services/local_notification_service.dart`
  - Registered in `set_up_di.dart`
  - Initialized in `main.dart`

### Logging & Debugging
- **Talker:** Remote log viewer (`talker_flutter: ^4.7.1`)
- Registered as singleton in `set_up_di.dart`
- View logs: Navigate to `/logsViewer` route
- Usage: `SetUpDI.getIt<Talker>().info('Message')`

## Development Constraints

### Forbidden Practices
- ❌ NO code generation (`freezed`, `json_serializable`, `build_runner`)
- ❌ NO refactoring legacy repositories without approval
- ❌ NO changing DI registration pattern
- ❌ NO using terminal commands for file edits (use tools)

### Required Practices
- ✅ Follow 3-step DI registration
- ✅ Use `part`/`part of` for cubit states
- ✅ Emit Loading → Success/Error states
- ✅ Create custom exceptions for repositories
- ✅ Use emoji-prefixed logging
- ✅ Replace URL placeholders before API calls
- ✅ Test printer features on real devices

## Feature Addition Checklist

Adding a new feature (e.g., "Customers"):

1. **Create repository:** `lib/features/customers/repository/customer_repository.dart`
   - Interface + Impl pattern
   - Custom exception (e.g., `CustomerException`)
   - Emoji logging

2. **Create cubit:** `lib/features/customers/cubits/customer_cubit.dart` + `customer_state.dart`
   - Use `part`/`part of`
   - Inject repository via constructor
   - Emit Loading → Success/Error

3. **Register in DI:** `lib/set_up_di.dart`
   ```dart
   _getIt.registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl());
   _getIt.registerFactory<CustomerCubit>(() => CustomerCubit(
     customerRepository: _getIt<CustomerRepository>()
   ));
   ```

4. **Provide cubit:** `lib/main.dart` `MultiBlocProvider`
   ```dart
   BlocProvider(create: (context) => CustomerCubit(
     customerRepository: SetUpDI.getIt<CustomerRepository>()
   )),
   ```

5. **Add route:** 
   - `lib/core/routes/route_names.dart`: `static const String customers = '/customers';`
   - `lib/core/routes/router.dart`: `GoRoute(path: RouteNames.customers, builder: ...)`

6. **Create UI:** `lib/features/customers/screens/customer_screen.dart`
   - Use `BlocBuilder<CustomerCubit, CustomerState>` or `BlocConsumer`
   - Handle all state cases (Initial, Loading, Loaded, Error)

## Key Files Reference

**Start here for understanding:**
- `lib/set_up_di.dart` — DI registration
- `lib/main.dart` — App initialization & BlocProviders
- `lib/core/base/base_client.dart` — HTTP client
- `lib/core/helpers/api_endpoints.dart` — API URLs
- `lib/core/helpers/storage.dart` — Persistent keys
- `lib/core/routes/router.dart` — Navigation
- `lib/features/company/` — Example of new pattern (interface + impl)
- `lib/features/auth/` — Example of legacy pattern (concrete class)

**For examples:**
- Interface pattern: `lib/features/company/repository/company_repo.dart`
- Cubit structure: `lib/features/company/cubits/company_cubit.dart`
- Error handling: `lib/features/jobBooking/cubits/brands/brand_cubit.dart`

## Testing
- Unit tests: `test/cubits/` and `test/models/`
- Uses `bloc_test: ^10.0.0` and `mocktail: ^1.0.4`
- Run: `flutter test`

---

**Need clarification?** Ask about specific features (e.g., "How do I implement file upload?" or "Show me socket integration example").
