import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/job_receipt_repo.dart';
import '../models/job_receipt_model.dart';

part 'job_receipt_state.dart';

class JobReceiptCubit extends Cubit<JobReceiptState> {
  final JobReceiptRepository jobReceiptRepository;

  JobReceiptCubit({required this.jobReceiptRepository}) : super(JobReceiptInitial());

  Future<void> getJobReceipt({required String userId}) async {
    debugPrint('🚀 [JobReceiptCubit] Starting to fetch job receipt');
    debugPrint('👤 [JobReceiptCubit] User ID: $userId');

    emit(JobReceiptLoading());

    try {
      final receipt = await jobReceiptRepository.getJobReceipt(userId: userId);

      debugPrint('✅ [JobReceiptCubit] Job receipt fetched successfully');
      debugPrint('📦 [JobReceiptCubit] Receipt ID: ${receipt.sId}');

      emit(JobReceiptLoaded(receipt: receipt));
    } on JobReceiptException catch (e) {
      debugPrint('❌ [JobReceiptCubit] Error fetching receipt: ${e.message}');
      emit(JobReceiptError(message: e.message));
    } catch (e) {
      debugPrint('💥 [JobReceiptCubit] Unexpected error: $e');
      emit(JobReceiptError(message: 'Unexpected error occurred: ${e.toString()}'));
    }
  }

  void reset() {
    debugPrint('🔄 [JobReceiptCubit] Resetting state');
    emit(JobReceiptInitial());
  }
}
