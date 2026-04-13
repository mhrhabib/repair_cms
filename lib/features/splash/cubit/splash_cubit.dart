import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/services/firebase_notification_service.dart';
import 'package:repair_cms/features/profile/repository/profile_repository.dart';
import 'package:repair_cms/features/splash/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final ProfileRepository _profileRepository;

  SplashCubit({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(SplashInitial());

  Future<void> initializeApp() async {
    if (isClosed) return;
    emit(SplashLoading());

    final startTime = DateTime.now();

    try {
      // 1. Check Connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (isClosed) return;

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Allow proceeding even if offline if we have stored data.
      }

      // 2. Check Authentication
      final isAuthenticated = await _checkAuthStatus();
      if (isClosed) return;

      // 3. Ensure minimum splash time for branding
      final elapsedTime = DateTime.now().difference(startTime);
      const minDisplayTime = Duration(seconds: 2);

      if (elapsedTime < minDisplayTime) {
        await Future.delayed(minDisplayTime - elapsedTime);
      }

      if (isClosed) return;

      if (isAuthenticated) {
        emit(SplashAuthenticated());
      } else {
        emit(SplashUnauthenticated());
      }
    } catch (e) {
      if (!isClosed) emit(SplashUnauthenticated());
    }
  }

  Future<bool> _checkAuthStatus() async {
    try {
      final token = storage.read('token');
      final userId = storage.read('userId');

      if (token == null || token.toString().isEmpty || userId == null) {
        return false;
      }

      // Verify token with server
      await _profileRepository.getProfile();

      // Trigger FCM token sync if authenticated
      await FirebaseNotificationService().syncToken();

      return true;
    } on ProfileException catch (e) {
      if (e.statusCode == 401) {
        await _clearSession();
      }
      return false;
    } catch (e) {
      // On network errors, we might want to allow offline access if we have valid local data
      // For now, following the safety-first approach
      return false;
    }
  }

  Future<void> _clearSession() async {
    await storage.remove('token');
    await storage.remove('userId');
    await storage.remove('user');
    await storage.remove('isLoggedIn');
  }
}
