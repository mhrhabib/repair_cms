part of 'job_file_upload_cubit.dart';

abstract class JobFileUploadState {}

class JobFileUploadInitial extends JobFileUploadState {}

class JobFileUploadLoading extends JobFileUploadState {}

class JobFileUploadSuccess extends JobFileUploadState {
  final List<UploadedFile> uploadedFiles;

  JobFileUploadSuccess({required this.uploadedFiles});
}

class JobFileUploadError extends JobFileUploadState {
  final String message;

  JobFileUploadError({required this.message});
}
