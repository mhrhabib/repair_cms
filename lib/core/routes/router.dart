import 'package:go_router/go_router.dart';
import 'package:repair_cms/core/routes/route_names.dart';
import 'package:repair_cms/features/auth/get_started_screen.dart';
import 'package:repair_cms/features/auth/signin/sign_in_screen.dart';
import 'package:repair_cms/features/splash/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(path: RouteNames.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RouteNames.getStarted, builder: (context, state) => const GetStartedScreen()),
      GoRoute(path: RouteNames.signIn, builder: (context, state) => SignInScreen()),
    ],
  );
}
