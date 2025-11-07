part of 'job_cubit.dart';

abstract class JobStates {}

class JobInitial extends JobStates {}

class JobLoading extends JobStates {}

class JobSuccess extends JobStates {
  final JobListResponse response;
  final List<Job> jobs;
  final int totalJobs;
  final int serviceRequestJobs;
  final int currentTotalJobs;
  final int pages;
  final int page;
  final int limit;
  final bool hasMore;

  JobSuccess({
    required this.response,
    required this.jobs,
    required this.totalJobs,
    required this.serviceRequestJobs,
    required this.currentTotalJobs,
    required this.pages,
    required this.page,
    required this.limit,
    this.hasMore = false,
  });
}

class JobDetailSuccess extends JobStates {
  final SingleJobModel job;

  JobDetailSuccess({required this.job});
}

class JobPrioritySuccess extends JobStates {
  final SingleJobModel job;

  JobPrioritySuccess({required this.job});
}

class JobStatusUpdated extends JobStates {
  final SingleJobModel job;

  JobStatusUpdated({required this.job});
}

class JobError extends JobStates {
  final String message;

  JobError({required this.message});
}

// Add this to your job_state.dart file

class AssignUserListLoading extends JobStates {}

class AssignUserListSuccess extends JobStates {
  final List<User> users;

  AssignUserListSuccess({required this.users});
}

class AssignUserListError extends JobStates {
  final String message;

  AssignUserListError({required this.message});
}
