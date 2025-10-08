import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:repair_cms/core/app_exports.dart';
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
