import 'package:get_it/get_it.dart';
import 'package:repair_cms/features/auth/forgotPassword/cubit/forgot_password_cubit.dart';
import 'package:repair_cms/features/auth/forgotPassword/repo/forgot_password_repo.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/auth/signin/repo/sign_in_repository.dart';
import 'package:repair_cms/features/dashboard/cubits/dashboard_cubit.dart';
import 'package:repair_cms/features/dashboard/repository/dashboard_repository.dart';
import 'package:repair_cms/features/jobBooking/cubits/accessories/accessories_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/brands/brand_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/contactType/contact_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/job_create_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/jobItem/job_item_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/jobType/job_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/model/models_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/service/service_cubit.dart';
import 'package:repair_cms/features/jobBooking/repository/accessories_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/brand_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/contact_type_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/job_booking_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/job_item_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/job_type_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/models_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/service_repository.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/repository/job_repository.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/repository/profile_repository.dart';
import 'package:repair_cms/features/quickTask/cubit/quick_task_cubit.dart';
import 'package:repair_cms/features/quickTask/repository/quick_task_repository.dart';

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
    _getIt.registerFactory<SignInCubit>(
      () => SignInCubit(repository: _getIt<SignInRepository>()),
    );

    // You can register other repositories and cubits similarly
    _getIt.registerLazySingleton<ForgotPasswordRepository>(
      () => ForgotPasswordRepository(),
    );
    _getIt.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(repository: _getIt<ForgotPasswordRepository>()),
    );

    // profile repository and cubit can be registered here as well
    _getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository());
    _getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(repository: _getIt<ProfileRepository>()),
    );
    // job repository and cubit
    _getIt.registerLazySingleton<JobRepository>(() => JobRepository());
    _getIt.registerFactory<JobCubit>(
      () => JobCubit(repository: _getIt<JobRepository>()),
    );
    _getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepository(),
    );
    _getIt.registerFactory<DashboardCubit>(
      () => DashboardCubit(repository: _getIt<DashboardRepository>()),
    );

    // quick task repository and cubit
    _getIt.registerLazySingleton<QuickTaskRepository>(
      () => QuickTaskRepository(),
    );
    _getIt.registerFactory<QuickTaskCubit>(
      () => QuickTaskCubit(_getIt<QuickTaskRepository>()),
    );

    //service list repository and cubit can be registered here as well
    _getIt.registerLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImpl(),
    );
    _getIt.registerFactory<ServiceCubit>(
      () => ServiceCubit(serviceRepository: _getIt<ServiceRepository>()),
    );

    // job booking cubit
    _getIt.registerLazySingleton<JobBookingRepository>(
      () => JobBookingRepositoryImpl(),
    );
    _getIt.registerFactory<JobCreateCubit>(
      () => JobCreateCubit(jobRepository: _getIt<JobBookingRepository>()),
    );
    _getIt.registerFactory<JobBookingCubit>(() => JobBookingCubit());
    //brand repository and cubit can be registered here as well
    _getIt.registerLazySingleton<BrandRepository>(() => BrandRepositoryImpl());
    _getIt.registerFactory<BrandCubit>(
      () => BrandCubit(brandRepository: _getIt<BrandRepository>()),
    );
    //models repository and cubit can be registered here as well
    _getIt.registerLazySingleton<ModelsRepository>(
      () => ModelsRepositoryImpl(),
    );
    _getIt.registerFactory<ModelsCubit>(
      () => ModelsCubit(modelsRepository: _getIt<ModelsRepository>()),
    );
    //accessory repository and cubit can be registered here as well
    _getIt.registerLazySingleton<AccessoriesRepository>(
      () => AccessoriesRepositoryImpl(),
    );
    _getIt.registerFactory<AccessoriesCubit>(
      () => AccessoriesCubit(
        accessoriesRepository: _getIt<AccessoriesRepository>(),
      ),
    );
    //contact type repository and cubit can be registered here as well
    _getIt.registerLazySingleton<ContactTypeRepository>(
      () => ContactTypeRepositoryImpl(),
    );
    _getIt.registerFactory<ContactTypeCubit>(
      () => ContactTypeCubit(
        contactTypeRepository: _getIt<ContactTypeRepository>(),
      ),
    );
    //job type repo and cubit can be registered here as well
    _getIt.registerLazySingleton<JobTypeRepository>(
      () => JobTypeRepositoryImpl(),
    );
    _getIt.registerFactory<JobTypeCubit>(
      () => JobTypeCubit(jobTypeRepository: _getIt<JobTypeRepository>()),
    );
    //job item repo and cubit can be registered here as well
    _getIt.registerLazySingleton<JobItemRepository>(
      () => JobItemRepositoryImpl(),
    );
    _getIt.registerFactory<JobItemCubit>(
      () => JobItemCubit(_getIt<JobItemRepository>()),
    );
  }
}
