// cubits/dashboard_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/features/dashboard/models/completed_jobs_response_model.dart';
import 'package:repair_cms/features/dashboard/repository/dashboard_repository.dart';
part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  // Track both types of data
  CompletedJobsResponseModel? _dashboardStats;
  CompletedJobsResponseModel? _jobProgress;

  // Timeout duration for dashboard operations (40 seconds to account for network delays)
  static const Duration operationTimeout = Duration(seconds: 40);

  DashboardCubit({required this.repository}) : super(DashboardInitial());

  void _safeEmit(DashboardState state) {
    try {
      if (!isClosed) {
        emit(state);
      } else {
        debugPrint('🚫 [DashboardCubit] Attempted to emit after cubit was closed: $state');
      }
    } catch (e) {
      debugPrint('❌ [DashboardCubit] Error in _safeEmit: $e');
    }
  }

  // Get completed jobs with date range
  Future<void> getDashboardStats({DateTime? startDate, DateTime? endDate, String? userId}) async {
    _safeEmit(DashboardLoading());

    try {
      debugPrint('🔄 [DashboardCubit] Fetching dashboard stats');
      debugPrint('👤 [DashboardCubit] User ID: $userId');

      String? startDateString;
      String? endDateString;

      if (startDate != null && endDate != null) {
        startDateString = repository.formatDateForApi(startDate);
        endDateString = repository.formatDateForApi(endDate);
      }

      final response = await repository.getCompletedJobs(
        startDate: startDateString,
        endDate: endDateString,
        userId: userId,
      );

      if (isClosed) {
        debugPrint('🔁 [DashboardCubit] Cubit closed; aborting getDashboardStats');
        return;
      }

      _dashboardStats = response;

      debugPrint('✅ [DashboardCubit] Successfully fetched dashboard stats');
      debugPrint('📊 [DashboardCubit] Completed Jobs: ${response.completedJobs}');
      debugPrint('📈 [DashboardCubit] Total Jobs: ${response.totalJobs}');

      _safeEmit(DashboardLoaded(dashboardStats: _dashboardStats, jobProgress: _jobProgress));
    } on DashboardException catch (e) {
      debugPrint('❌ [DashboardCubit] Dashboard Error: ${e.message}');
      _safeEmit(DashboardError(message: e.message));
    } catch (e) {
      debugPrint('💥 [DashboardCubit] Unexpected Error: $e');
      _safeEmit(DashboardError(message: 'Unexpected error occurred: ${e.toString()}'));
    }
  }

  // Get job progress data (without date parameters)
  Future<void> getJobProgress({String? userId}) async {
    _safeEmit(DashboardLoading());

    try {
      debugPrint('🔄 [DashboardCubit] Fetching job progress data');
      debugPrint('👤 [DashboardCubit] User ID: $userId');

      final response = await repository.getJobProgress(userId: userId);

      if (isClosed) {
        debugPrint('🔁 [DashboardCubit] Cubit closed; aborting getJobProgress');
        return;
      }

      _jobProgress = response;

      debugPrint('✅ [DashboardCubit] Successfully fetched job progress');
      debugPrint('📊 [DashboardCubit] Total Active Jobs: ${response.totalJobs}');
      debugPrint('🔄 [DashboardCubit] In Progress Jobs: ${response.inProgressJobs}');
      debugPrint('⏸️ [DashboardCubit] On Hold Jobs: ${response.readyToReturnJobs}');
      debugPrint('✅ [DashboardCubit] Quotation Confirmed: ${response.acceptedQuotesJobs}');
      debugPrint('❌ [DashboardCubit] Quotation Rejected: ${response.rejectQuotesJobs}');

      _safeEmit(DashboardLoaded(dashboardStats: _dashboardStats, jobProgress: _jobProgress));
    } on DashboardException catch (e) {
      debugPrint('❌ [DashboardCubit] Dashboard Error: ${e.message}');
      _safeEmit(DashboardError(message: e.message));
    } catch (e) {
      debugPrint('💥 [DashboardCubit] Unexpected Job Progress Error: $e');
      _safeEmit(DashboardError(message: 'Unexpected error occurred: ${e.toString()}'));
    }
  }

  // Load all dashboard data
  Future<void> loadAllDashboardData({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    bool force = false,
  }) async {
    // Prevent redundant loads unless forced
    if (state is DashboardLoading && !force) {
      debugPrint('⏳ [DashboardCubit] Load already in progress, skipping redundant call');
      return;
    }

    _safeEmit(DashboardLoading());

    try {
      debugPrint('🔄 [DashboardCubit] Loading all dashboard data');
      debugPrint('👤 [DashboardCubit] User ID: $userId');

      // Get dashboard stats with date range
      String? startDateString;
      String? endDateString;

      if (startDate != null && endDate != null) {
        startDateString = repository.formatDateForApi(startDate);
        endDateString = repository.formatDateForApi(endDate);
      }

      final statsFuture = repository.getCompletedJobs(
        startDate: startDateString,
        endDate: endDateString,
        userId: userId,
      );

      // Get job progress without date parameters
      final progressFuture = repository.getJobProgress(userId: userId);

      // Wait for both requests to complete with timeout protection
      final results = await Future.wait([statsFuture, progressFuture]).timeout(
        operationTimeout,
        onTimeout: () {
          debugPrint('⏱️ [DashboardCubit] loadAllDashboardData operation timeout');
          throw DashboardException(message: 'Dashboard data loading timed out. Please try again.');
        },
      );

      if (isClosed) {
        debugPrint('🔁 [DashboardCubit] Cubit closed; aborting loadAllDashboardData');
        return;
      }

      _dashboardStats = results[0];
      _jobProgress = results[1];

      debugPrint('✅ [DashboardCubit] All data loaded successfully');
      debugPrint('📊 [DashboardCubit] Stats: ${_dashboardStats?.completedJobs ?? 0} completed');
      debugPrint('📈 [DashboardCubit] Progress: ${_jobProgress?.totalJobs ?? 0} total jobs');

      _safeEmit(DashboardLoaded(dashboardStats: _dashboardStats, jobProgress: _jobProgress));
    } on DashboardException catch (e) {
      debugPrint('❌ [DashboardCubit] Dashboard Error: ${e.message}');
      _safeEmit(DashboardError(message: e.message));
    } catch (e) {
      debugPrint('💥 [DashboardCubit] Unexpected All Data Error: $e');
      _safeEmit(DashboardError(message: 'Failed to load dashboard data: ${e.toString()}'));
    }
  }

  Future<void> getTodayStats(String? userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    await loadAllDashboardData(startDate: startOfDay, endDate: endOfDay, userId: userId);
  }

  Future<void> getThisMonthStats(String? userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    await loadAllDashboardData(startDate: startOfMonth, endDate: endOfMonth, userId: userId);
  }

  void clearError() {
    final currentState = state;
    if (currentState is DashboardError) {
      _safeEmit(DashboardInitial());
    }
  }

  // Getters for current data
  CompletedJobsResponseModel? get dashboardStats => _dashboardStats;
  CompletedJobsResponseModel? get jobProgress => _jobProgress;
}
