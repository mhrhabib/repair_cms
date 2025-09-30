part of 'forgot_password_cubit.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordEmailSent extends ForgotPasswordState {
  final String email;
  const ForgotPasswordEmailSent(this.email);

  @override
  List<Object> get props => [email];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String email;
  const ForgotPasswordOtpVerified(this.email);

  @override
  List<Object> get props => [email];
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
