// cubits/profile_states.dart
part of 'profile_cubit.dart';

abstract class ProfileStates {}

class ProfileInitial extends ProfileStates {}

class ProfileLoading extends ProfileStates {}

class ProfileLoaded extends ProfileStates {
  final User user;

  ProfileLoaded({required this.user});
}

class ProfileUpdated extends ProfileStates {
  final User user;

  ProfileUpdated({required this.user});
}

class PasswordChanged extends ProfileStates {}

class ProfileError extends ProfileStates {
  final String message;

  ProfileError({required this.message});
}
