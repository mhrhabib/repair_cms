import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';
import 'package:repair_cms/features/home/home_screen.dart';
import 'package:repair_cms/features/messeges/chat_conversation_screen.dart';
import 'package:repair_cms/features/messeges/cubits/message_cubit.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/set_up_di.dart';

/// Helper class to set up notification deep-link navigation in the app.
///
/// Routing rules (based on FCM payload fields):
/// - action == 'open_conversation'  → open chat for [conversationId]
/// - message contains 'quote'       → open chat for [conversationId]
/// - everything else (job-notification: assign/priority/due) → open JobDetailsScreen
class NotificationNavigationHelper {
  /// Register the navigation callback with [LocalNotificationService].
  /// Call this once from a widget that has a valid [BuildContext] with
  /// all required BLoC providers (e.g., the root navigator context).
  static void setupNavigationCallback(BuildContext context) {
    final notificationService = SetUpDI.getIt<LocalNotificationService>();

    notificationService.setNavigationCallback((
      conversationId,
      jobNo,
      type,
      action,
      notifMessage,
    ) {
      debugPrint(
        '📱 [NotificationNavigation] Routing: action=$action type=$type msg=$notifMessage conversationId=$conversationId jobNo=$jobNo',
      );

      // ── Determine destination ─────────────────────────────────────
      final bool isConversationAction = action == 'open_conversation';
      final bool isQuoteMessage =
          notifMessage != null &&
          (notifMessage.contains('quote_accepted') ||
              notifMessage.contains('quote_rejected') ||
              notifMessage.contains('quote'));

      if (isConversationAction || isQuoteMessage) {
        _navigateToChat(context, conversationId: conversationId);
      } else {
        // Job-level notification (assign, priority, due date, etc.)
        // Navigate to jobs list then open the specific job if we have an ID.
        _navigateToJob(context, jobNo: jobNo, conversationId: conversationId);
      }
    });
  }

  // ── Private helpers ───────────────────────────────────────────────────

  static void _navigateToChat(
    BuildContext context, {
    required String conversationId,
  }) {
    debugPrint(
      '📱 [NotificationNavigation] → ChatConversationScreen ($conversationId)',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: SetUpDI.getIt<MessageCubit>(),
          child: ChatConversationScreen(conversationId: conversationId),
        ),
      ),
    );
  }

  static void _navigateToJob(
    BuildContext context, {
    String? jobNo,
    required String conversationId,
  }) {
    // If we have a jobNo or conversationId we can try to open the job details.
    // We push HomeScreen (jobs tab) as the base and then JobDetailsScreen on top.
    // JobDetailsScreen requires a MongoDB _id, not a jobNo string, so if
    // we only have jobNo we need an intermediate lookup. For now we navigate to
    // the Jobs tab and rely on the cubit to search by jobNo.
    debugPrint('📱 [NotificationNavigation] → JobDetailsScreen (jobNo=$jobNo)');

    if (jobNo != null && jobNo.isNotEmpty) {
      // Push HomeScreen (jobs tab index=1) and then search for the job.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
        (route) => false,
      );

      // After navigation, search by jobNo so the job appears in the list.
      // The JobCubit is available in the new HomeScreen context via DI.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          SetUpDI.getIt<JobCubit>().searchJobs(jobNo);
        } catch (e) {
          debugPrint(
            '⚠️ [NotificationNavigation] Could not trigger job search: $e',
          );
        }
      });
    } else {
      // No job number available — fall back to the jobs list.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
      );
    }
  }
}
