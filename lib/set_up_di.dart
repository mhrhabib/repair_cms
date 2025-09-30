import 'package:get_it/get_it.dart';
import 'package:repair_cms/features/auth/forgotPassword/cubit/forgot_password_cubit.dart';
import 'package:repair_cms/features/auth/forgotPassword/repo/forgot_password_repo.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/auth/signin/repo/sign_in_repository.dart';

class SetUpDI {
  static final GetIt _getIt = GetIt.instance;

  static GetIt get getIt => _getIt;

  SetUpDI._();

  static final SetUpDI _instance = SetUpDI._();

  static SetUpDI get instance => _instance;

  Future<void> init() async {
    // Register SignInRepository
    _getIt.registerLazySingleton<SignInRepository>(() => SignInRepository());

    // Register SignInCubit with the repository dependency
    _getIt.registerFactory<SignInCubit>(() => SignInCubit(repository: _getIt<SignInRepository>()));

    // You can register other repositories and cubits similarly
    _getIt.registerLazySingleton<ForgotPasswordRepository>(() => ForgotPasswordRepository());
    _getIt.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(repository: _getIt<ForgotPasswordRepository>()),
    );
  }
}
