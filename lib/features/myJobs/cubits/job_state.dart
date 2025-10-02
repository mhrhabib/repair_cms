// cubits/job_states.dart
part of 'job_cubit.dart';

abstract class JobStates {}

class JobInitial extends JobStates {}

class JobLoading extends JobStates {}

class JobSuccess extends JobStates {
  final List<Job> jobs;
  final int totalJobs;
  final int serviceRequestJobs;
  final int total;
  final int pages;
  final int page;
  final int limit;
  final bool hasMore;

  JobSuccess({
    required this.jobs,
    required this.totalJobs,
    required this.serviceRequestJobs,
    required this.total,
    required this.pages,
    required this.page,
    required this.limit,
    this.hasMore = false,
  });
}

class JobDetailSuccess extends JobStates {
  final Job job;

  JobDetailSuccess({required this.job});
}

class JobStatusUpdated extends JobStates {
  final Job job;

  JobStatusUpdated({required this.job});
}

class JobError extends JobStates {
  final String message;

  JobError({required this.message});
}
