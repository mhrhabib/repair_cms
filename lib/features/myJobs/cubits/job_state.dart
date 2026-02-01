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

// Add these states to your job_state.dart file
class JobActionLoading extends JobStates {
  JobActionLoading();
}

class JobStatusUpdateSuccess extends JobStates {
  final SingleJobModel job;

  JobStatusUpdateSuccess({required this.job});

  List<Object> get props => [job];
}

class JobActionError extends JobStates {
  final String message;

  JobActionError({required this.message});

  List<Object> get props => [message];
}

// Add to job_state.dart
class JobNoteUpdateSuccess extends JobStates {
  final SingleJobModel job;
  JobNoteUpdateSuccess({required this.job});
  List<Object> get props => [job];
}

// Add to job_state.dart
class JobFileUploading extends JobStates {
  JobFileUploading();
}

class JobFileUploadSuccess extends JobStates {
  final SingleJobModel job;

  JobFileUploadSuccess({required this.job});
  List<Object> get props => [job];
}

class JobFileDeleteSuccess extends JobStates {
  final SingleJobModel job;

  JobFileDeleteSuccess({required this.job});

  List<Object> get props => [job];
}

class JobStatusSettingsLoaded extends JobStates {
  final StatusSettingsResponse statusSettings;

  JobStatusSettingsLoaded({required this.statusSettings});

  List<Object> get props => [statusSettings];
}
