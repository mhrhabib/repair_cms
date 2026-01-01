import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/repository/job_type_repository.dart';
import 'package:repair_cms/features/jobBooking/models/job_type_model.dart';
import 'package:equatable/equatable.dart';
part 'job_type_state.dart';

class JobTypeCubit extends Cubit<JobTypeState> {
  final JobTypeRepository jobTypeRepository;

  JobTypeCubit({required this.jobTypeRepository}) : super(JobTypeInitial());

  Future<void> getJobTypes({required String userId}) async {
    emit(JobTypeLoading());

    try {
      debugPrint('🚀 [JobTypeCubit] Fetching job types for user: $userId');
      final jobTypes = await jobTypeRepository.getJobTypeList(userId: userId);

      debugPrint('✅ [JobTypeCubit] Successfully loaded ${jobTypes.length} job types');
      emit(JobTypeLoaded(jobTypes: jobTypes));
    } on JobTypeException catch (e) {
      debugPrint('❌ [JobTypeCubit] JobTypeException: ${e.message}');
      emit(JobTypeError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [JobTypeCubit] Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(JobTypeError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  void clearJobTypes() {
    emit(JobTypeInitial());
  }

  Future<void> createJobType({required String name, required String userId, required String locationId}) async {
    // Basic validation
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      debugPrint('❌ [JobTypeCubit] Attempted to create job type with empty name');
      emit(const JobTypeError(message: 'Job type name cannot be empty'));
      return;
    }

    emit(JobTypeLoading());

    try {
      debugPrint('🚀 [JobTypeCubit] Creating job type: $trimmedName');

      final newJobType = await jobTypeRepository.createJobType(
        name: trimmedName,
        userId: userId,
        locationId: locationId,
      );

      debugPrint('✅ [JobTypeCubit] Job type created successfully: ${newJobType.sId ?? 'unknown id'}');

      // Refresh the job types list
      await getJobTypes(userId: userId);
    } on JobTypeException catch (e) {
      debugPrint('❌ [JobTypeCubit] JobTypeException during creation: ${e.message}');
      emit(JobTypeError(message: e.message));
      return;
    } catch (e, stackTrace) {
      debugPrint('💥 [JobTypeCubit] Unexpected error during creation: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(JobTypeError(message: 'Failed to create job type'));
      return;
    }
  }

  // Get job type by ID
  JobType? getJobTypeById(String jobTypeId) {
    final state = this.state;
    if (state is JobTypeLoaded) {
      return state.jobTypes.firstWhere((jobType) => jobType.sId == jobTypeId, orElse: () => JobType());
    }
    return null;
  }

  // Get job type by name
  JobType? getJobTypeByName(String name) {
    final state = this.state;
    if (state is JobTypeLoaded) {
      return state.jobTypes.firstWhere(
        (jobType) => jobType.name?.toLowerCase() == name.toLowerCase(),
        orElse: () => JobType(),
      );
    }
    return null;
  }

  // Get default job type
  // JobType? getDefaultJobType() {
  //   final state = this.state;
  //   if (state is JobTypeLoaded) {
  //     return state.jobTypes.firstWhere(
  //       (jobType) => jobType.isDefault == true,
  //       orElse: () => state.jobTypes.isNotEmpty ? state.jobTypes.first : JobType(),
  //     );
  //   }
  //   return null;
  // }
}
