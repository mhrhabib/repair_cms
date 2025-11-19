import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/job_booking_file_upload_repo.dart';

part 'job_file_upload_state.dart';

class JobFileUploadCubit extends Cubit<JobFileUploadState> {
  final JobBookingFileUploadRepository fileUploadRepository;

  JobFileUploadCubit({required this.fileUploadRepository}) : super(JobFileUploadInitial());

  Future<void> uploadFiles({required String userId, required String jobId, required List fileData}) async {
    debugPrint('🚀 [JobFileUploadCubit] Starting file upload process');
    debugPrint('👤 [JobFileUploadCubit] User ID: $userId');
    debugPrint('📋 [JobFileUploadCubit] Job ID: $jobId');
    debugPrint('📊 [JobFileUploadCubit] Files to upload: ${fileData.length}');

    emit(JobFileUploadLoading());

    try {
      final uploadedFiles = await fileUploadRepository.uploadJobFile(userId: userId, jobId: jobId, fileData: fileData);

      debugPrint('✅ [JobFileUploadCubit] Upload completed successfully');
      debugPrint('📦 [JobFileUploadCubit] Uploaded files count: ${uploadedFiles.length}');

      emit(JobFileUploadSuccess(uploadedFiles: uploadedFiles));
    } on JobFileUploadException catch (e) {
      debugPrint('❌ [JobFileUploadCubit] Upload failed: ${e.message}');
      emit(JobFileUploadError(message: e.message));
    } catch (e) {
      debugPrint('💥 [JobFileUploadCubit] Unexpected error: $e');
      emit(JobFileUploadError(message: 'Unexpected error occurred: ${e.toString()}'));
    }
  }

  void reset() {
    debugPrint('🔄 [JobFileUploadCubit] Resetting state');
    emit(JobFileUploadInitial());
  }
}
