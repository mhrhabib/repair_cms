import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/services/firebase_notification_service.dart';
import 'package:repair_cms/features/auth/signin/repo/sign_in_repository.dart';

import '../models/find_user_response_model.dart';
import '../models/login_response_model.dart';

part 'sign_in_states.dart';

class SignInCubit extends Cubit<SignInStates> {
  final SignInRepository repository;

  SignInCubit({required this.repository}) : super(SignInInitial());

  Future<void> findUserByEmail(String email) async {
    emit(SignInLoading());
    try {
      final FindUserResponseModel response = await repository.findUserByEmail(
        email,
      );

      if (response.success) {
        emit(SignInSuccess(email: email, message: response.message));
      } else {
        emit(SignInError(message: response.message));
      }
    } catch (e) {
      emit(SignInError(message: e.toString()));
    }
  }

  String userType = '';
  String userId = '';

  void saveUserTypeandId(String userType, String userId) async {
    this.userType = userType;
    this.userId = userId;
  }

  Future<void> login(String email, String password) async {
    emit(SignInLoading());
    try {
      final LoginResponseModel response = await repository.login(
        email,
        password,
      );

      if (response.success) {
        // Check for Two-Factor Authentication
        if (response.secure == true) {
          emit(
            TwoFactorRequired(
              email: email,
              message: response.message,
              twoFactorEmail: response.twoFactorEmail,
              bothEnabled: response.bothEnabled ?? false,
              appBasedAuthEnabled: response.appBasedAuthEnabled ?? false,
              emailBasedAuthEnabled: response.emailBasedAuthEnabled ?? false,
            ),
          );
          return;
        }

        await _handleLoginSuccess(email, response);
      } else {
        emit(SignInError(message: response.error ?? response.message));
      }
    } catch (e) {
      emit(SignInError(message: e.toString()));
    }
  }

  Future<void> verify2FA({
    required String email,
    required String code,
    required String authType,
  }) async {
    emit(SignInLoading());
    try {
      final LoginResponseModel response = await repository.verify2FACode(
        email: email,
        code: code,
        authType: authType,
      );

      if (response.success && response.data != null) {
        await _handleLoginSuccess(email, response);
      } else {
        emit(SignInError(message: response.error ?? response.message));
      }
    } catch (e) {
      emit(SignInError(message: e.toString()));
    }
  }

  Future<void> _handleLoginSuccess(String email, LoginResponseModel response) async {
    // Save token and user data to storage
    if (response.data != null) {
      await storage.write('token', response.data!.accessToken);
      await storage.write('user', response.data!.user.toJson());
      await storage.write('isLoggedIn', true);
      await storage.write('userType', response.data!.user.userType);
      if (response.data!.user.userType == 'Owner') {
        await storage.write('userId', response.data!.user.id);
      } else {
        await storage.write('userId', response.data!.user.ownerId);
      }
      debugPrint('🔐 User ID in: ${response.data!.user.id}');
      debugPrint('🔐 User Owner ID in: ${response.data!.user.ownerId}');
      debugPrint('🔐 User storage userId in: ${storage.read('userId')}');
      await storage.write('email', response.data!.user.email);
      await storage.write(
        'companyId',
        response.data!.user.location!.companyId,
      );
      await storage.write('fullName', response.data!.user.fullName);
      await storage.write('locationId', response.data!.user.location!.id);
      debugPrint(
        '🔐 User locationId in: ${response.data!.user.location!.id}',
      );
      saveUserTypeandId(
        response.data!.user.userType,
        response.data!.user.userType == 'Owner'
            ? response.data!.user.id
            : response.data!.user.ownerId!,
      );
      // Trigger FCM token sync after successful login
      FirebaseNotificationService().syncToken();
    }

    emit(
      LoginSuccess(
        email: email,
        message: response.message,
        user: response.data?.user,
        token: response.data?.accessToken,
      ),
    );
  }

  Future<void> resend2FAEmailOtp(String email) async {
    emit(SignInLoading());
    try {
      final bool success = await repository.resend2FAEmailOtp(email);
      if (success) {
        // We stay on the same screen, just show success. 
        // We use SignInInitial temporarily to clear loading, 
        // or we could add a ResendSuccess state if needed.
        emit(SignInInitial());
      }
    } catch (e) {
      emit(SignInError(message: e.toString()));
    }
  }

  void reset() {
    emit(SignInInitial());
  }
}
