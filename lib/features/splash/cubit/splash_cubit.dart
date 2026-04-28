import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      final authResult = await _checkAuthStatus();
      if (isClosed) return;

      // 3. Ensure minimum splash time for branding
      final elapsedTime = DateTime.now().difference(startTime);
      const minDisplayTime = Duration(seconds: 2);

      if (elapsedTime < minDisplayTime) {
        await Future.delayed(minDisplayTime - elapsedTime);
      }

      if (isClosed) return;

      switch (authResult) {
        case _AuthResult.authenticated:
          emit(SplashAuthenticated());
          break;
        case _AuthResult.sessionExpired:
          emit(SplashSessionExpired());
          break;
        case _AuthResult.unauthenticated:
          emit(SplashUnauthenticated());
          break;
      }
    } catch (e) {
      if (!isClosed) emit(SplashUnauthenticated());
    }
  }

  Future<_AuthResult> _checkAuthStatus() async {
    final tokenRaw = storage.read('token');
    final userIdRaw = storage.read('userId');
    final token = tokenRaw?.toString() ?? '';
    final userId = userIdRaw?.toString() ?? '';

    // No prior session → onboarding flow
    if (token.isEmpty || userId.isEmpty) {
      return _AuthResult.unauthenticated;
    }

    // Local JWT expiry check — avoids sending an unusable token to the server
    if (_isJwtExpired(token)) {
      debugPrint('🔐 [SplashCubit] Local JWT expired, clearing session');
      await _clearSession();
      return _AuthResult.sessionExpired;
    }

    try {
      // Verify token with server (catches revoked / rotated tokens). Bound the
      // wait so a slow network doesn't hang the splash indefinitely.
      await _profileRepository.getProfile().timeout(const Duration(seconds: 8));

      // Trigger FCM token sync if authenticated
      unawaited(FirebaseNotificationService().syncToken());

      return _AuthResult.authenticated;
    } on ProfileException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _clearSession();
        return _AuthResult.sessionExpired;
      }
      // Server reachable but returned a non-auth error (5xx, etc.). The local
      // JWT is still valid, so proceed optimistically — the user can continue
      // using cached state and individual API calls will surface their own
      // errors. Forcing logout here would lock users out during outages.
      debugPrint(
        '⚠️ [SplashCubit] Profile check failed with ${e.statusCode}, proceeding with valid local token',
      );
      return _AuthResult.authenticated;
    } catch (e) {
      // Timeout / network / unexpected error with a locally-valid JWT —
      // proceed so the app works offline.
      debugPrint('⚠️ [SplashCubit] Profile check error: $e — proceeding with valid local token');
      return _AuthResult.authenticated;
    }
  }

  bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      var payload = parts[1];
      switch (payload.length % 4) {
        case 1:
          payload += '===';
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = json['exp'];
      if (exp is! int) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  Future<void> _clearSession() async {
    await storage.remove('token');
    await storage.remove('userId');
    await storage.remove('user');
    await storage.remove('isLoggedIn');
    await storage.remove('userType');
    await storage.remove('companyId');
    await storage.remove('fullName');
    await storage.remove('locationId');
  }
}

enum _AuthResult { authenticated, sessionExpired, unauthenticated }
