import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/features/notifications/models/notificaiton_model.dart';
import 'package:repair_cms/features/notifications/repository/notification_repo.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationCubit({required this.notificationRepository}) : super(NotificationInitial());

  Future<void> getNotifications({required String userId}) async {
    debugPrint('🚀 [NotificationCubit] Fetching notifications for user: $userId');

    emit(NotificationLoading());

    try {
      final notifications = await notificationRepository.getNotifications(userId: userId);
      debugPrint('✅ [NotificationCubit] Loaded ${notifications.length} notifications');
      emit(NotificationLoaded(notifications: notifications));
    } on NotificationException catch (e) {
      debugPrint('❌ [NotificationCubit] Error: ${e.message}');
      emit(NotificationError(message: e.message));
    } catch (e) {
      debugPrint('💥 [NotificationCubit] Unexpected error: $e');
      emit(NotificationError(message: 'Unexpected error occurred'));
    }
  }
}
