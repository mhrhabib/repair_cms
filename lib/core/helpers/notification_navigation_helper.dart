import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';
import 'package:repair_cms/features/messeges/chat_conversation_screen.dart';
import 'package:repair_cms/features/messeges/cubits/message_cubit.dart';
import 'package:repair_cms/set_up_di.dart';

/// Helper class to set up notification navigation in the app
class NotificationNavigationHelper {
  /// Set up the navigation callback for handling notification taps
  /// Call this once when your navigation context is ready (e.g., in Messages screen)
  static void setupNavigationCallback(BuildContext context) {
    final notificationService = SetUpDI.getIt<LocalNotificationService>();

    notificationService.setNavigationCallback((conversationId, jobId) {
      debugPrint('📱 [NotificationNavigation] Navigating to conversation: $conversationId');

      // Navigate to the conversation screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: SetUpDI.getIt<MessageCubit>(),
            child: ChatConversationScreen(
              conversationId: conversationId,
              // Optional: could fetch recipient info from jobId if needed
            ),
          ),
        ),
      );
    });
  }
}
