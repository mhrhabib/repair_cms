// cubits/forgot_password_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/features/auth/forgotPassword/repo/forgot_password_repo.dart';
part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepository repository;

  ForgotPasswordCubit({required this.repository})
    : super(ForgotPasswordInitial());

  void updateOtp(String otp) {
    if (state is! ForgotPasswordLoading) {
      emit(ForgotPasswordOtpState(otp));
    }
  }

  Future<void> sendResetEmail(String email) async {
    try {
      emit(ForgotPasswordLoading());

      final response = await repository.sendOtp(email);

      if (response.success) {
        emit(ForgotPasswordEmailSent(email, response.message));
      } else {
        emit(ForgotPasswordError(response.error ?? response.message));
      }
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      emit(ForgotPasswordLoading());

      final response = await repository.verifyOtp(email, otp);

      if (response.success) {
        emit(ForgotPasswordOtpVerified(email, otp, response.message));
      } else {
        emit(ForgotPasswordError(response.error ?? response.message));
      }
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  Future<void> resetPassword(
    String email,
    String newPassword,
    String otp,
  ) async {
    try {
      emit(ForgotPasswordLoading());

      final response = await repository.resetPassword(email, newPassword, otp);

      if (response.success) {
        emit(ForgotPasswordSuccess(response.message));
      } else {
        emit(ForgotPasswordError(response.error ?? response.message));
      }
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  void resetState() {
    emit(ForgotPasswordInitial());
  }
}
