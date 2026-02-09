import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/assets_constant.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/routes/route_names.dart';
import 'package:repair_cms/features/profile/repository/profile_repository.dart';
import 'package:repair_cms/set_up_di.dart';

/// Splash screen displayed on app launch
/// Handles initial authentication check and navigation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Configuration constants
  static const Duration _splashDuration = Duration(milliseconds: 2500);
  static const Duration _animationDuration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _performStartupChecks();
  }

  /// Initialize fade and scale animations for logo
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  /// Perform startup checks and navigate to appropriate screen
  Future<void> _performStartupChecks() async {
    try {
      debugPrint('🚀 [SplashScreen] Starting app initialization');

      // Wait for minimum splash duration to show branding
      await Future.delayed(_splashDuration);

      if (!mounted) return;

      // Check authentication status
      final isAuthenticated = await _checkAuthentication();

      debugPrint(
        '✅ [SplashScreen] Auth check complete: ${isAuthenticated ? "Authenticated" : "Not authenticated"}',
      );

      // Navigate to appropriate screen
      _navigateToNextScreen(isAuthenticated);
    } catch (e, stackTrace) {
      debugPrint('❌ [SplashScreen] Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');

      // On error, navigate to get started screen for safety
      if (mounted) {
        _navigateToNextScreen(false);
      }
    }
  }

  /// Check if user is authenticated by verifying stored token and fetching profile
  Future<bool> _checkAuthentication() async {
    try {
      final token = storage.read('token');
      final userId = storage.read('userId');

      // Validate token and userId exist locally
      if (token == null || token.toString().isEmpty) {
        debugPrint('🔐 [SplashScreen] No token found');
        return false;
      }

      if (userId == null) {
        debugPrint('⚠️ [SplashScreen] Token exists but no userId found');
        return false;
      }

      debugPrint('🔐 [SplashScreen] Token found, verifying with server...');

      // Verify token validity by fetching user profile
      final profileRepository = SetUpDI.getIt<ProfileRepository>();
      await profileRepository.getProfile();

      debugPrint('🏁 [SplashScreen] Token is valid for userId: $userId');
      return true;
    } on ProfileException catch (e) {
      debugPrint(
        '❌ [SplashScreen] Profile API error: ${e.message} (Status: ${e.statusCode})',
      );

      // If unauthorized (401), clear storage as the token is no longer valid
      if (e.statusCode == 401) {
        debugPrint(
          '🚫 [SplashScreen] Token expired or invalid, clearing storage',
        );
        await _clearSession();
      }
      return false;
    } catch (e) {
      debugPrint('❌ [SplashScreen] Auth check unexpected error: $e');
      // On unexpected errors (like network issues), we might want to allow
      // the user to proceed if they have a token, but for strict security
      // we check for connectivity or return false.
      // Given the requirement "user should not go to homescreen with an invalid token",
      // we return false to be safe.
      return false;
    }
  }

  /// Clear session data from storage
  Future<void> _clearSession() async {
    try {
      await storage.remove('token');
      await storage.remove('userId');
      await storage.remove('user');
      await storage.remove('isLoggedIn');
      debugPrint('🧹 [SplashScreen] Session cleared');
    } catch (e) {
      debugPrint('❌ [SplashScreen] Error clearing session: $e');
    }
  }

  /// Navigate to the next screen based on authentication status
  void _navigateToNextScreen(bool isAuthenticated) {
    if (!mounted) return;

    if (isAuthenticated) {
      debugPrint('🏠 [SplashScreen] Navigating to home screen');
      context.go(RouteNames.home);
    } else {
      debugPrint('👋 [SplashScreen] Navigating to get started screen');
      context.go(RouteNames.getStarted);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(scale: _scaleAnimation, child: child),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Image.asset(
                  AssetsConstant.mainLogo,
                  width: 200.w,
                  height: 200.h,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('❌ [SplashScreen] Logo load error: $error');
                    return Icon(
                      Icons.business_center,
                      size: 200.w,
                      color: AppColors.primary,
                    );
                  },
                ),
                SizedBox(height: 24.h),

                // Loading indicator
                SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Loading text
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.deviderColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
