// cubits/dashboard_state.dart
part of 'dashboard_cubit.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final CompletedJobsResponseModel? dashboardStats;
  final CompletedJobsResponseModel? jobProgress;

  const DashboardLoaded({this.dashboardStats, this.jobProgress});
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});
}
