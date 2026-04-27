// cubits/sign_in_states.dart
part of 'sign_in_cubit.dart';

abstract class SignInStates {}

class SignInInitial extends SignInStates {}

class SignInLoading extends SignInStates {}

class SignInSuccess extends SignInStates {
  final String email;
  final String message;

  SignInSuccess({required this.email, required this.message});
}

class LoginSuccess extends SignInStates {
  final String email;
  final String message;
  final String? token;
  final User? user;

  LoginSuccess({required this.email, required this.message, this.token, this.user});
}

class TwoFactorRequired extends SignInStates {
  final String email;
  final String message;
  final String? twoFactorEmail;
  final bool bothEnabled;
  final bool appBasedAuthEnabled;
  final bool emailBasedAuthEnabled;

  TwoFactorRequired({
    required this.email,
    required this.message,
    this.twoFactorEmail,
    this.bothEnabled = false,
    this.appBasedAuthEnabled = false,
    this.emailBasedAuthEnabled = false,
  });
}

class SignInError extends SignInStates {
  final String message;

  SignInError({required this.message});
}
