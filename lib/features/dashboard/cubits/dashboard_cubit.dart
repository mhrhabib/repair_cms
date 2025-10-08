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

  DashboardCubit({required this.repository}) : super(DashboardInitial());

  // Get completed jobs with date range
  Future<void> getDashboardStats({DateTime? startDate, DateTime? endDate, String? userId}) async {
    emit(DashboardLoading());

    try {
      debugPrint('🔄 DashboardCubit: Fetching dashboard stats');

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

      _dashboardStats = response;

      debugPrint('✅ DashboardCubit: Successfully fetched dashboard stats');
      debugPrint('📊 Completed Jobs: ${response.completedJobs}');
      debugPrint('📈 Total Jobs: ${response.totalJobs}');

      emit(DashboardLoaded(dashboardStats: _dashboardStats, jobProgress: _jobProgress));
    } catch (e) {
      debugPrint('❌ DashboardCubit Error: $e');
      emit(DashboardError(message: e.toString()));
    }
  }

  // Get job progress data (without date parameters)
  Future<void> getJobProgress() async {
    emit(DashboardLoading());

    try {
      debugPrint('🔄 DashboardCubit: Fetching job progress data');

      final response = await repository.getJobProgress();
      _jobProgress = response;

      debugPrint('✅ DashboardCubit: Successfully fetched job progress');
      debugPrint('📊 Total Active Jobs: ${response.totalJobs}');
      debugPrint('🔄 In Progress Jobs: ${response.inProgressJobs}');
      debugPrint('⏸️ On Hold Jobs: ${response.readyToReturnJobs}');
      debugPrint('✅ Quotation Confirmed: ${response.acceptedQuotesJobs}');
      debugPrint('❌ Quotation Rejected: ${response.rejectQuotesJobs}');

      emit(DashboardLoaded(dashboardStats: _dashboardStats, jobProgress: _jobProgress));
    } catch (e) {
      debugPrint('❌ DashboardCubit Job Progress Error: $e');
      emit(DashboardError(message: e.toString()));
    }
  }

  // Load all dashboard data
  Future<void> loadAllDashboardData({DateTime? startDate, DateTime? endDate, String? userId}) async {
    emit(DashboardLoading());

    try {
      debugPrint('🔄 DashboardCubit: Loading all dashboard data');

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

      // Wait for both requests to complete
      final results = await Future.wait([statsFuture, progressFuture]);

      _dashboardStats = results[0];
      _jobProgress = results[1];

      debugPrint('✅ DashboardCubit: All data loaded successfully');

      emit(DashboardLoaded(dashboardStats: _dashboardStats, jobProgress: _jobProgress));
    } catch (e) {
      debugPrint('❌ DashboardCubit All Data Error: $e');
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> getTodayStats(String? userId) async {
    final dateRange = repository.getTodayDateRange();
    await loadAllDashboardData(
      startDate: DateTime.parse(dateRange['startDate']!),
      endDate: DateTime.parse(dateRange['endDate']!),
      userId: userId,
    );
  }

  Future<void> getThisMonthStats(String? userId) async {
    final dateRange = repository.getThisMonthDateRange();
    await loadAllDashboardData(
      startDate: DateTime.parse(dateRange['startDate']!),
      endDate: DateTime.parse(dateRange['endDate']!),
      userId: userId,
    );
  }

  void clearError() {
    final currentState = state;
    if (currentState is DashboardError) {
      emit(DashboardInitial());
    }
  }

  // Getters for current data
  CompletedJobsResponseModel? get dashboardStats => _dashboardStats;
  CompletedJobsResponseModel? get jobProgress => _jobProgress;
}
