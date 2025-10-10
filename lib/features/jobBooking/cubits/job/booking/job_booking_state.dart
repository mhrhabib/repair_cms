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
  final int currentStep;

  const JobBookingData({
    required this.job,
    required this.defect,
    required this.device,
    required this.contact,
    required this.currentStep,
  });

  JobBookingData copyWith({Job? job, Defect? defect, Device? device, Contact? contact, int? currentStep}) {
    return JobBookingData(
      job: job ?? this.job,
      defect: defect ?? this.defect,
      device: device ?? this.device,
      contact: contact ?? this.contact,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
