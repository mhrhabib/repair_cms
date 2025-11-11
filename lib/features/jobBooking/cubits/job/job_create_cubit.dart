import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/repository/job_booking_repository.dart';
part 'job_create_state.dart';

class JobCreateCubit extends Cubit<JobCreateState> {
  final JobBookingRepository jobRepository;

  JobCreateCubit({required this.jobRepository}) : super(JobCreateInitial());

  Future<void> createJob({required CreateJobRequest request}) async {
    emit(JobCreateLoading());

    try {
      debugPrint('🚀 [JobCubit] Starting job creation...');
      final response = await jobRepository.createJob(request: request);

      debugPrint('✅ [JobCubit] Job created successfully');
      emit(JobCreateCreated(response: response));
    } on JobException catch (e) {
      debugPrint('❌ [JobCubit] Job creation failed: ${e.message}');
      emit(JobCreateError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [JobCubit] Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(JobCreateError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  void clearState() {
    emit(JobCreateInitial());
  }
}
