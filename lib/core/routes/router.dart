import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/routes/route_names.dart';
import 'package:repair_cms/features/auth/forgotPassword/set_new_password_screen.dart';
import 'package:repair_cms/features/auth/forgotPassword/verify_code_screen.dart';
import 'package:repair_cms/features/auth/get_started_screen.dart';
import 'package:repair_cms/features/auth/forgotPassword/password_forgotten_screen.dart';
import 'package:repair_cms/features/auth/signin/password_input_screen.dart';
import 'package:repair_cms/features/auth/signin/sign_in_screen.dart';
import 'package:repair_cms/features/dashboard/dashboard_screen.dart';
import 'package:repair_cms/features/home/home_screen.dart';
import 'package:repair_cms/features/splash/splash_screen.dart';
import 'package:repair_cms/features/moreSettings/logs/logs_viewer_screen.dart';

class AppRouter {
  // List of public routes that don't require authentication
  static final List<String> _publicRoutes = [
    RouteNames.splash,
    RouteNames.getStarted,
    RouteNames.signIn,
    RouteNames.passwordInput,
    RouteNames.passwordForgotten,
    RouteNames.verifyCode,
    RouteNames.setNewPassword,
  ];

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final storage = GetStorage();
      final token = storage.read('token');
      final currentPath = state.matchedLocation;

      debugPrint('🔐 [RouteGuard] Checking route: $currentPath');
      debugPrint('🔐 [RouteGuard] Token present: ${token != null}');

      // Check if current route is public
      final isPublicRoute = _publicRoutes.contains(currentPath);

      // If token is null and trying to access protected route, redirect to signIn
      if (token == null && !isPublicRoute) {
        debugPrint('❌ [RouteGuard] No token found, redirecting to sign in');
        return RouteNames.signIn;
      }

      // If token exists and trying to access signIn or getStarted, redirect to home
      if (token != null && (currentPath == RouteNames.signIn || currentPath == RouteNames.getStarted)) {
        debugPrint('✅ [RouteGuard] Token found, redirecting to home');
        return RouteNames.home;
      }

      // No redirect needed
      return null;
    },
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
      GoRoute(path: RouteNames.logsViewer, builder: (context, state) => const LogsViewerScreen()),
    ],
  );
}
