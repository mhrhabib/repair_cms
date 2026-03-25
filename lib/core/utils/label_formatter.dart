import 'package:repair_cms/features/notifications/models/notificaiton_model.dart';

/// Shared utility for converting raw API strings (snake_case, underscore slugs,
/// and notification message templates) into human-readable labels.
class LabelFormatter {
  LabelFormatter._();

  // ─── Generic ────────────────────────────────────────────────────────────

  /// Converts any snake_case or underscore-separated string to Title Case.
  ///
  /// Examples:
  ///   "in_progress"          → "In Progress"
  ///   "ready_to_return"      → "Ready To Return"
  ///   "has_accepted_quotation_no123" → "Has Accepted Quotation No123"
  static String formatLabel(String raw) {
    if (raw.isEmpty) return raw;
    return raw
        .split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ')
        .trim();
  }

  // ─── Job Status ─────────────────────────────────────────────────────────

  /// Maps known job status API slugs to display strings.
  /// Falls back to [formatLabel] for any unknown status.
  static String formatJobStatus(String rawStatus) {
    final status = rawStatus.toLowerCase().trim();
    switch (status) {
      case 'booked':
        return 'Booked In';
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      case 'repair_in_progress':
        return 'Repair In Progress';
      case 'accepted_quotes':
      case 'quotation_accepted':
        return 'Quote Accepted';
      case 'rejected_quotes':
        return 'Quote Rejected';
      case 'quotation_sent':
        return 'Quotation Sent';
      case 'parts_not_available':
      case 'parts not available':
        return 'Parts Not Available';
      case 'ready_to_return':
      case 'ready to return':
        return 'Ready To Return';
      case 'completed':
        return 'Completed';
      case 'draft':
        return 'Draft';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'archived':
        return 'Archived';
      default:
        return formatLabel(rawStatus);
    }
  }

  // ─── Notification Data ───────────────────────────────────────────────────

  /// Parses a [Notifications] model and returns a human-readable
  /// `({String title, String text})` record.
  ///
  /// Returns `null` only if the notification has no message at all.
  ///
  /// Mirrors the TypeScript `getNotificationData` helper.
  static ({String title, String text})? notificationData(
    Notifications notification,
  ) {
    final message = notification.message;
    final messageType = notification.messageType;
    final quotationNo = notification.quotationNo;
    final senderName = notification.senderDetails?.name ?? 'Someone';

    // ── Quotation ──────────────────────────────────────────────────────────
    if (messageType == 'quotation') {
      if (message?.contains('has_accepted_quotation_no') == true) {
        return (
          title: '✅ Quotation Accepted',
          text:
              '$senderName has accepted the quote no. ${quotationNo ?? ''}',
        );
      }
      if (message?.contains('has_declined_quotation_no') == true) {
        return (
          title: '❌ Quotation Rejected',
          text:
              '$senderName has declined the quote no. ${quotationNo ?? ''}',
        );
      }
      return (
        title: '📄 Quotation',
        text: '$senderName — Quote no. ${quotationNo ?? ''}',
      );
    }

    // ── Standard message ───────────────────────────────────────────────────
    if ((messageType == 'stanard' || messageType == 'standard') &&
        message?.contains('has sent you a message') == true) {
      return (
        title: '💬 Message from $senderName',
        text: message ?? '',
      );
    }

    // ── Job notification ───────────────────────────────────────────────────
    if (messageType == 'job-notification') {
      final jobNo = notification.conversationId ?? ''; // fallback field
      String title = '🟠 Job Update';
      String text = jobNo.isNotEmpty
          ? 'Job No. $jobNo has been updated'
          : 'A job has been updated';

      if (message?.contains('priority_changed') == true) {
        if (message?.toUpperCase().contains('URGENT') == true) {
          title = '🔴 Job Priority Changed to URGENT';
        } else if (message?.toUpperCase().contains('HIGH') == true) {
          title = '🟠 Job Priority Changed to HIGH';
        } else {
          title = '🔔 Job Priority Changed';
        }
      } else if (message?.contains('is_assigned_to_you') == true) {
        title = '📌 Job Assigned to You';
        text = jobNo.isNotEmpty
            ? 'Job No. $jobNo has been assigned to you'
            : 'A job has been assigned to you';
      } else if (message?.contains('is_unassigned_from_you') == true) {
        title = '📌 Job Unassigned from You';
        text = jobNo.isNotEmpty
            ? 'Job No. $jobNo has been unassigned from you'
            : 'A job has been unassigned from you';
      } else if (message?.contains('job_overdue') == true) {
        title = '⏰ Job Overdue';
        text = jobNo.isNotEmpty
            ? 'Job No. $jobNo is overdue'
            : 'A job is overdue';
      }

      return (title: title, text: text);
    }

    // ── Generic fallback ───────────────────────────────────────────────────
    if (message != null && message.isNotEmpty) {
      return (
        title: '🔔 Notification',
        text: formatLabel(message),
      );
    }

    return null;
  }
}
