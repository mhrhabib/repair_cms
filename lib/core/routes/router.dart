import 'package:go_router/go_router.dart';
import 'package:repair_cms/core/routes/route_names.dart';
import 'package:repair_cms/features/auth/forgotPassword/set_new_password_screen.dart';
import 'package:repair_cms/features/auth/forgotPassword/verify_code_screen.dart';
import 'package:repair_cms/features/auth/get_started_screen.dart';
import 'package:repair_cms/features/auth/forgotPassword/password_forgotten_screen.dart';
import 'package:repair_cms/features/auth/signin/password_input_screen.dart';
import 'package:repair_cms/features/auth/signin/sign_in_screen.dart';
import 'package:repair_cms/features/dasboard/dashboard_screen.dart';
import 'package:repair_cms/features/home/home_screen.dart';
import 'package:repair_cms/features/splash/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(path: RouteNames.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RouteNames.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: RouteNames.dashboard, builder: (context, state) => DashboardScreen()),
      GoRoute(path: RouteNames.getStarted, builder: (context, state) => const GetStartedScreen()),
      GoRoute(path: RouteNames.signIn, builder: (context, state) => SignInScreen()),
      GoRoute(
        path: RouteNames.passwordInput,
        builder: (context, state) => PasswordInputScreen(email: state.extra as String),
      ),
      GoRoute(
        path: RouteNames.passwordForgotten,
        builder: (context, state) => PasswordForgottenScreen(email: state.extra as String),
      ),
      GoRoute(
        path: RouteNames.verifyCode,
        builder: (context, state) => VerifyCodeScreen(email: state.extra as String),
      ),
      GoRoute(
        path: RouteNames.setNewPassword,
        builder: (context, state) => SetNewPasswordScreen(email: state.extra as String),
      ),
    ],
  );
}
