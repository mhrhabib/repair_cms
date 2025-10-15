// features/jobBooking/cubit/job_type_state.dart
part of 'job_type_cubit.dart';

abstract class JobTypeState extends Equatable {
  const JobTypeState();

  @override
  List<Object> get props => [];
}

class JobTypeInitial extends JobTypeState {}

class JobTypeLoading extends JobTypeState {}

class JobTypeLoaded extends JobTypeState {
  final List<JobType> jobTypes;

  const JobTypeLoaded({required this.jobTypes});

  @override
  List<Object> get props => [jobTypes];
}

class JobTypeError extends JobTypeState {
  final String message;

  const JobTypeError({required this.message});

  @override
  List<Object> get props => [message];
}
