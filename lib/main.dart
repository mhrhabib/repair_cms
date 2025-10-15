import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:repair_cms/core/app_exports.dart';
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
import 'package:repair_cms/features/jobBooking/cubits/model/models_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/service/service_cubit.dart';
import 'package:repair_cms/features/jobBooking/repository/accessories_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/brand_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/contact_type_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/job_booking_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/models_repository.dart';
import 'package:repair_cms/features/jobBooking/repository/service_repository.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/repository/job_repository.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/repository/profile_repository.dart';
import 'package:repair_cms/features/quickTask/cubit/quick_task_cubit.dart';
import 'package:repair_cms/features/quickTask/repository/quick_task_repository.dart';
import 'package:repair_cms/set_up_di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await SetUpDI.instance.init();
  runApp(OKToast(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SignInCubit(repository: SetUpDI.getIt<SignInRepository>())),
        BlocProvider(create: (context) => ForgotPasswordCubit(repository: SetUpDI.getIt<ForgotPasswordRepository>())),
        BlocProvider(create: (context) => ProfileCubit(repository: SetUpDI.getIt<ProfileRepository>())),
        BlocProvider(create: (context) => JobCubit(repository: SetUpDI.getIt<JobRepository>())),
        BlocProvider(create: (context) => DashboardCubit(repository: SetUpDI.getIt<DashboardRepository>())),
        BlocProvider(create: (context) => QuickTaskCubit(SetUpDI.getIt<QuickTaskRepository>())),
        BlocProvider(create: (context) => ServiceCubit(serviceRepository: SetUpDI.getIt<ServiceRepository>())),
        BlocProvider(create: (context) => JobCreateCubit(jobRepository: SetUpDI.getIt<JobBookingRepository>())),
        BlocProvider(create: (context) => JobBookingCubit()),
        BlocProvider(create: (context) => BrandCubit(brandRepository: SetUpDI.getIt<BrandRepository>())),
        BlocProvider(create: (context) => ModelsCubit(modelsRepository: SetUpDI.getIt<ModelsRepository>())),
        BlocProvider(
          create: (context) => AccessoriesCubit(accessoriesRepository: SetUpDI.getIt<AccessoriesRepository>()),
        ),
        BlocProvider(
          create: (context) => ContactTypeCubit(contactTypeRepository: SetUpDI.getIt<ContactTypeRepository>()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Repair CMS',
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
