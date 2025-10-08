import 'package:get_it/get_it.dart';
import 'package:repair_cms/features/auth/forgotPassword/cubit/forgot_password_cubit.dart';
import 'package:repair_cms/features/auth/forgotPassword/repo/forgot_password_repo.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/auth/signin/repo/sign_in_repository.dart';
import 'package:repair_cms/features/dashboard/cubits/dashboard_cubit.dart';
import 'package:repair_cms/features/dashboard/repository/dashboard_repository.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/repository/job_repository.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/repository/profile_repository.dart';

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

    // profile repository and cubit can be registered here as well
    _getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository());
    _getIt.registerFactory<ProfileCubit>(() => ProfileCubit(repository: _getIt<ProfileRepository>()));
    // job repository and cubit
    _getIt.registerLazySingleton<JobRepository>(() => JobRepository());
    _getIt.registerFactory<JobCubit>(() => JobCubit(repository: _getIt<JobRepository>()));
    _getIt.registerLazySingleton<DashboardRepository>(() => DashboardRepository());
    _getIt.registerFactory<DashboardCubit>(() => DashboardCubit(repository: _getIt<DashboardRepository>()));
  }
}
