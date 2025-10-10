part of 'job_create_cubit.dart';

abstract class JobCreateState {
  const JobCreateState();
}

class JobCreateInitial extends JobCreateState {}

class JobCreateLoading extends JobCreateState {}

class JobCreateCreated extends JobCreateState {
  final CreateJobResponse response;

  const JobCreateCreated({required this.response});
}

class JobCreateError extends JobCreateState {
  final String message;

  const JobCreateError({required this.message});
}
