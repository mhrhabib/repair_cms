import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/myJobs/models/assign_user_list_model.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/myJobs/repository/job_repository.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
part 'job_state.dart';

class JobCubit extends Cubit<JobStates> {
  final JobRepository repository;

  // Track current filter state
  String _currentStatusFilter = '';
  String _currentKeyword = '';
  String _currentStartDate = '';
  String _currentEndDate = '';
  int _currentPage = 1;
  final int _pageSize = 20;

  JobCubit({required this.repository}) : super(JobInitial());

  Future<void> getJobs({
    String? keyword,
    String? startDate,
    String? endDate,
    String? status,
    int page = 1,
    bool loadMore = false,
  }) async {
    // Update filter state
    _currentKeyword = keyword ?? _currentKeyword;
    _currentStartDate = startDate ?? _currentStartDate;
    _currentEndDate = endDate ?? _currentEndDate;
    _currentStatusFilter = status ?? _currentStatusFilter;
    _currentPage = page;

    if (!loadMore) {
      emit(JobLoading());
    }

    try {
      print('🔄 JobCubit: Fetching jobs with params: page=$page, status=$status');

      final JobListResponse response = await repository.getJobs(
        keyword: _currentKeyword,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        status: _currentStatusFilter,
        page: _currentPage,
        pageSize: _pageSize,
        userID: storage.read('userId'),
      );

      print('✅ JobCubit: Successfully parsed ${response.jobs.length} jobs');
      print('📊 JobCubit: Total jobs: ${response.totalJobs}, Pages: ${response.pages}');

      // Check if jobs are properly parsed
      if (response.jobs.isNotEmpty) {
        final firstJob = response.jobs.first;
        print('🔍 First job details:');
        print('   - Job No: ${firstJob.jobNo}');
        print('   - Customer: ${firstJob.customerDetails.firstName} ${firstJob.customerDetails.lastName}');
        print('   - Status: ${firstJob.status}');
      }

      if (loadMore) {
        final currentState = state;
        if (currentState is JobSuccess) {
          // Combine existing jobs with new ones
          final allJobs = [...currentState.jobs, ...response.jobs];
          emit(
            JobSuccess(
              response: response,
              jobs: allJobs,
              totalJobs: response.totalJobs,
              serviceRequestJobs: response.serviceRequestJobs,
              currentTotalJobs: response.currentTotalJobs,
              pages: response.pages,
              page: _currentPage,
              limit: _pageSize,
              hasMore: _currentPage < response.pages,
            ),
          );
        }
      } else {
        emit(
          JobSuccess(
            response: response,
            jobs: response.jobs,
            totalJobs: response.totalJobs,
            serviceRequestJobs: response.serviceRequestJobs,
            currentTotalJobs: response.currentTotalJobs,
            pages: response.pages,
            page: _currentPage,
            limit: _pageSize,
            hasMore: _currentPage < response.pages,
          ),
        );
      }
    } catch (e) {
      print('❌ JobCubit Error: $e');
      print('❌ Error type: ${e.runtimeType}');
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> loadMoreJobs() async {
    final currentState = state;
    if (currentState is JobSuccess && currentState.hasMore) {
      await getJobs(page: _currentPage + 1, loadMore: true);
    }
  }

  Future<void> getJobById(String jobId) async {
    emit(JobLoading());
    try {
      final job = await repository.getJobById(jobId);
      emit(JobDetailSuccess(job: job));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  // Add these methods to your JobCubit

  // Add these methods to your JobCubit

  Future<void> setJobAsComplete({
    required String jobId,
    required String userId,
    required String userName,
    required String email,
    String? notes,
    bool sendNotification = true,
    required SingleJobModel currentJob, // Add current job parameter
  }) async {
    emit(JobLoading());
    try {
      final SingleJobModel updatedJob = await repository.updateJobCompletionStatus(
        jobId,
        true, // isJobCompleted
        userId,
        userName,
        email,
        customNotes: notes,
        sendNotification: sendNotification,
        currentJob: currentJob, // Pass current job for email data
      );

      emit(JobStatusUpdated(job: updatedJob));

      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> setJobAsIncomplete({
    required String jobId,
    required String userId,
    required String userName,
    required String email,
    String? notes,
    bool sendNotification = true,
    required SingleJobModel currentJob,
  }) async {
    emit(JobLoading());
    try {
      final SingleJobModel updatedJob = await repository.updateJobCompletionStatus(
        jobId,
        false, // isJobCompleted
        userId,
        userName,
        email,
        customNotes: notes,
        sendNotification: sendNotification,
        currentJob: currentJob,
      );

      emit(JobStatusUpdated(job: updatedJob));

      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  // Backward compatibility method
  Future<void> updateCompleteJobStatus({
    required String jobId,
    required bool isJobCompleted,
    required String userId,
    required String userName,
    required String email,
    String? notes,
    bool sendNotification = true,
    required SingleJobModel currentJob,
  }) async {
    if (isJobCompleted) {
      await setJobAsComplete(
        jobId: jobId,
        userId: userId,
        userName: userName,
        email: email,
        notes: notes,
        sendNotification: sendNotification,
        currentJob: currentJob,
      );
    } else {
      await setJobAsIncomplete(
        jobId: jobId,
        userId: userId,
        userName: userName,
        email: email,
        notes: notes,
        sendNotification: sendNotification,
        currentJob: currentJob,
      );
    }
  }

  // Add these methods to your JobCubit

  Future<void> setDeviceAsReturned({
    required String jobId,
    required String userId,
    required String userName,
    required String email,
    String? notes,
    bool sendNotification = true,
  }) async {
    emit(JobLoading());
    try {
      final SingleJobModel updatedJob = await repository.updateJobReturnStatus(
        jobId,
        true, // isReturnDevice
        userId,
        userName,
        email,
        customNotes: notes,
        sendNotification: sendNotification,
      );

      emit(JobStatusUpdated(job: updatedJob));

      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> setDeviceAsNotReturned({
    required String jobId,
    required String userId,
    required String userName,
    required String email,
    String? notes,
    bool sendNotification = true,
  }) async {
    emit(JobLoading());
    try {
      final SingleJobModel updatedJob = await repository.updateJobReturnStatus(
        jobId,
        false, // isReturnDevice
        userId,
        userName,
        email,
        customNotes: notes,
        sendNotification: sendNotification,
      );

      emit(JobStatusUpdated(job: updatedJob));

      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  // Backward compatibility method
  Future<void> updateReturnJobStatus(
    String jobId,
    bool isReturnDevice,
    String userId,
    String userName,
    String email, {
    String? notes,
    bool sendNotification = true,
  }) async {
    if (isReturnDevice) {
      await setDeviceAsReturned(
        jobId: jobId,
        userId: userId,
        userName: userName,
        email: email,
        notes: notes,
        sendNotification: sendNotification,
      );
    } else {
      await setDeviceAsNotReturned(
        jobId: jobId,
        userId: userId,
        userName: userName,
        email: email,
        notes: notes,
        sendNotification: sendNotification,
      );
    }
  }

  // job priority update
  // Add to JobCubit

  Future<void> updateJobDueDate(String jobId, DateTime dueDate) async {
    emit(JobLoading());
    try {
      final updatedJob = await repository.updateJobDueDate(jobId, dueDate);
      emit(JobStatusUpdated(job: updatedJob));
      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> updateJobAssignee(String jobId, String assignUserId, String assignerName) async {
    emit(JobLoading());
    try {
      final updatedJob = await repository.updateJobAssignee(jobId, assignUserId, assignerName);
      emit(JobStatusUpdated(job: updatedJob));
      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  // Update the existing priority method to use new repository method
  Future<void> updateJobPriority(String jobId, String priority) async {
    emit(JobLoading());
    debugPrint('🔄 Updating job priority for Job ID: $jobId to $priority');
    try {
      final updatedJob = await repository.updateJobPriority(jobId, priority);
      emit(JobPrioritySuccess(job: updatedJob));
      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  // Add this to your JobCubit

  Future<void> getAssignUserList() async {
    // Don't emit loading state here to preserve current job state
    try {
      final ownerId = storage.read('userId');
      if (ownerId == null) {
        throw Exception('User ID not found in storage');
      }

      final AssignUserListModel response = await repository.getAssignUserList(ownerId);

      emit(AssignUserListSuccess(users: response.data));
    } catch (e) {
      debugPrint('❌ JobCubit Error in getAssignUserList: $e');
      emit(AssignUserListError(message: e.toString()));
    }
  }

  // add job status
  // Add to JobCubit class
  // Update the addJobStatus method in JobCubit
  Future<void> addJobStatus({
    required String jobId,
    required String status,
    required String userId,
    required String userName,
    required String email,
    String? notes,
    bool sendNotification = true,
    String? colorCode,
    int priority = 2,
  }) async {
    // Use a temporary loading state that doesn't interfere with the main state
    emit(JobActionLoading());

    try {
      final SingleJobModel updatedJob = await repository.addJobStatus(
        jobId: jobId,
        status: status,
        userId: userId,
        userName: userName,
        email: email,
        notes: notes,
        sendNotification: sendNotification,
        colorCode: colorCode,
        priority: priority,
      );

      // Emit success state for the action
      emit(JobStatusUpdateSuccess(job: updatedJob));

      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobActionError(message: e.toString()));
      // Re-emit the previous successful state after a delay
      Future.delayed(Duration(seconds: 2), () {
        if (state is JobDetailSuccess) {
          emit(state); // Re-emit the current detail state
        }
      });
    }
  }

  void filterJobsByStatus(String status) {
    _currentStatusFilter = status;
    _currentPage = 1;
    getJobs(status: status);
  }

  void searchJobs(String keyword) {
    _currentKeyword = keyword;
    _currentPage = 1;
    getJobs(keyword: keyword);
  }

  void filterByDateRange(String startDate, String endDate) {
    _currentStartDate = startDate;
    _currentEndDate = endDate;
    _currentPage = 1;
    getJobs(startDate: startDate, endDate: endDate);
  }

  void clearFilters() {
    _currentKeyword = '';
    _currentStartDate = '';
    _currentEndDate = '';
    _currentStatusFilter = '';
    _currentPage = 1;
    getJobs();
  }

  // Getters for current filter state
  String get currentStatusFilter => _currentStatusFilter;
  String get currentKeyword => _currentKeyword;
  String get currentStartDate => _currentStartDate;
  String get currentEndDate => _currentEndDate;

  ///.=========================================================================.
  ///! add job notes                                                        !
  ///.=========================================================================.
  // Add to JobCubit class
  Future<void> addJobNote({
    required String jobId,
    required String noteText,
    required String userId,
    required String userName,
  }) async {
    if (isClosed) return;

    emit(JobActionLoading());

    try {
      final SingleJobModel updatedJob = await repository.addJobNote(
        jobId: jobId,
        noteText: noteText,
        userId: userId,
        userName: userName,
      );

      if (!isClosed) {
        emit(JobNoteUpdateSuccess(job: updatedJob));
      }
      await getJobById(jobId);
    } catch (e) {
      if (!isClosed) {
        emit(JobActionError(message: e.toString()));
      }
    }
  }

  Future<void> updateJobNote({
    required String jobId,
    required String noteId,
    required String noteText,
    required String userId,
    required String userName,
  }) async {
    emit(JobActionLoading());

    try {
      final SingleJobModel updatedJob = await repository.updateJobNote(
        jobId: jobId,
        noteId: noteId,
        noteText: noteText,
        userId: userId,
        userName: userName,
      );

      emit(JobNoteUpdateSuccess(job: updatedJob));

      // Reload the job to get the latest data
      await getJobById(jobId);
    } catch (e) {
      emit(JobActionError(message: e.toString()));
      Future.delayed(Duration(seconds: 2), () {
        if (state is JobDetailSuccess) {
          emit(state);
        }
      });
    }
  }

  Future<void> deleteJobNote({required String jobId, required String noteId}) async {
    if (isClosed) return;

    emit(JobActionLoading());

    try {
      final SingleJobModel updatedJob = await repository.deleteJobNote(jobId: jobId, noteId: noteId);

      if (!isClosed) {
        emit(JobNoteUpdateSuccess(job: updatedJob));
        // Don't call getJobById here - let the BlocListener handle it
      }
      emit(JobNoteUpdateSuccess(job: updatedJob));
      await getJobById(jobId);
    } catch (e) {
      if (!isClosed) {
        emit(JobActionError(message: e.toString()));
      }
    }
  }

  ///.=========================================================================.
  ///! file upload                                                     !
  ///.=========================================================================.
  ///
  // Add to JobCubit class
  Future<void> uploadJobFile({
    required String jobId,
    required String jobNo,
    required String filePath,
    required String fileName,
    required int fileSize,
  }) async {
    if (isClosed) return;

    emit(JobFileUploading());

    try {
      final SingleJobModel updatedJob = await repository.uploadJobFile(
        jobId: jobId,
        jobNo: jobNo,
        filePath: filePath,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (!isClosed) {
        emit(JobFileUploadSuccess(job: updatedJob));
      }
    } catch (e) {
      if (!isClosed) {
        emit(JobActionError(message: e.toString()));
      }
    }
  }

  Future<void> deleteJobFile({required String jobId, required String fileId}) async {
    if (isClosed) return;

    emit(JobActionLoading());

    try {
      final SingleJobModel updatedJob = await repository.deleteJobFile(jobId: jobId, fileId: fileId);

      if (!isClosed) {
        emit(JobFileDeleteSuccess(job: updatedJob));
      }
    } catch (e) {
      if (!isClosed) {
        emit(JobActionError(message: e.toString()));
      }
    }
  }
}
