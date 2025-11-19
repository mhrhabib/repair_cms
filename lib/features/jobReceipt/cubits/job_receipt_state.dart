part of 'job_receipt_cubit.dart';

abstract class JobReceiptState {}

class JobReceiptInitial extends JobReceiptState {}

class JobReceiptLoading extends JobReceiptState {}

class JobReceiptLoaded extends JobReceiptState {
  final JobReceiptModel receipt;

  JobReceiptLoaded({required this.receipt});
}

class JobReceiptError extends JobReceiptState {
  final String message;

  JobReceiptError({required this.message});
}
