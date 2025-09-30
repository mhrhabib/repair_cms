// cubits/forgot_password_state.dart
part of 'forgot_password_cubit.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  const ForgotPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ForgotPasswordEmailSent extends ForgotPasswordState {
  final String email;
  final String message;
  const ForgotPasswordEmailSent(this.email, this.message);

  @override
  List<Object> get props => [email, message];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String email;
  final String message;
  const ForgotPasswordOtpVerified(this.email, this.message);

  @override
  List<Object> get props => [email, message];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);

  @override
  List<Object> get props => [message];
}

class ForgotPasswordOtpState extends ForgotPasswordState {
  final String otp;
  const ForgotPasswordOtpState(this.otp);

  @override
  List<Object> get props => [otp];
}
