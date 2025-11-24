part of 'notification_cubit.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Notifications> notifications;

  NotificationLoaded({required this.notifications});
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});
}
