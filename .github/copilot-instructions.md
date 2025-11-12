# Repair CMS - AI Agent Instructions

## Project Overview
Flutter mobile app for repair shop management with job tracking, quick tasks, customer management, and printing capabilities (Brother & Dymo printers).

## Architecture

### State Management: BLoC Pattern
- **Cubit-based**: Use `flutter_bloc` with Cubit (not full Bloc)
- **State classes**: Define states as part-of files in `*_cubit.dart` using `part 'cubit_name_states.dart'`
- **Injection**: Register in `SetUpDI` (GetIt) - repositories as `registerLazySingleton`, cubits as `registerFactory`
- **Providers**: All cubits registered globally in `main.dart` using `MultiBlocProvider`

Example cubit structure:
```dart
class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository repository;
  ServiceCubit({required this.serviceRepository}) : super(ServiceInitial());
  // methods that emit states
}
```

### Repository Pattern with Interface Segregation
- **Convention**: Abstract interface + `*RepositoryImpl` implementation
- **Example**: `abstract class BrandRepository` + `class BrandRepositoryImpl implements BrandRepository`
- **Legacy exception**: Early features (auth, profile, jobs, quickTask, dashboard) use concrete classes without interfaces
- **HTTP Client**: All repos use `BaseClient` (Dio wrapper) from `lib/core/base/base_client.dart`

### Networking & API
- **Base client**: `BaseClient.get/post/put/patch/delete` in `lib/core/base/base_client.dart`
- **Authentication**: Bearer token stored in GetStorage, auto-injected in headers via `getBaseOptions()`
- **Logging**: `PrettyDioLogger` enabled globally with custom debug prints (🌐 GET/POST, ✅ success, ❌ errors)
- **Endpoints**: Centralized in `ApiEndpoints` class with placeholders like `<id>`, `<userId>` (replace with `.replaceAll('<id>', actualId)`)
- **Base URL**: `https://api.repaircms.com`

### Feature Structure (Feature-First Organization)
```
lib/features/<feature>/
  ├── screens/         # UI screens
  ├── widgets/         # Feature-specific widgets
  ├── cubits/          # State management (can have subfolders: brands/, service/, etc.)
  ├── repository/      # Data layer
  └── models/          # Data models with fromJson/toJson
```

### Models & Serialization
- **Manual serialization**: All models use hand-written `fromJson` and `toJson` (no code generation)
- **Nested models**: Complex responses have multiple model classes (e.g., `ServiceResponseModel` > `ServiceModel` > `AssignedItem`)
- **Null safety**: Use nullable types liberally (`String?`, `List<T>?`) and null-aware operators

## Key Conventions

### State Management
- Emit states in this order: `Loading` → `Success` or `Error`
- Reset cubit state: Implement `reset()` method that emits initial state
- Access cubits: `context.read<CubitName>()` for actions, `BlocBuilder/BlocListener` for UI reactions

### Storage
- **Token & user data**: Use `GetStorage` instance from `lib/core/helpers/storage.dart` (`final storage = GetStorage()`)
- **Stored keys**: `token`, `user`, `isLoggedIn`, `userType`, `userId`, `email`, `fullName`, `locationId`
- **Initialize**: Call `GetStorage.init()` in `main()` before `runApp()`

### Routing
- **Router**: GoRouter in `lib/core/routes/router.dart` via `AppRouter.router`
- **Navigation**: `context.go(RouteNames.screenName)` or `context.push(RouteNames.screenName, extra: data)`
- **Route names**: Centralized in `RouteNames` class (e.g., `RouteNames.signIn`)

### UI & Design
- **Screen utilities**: `ScreenUtilInit` with design size `375x812` - use `.w`, `.h`, `.sp` extensions
- **Colors**: `AppColors` class in `lib/core/constants/app_colors.dart` (primary, fontMainColor, etc.)
- **Typography**: `AppTypography` with Google Fonts (SF Pro Text family)
- **Exports**: Use `lib/core/app_exports.dart` for common imports (Material, Bloc, GoRouter, etc.)
- **Toasts**: `showCustomToast(message, isError: true/false)` from `lib/core/helpers/show_toast.dart`

### Error Handling
- **Repository exceptions**: Catch `DioException` separately, provide user-friendly messages
- **Custom exceptions**: Create domain-specific exceptions (e.g., `BrandException`) with `message` and optional `statusCode`
- **Debugging**: Extensive `debugPrint` with emojis (🚀 start, ✅ success, ❌ error, 📊 data, 👤 user)

## Development Workflow

### Running the App
```bash
flutter pub get
flutter run
```

### Testing
- Minimal test coverage (only default `widget_test.dart`)
- No established test patterns yet

### Adding a New Feature
1. Create feature folder in `lib/features/`
2. Define models with `fromJson/toJson` in `models/`
3. Create abstract repository interface + implementation in `repository/`
4. Build cubit with states file in `cubits/`
5. Register repository (lazy singleton) and cubit (factory) in `SetUpDI.init()`
6. Add cubit to `MultiBlocProvider` in `main.dart`
7. Add routes to `AppRouter.router`
8. Build screens and widgets

### API Integration Pattern
```dart
Future<ModelType> fetchData() async {
  dio.Response response = await BaseClient.get(
    url: ApiEndpoints.endpoint.replaceAll('<id>', userId)
  );
  if (response.statusCode == 200) {
    return ModelType.fromJson(response.data);
  } else {
    throw Exception('Failed: ${response.statusCode}');
  }
}
```

## Important Notes
- **Printer integration**: Uses `another_brother` for Brother printers, `escp_printer` for Dymo
- **File uploads**: Special endpoints for avatars and job files (see `ApiEndpoints`)
- **Biometric auth**: Services in `lib/core/services/` for local auth and secure storage
- **Date picker**: Syncfusion datepicker (`syncfusion_flutter_datepicker`)
- **PDF generation**: `pdf` + `printing` packages available
