import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  void updateOtp(String otp) {
    emit(ForgotPasswordOtpState(otp));
  }

  Future<void> sendResetEmail(String email) async {
    try {
      emit(ForgotPasswordLoading());
      await Future.delayed(const Duration(seconds: 2));

      // Simulate email validation
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(email)) {
        emit(const ForgotPasswordError('Please enter a valid email address'));
        return;
      }

      emit(ForgotPasswordEmailSent(email));
    } catch (e) {
      emit(ForgotPasswordError('Failed to send reset email: ${e.toString()}'));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      emit(ForgotPasswordLoading());
      await Future.delayed(const Duration(seconds: 2));

      // Simulate OTP validation (in real app, this would verify with backend)
      if (otp.length == 4 && otp == '1234') {
        // Example valid OTP
        emit(ForgotPasswordOtpVerified(email));
      } else {
        emit(const ForgotPasswordError('Invalid verification code'));
      }
    } catch (e) {
      emit(ForgotPasswordError('Verification failed: ${e.toString()}'));
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      emit(ForgotPasswordLoading());
      await Future.delayed(const Duration(seconds: 2));

      // Simulate password validation
      if (newPassword.length < 6) {
        emit(const ForgotPasswordError('Password must be at least 6 characters'));
        return;
      }

      // Simulate successful password reset
      emit(ForgotPasswordInitial()); // Return to initial state after success
    } catch (e) {
      emit(ForgotPasswordError('Password reset failed: ${e.toString()}'));
    }
  }

  void resetState() {
    emit(ForgotPasswordInitial());
  }
}
