part of 'job_booking_cubit.dart';

abstract class JobBookingState {
  const JobBookingState();
}

class JobBookingInitial extends JobBookingState {}

class JobBookingData extends JobBookingState {
  final Job job;
  final Defect defect;
  final Device device;
  final Contact contact;
  final bool isUploading;
  final int currentStep;
  final String? jobId; // Store job ID after creation
  List<File>? localFiles;

  JobBookingData({
    required this.job,
    required this.defect,
    required this.device,
    required this.contact,
    this.isUploading = false,
    required this.currentStep,
    this.jobId,
    this.localFiles = const [],
  });

  JobBookingData copyWith({
    Job? job,
    Defect? defect,
    Device? device,
    Contact? contact,
    bool? isUploading,
    int? currentStep,
    String? jobId,
    List<File>? localFiles,
  }) {
    return JobBookingData(
      job: job ?? this.job,
      defect: defect ?? this.defect,
      device: device ?? this.device,
      contact: contact ?? this.contact,
      isUploading: isUploading ?? this.isUploading,
      currentStep: currentStep ?? this.currentStep,
      jobId: jobId ?? this.jobId,
      localFiles: localFiles ?? this.localFiles,
    );
  }
}
