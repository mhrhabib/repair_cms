import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Callback type for handling notification navigation
typedef NotificationNavigationCallback = void Function(String conversationId, String? jobId);

/// Service for managing local notifications throughout the app.
/// Handles initialization, permission requests, and showing notifications.
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Navigation callback for handling notification taps
  /// Set this from your app's navigation context
  NotificationNavigationCallback? _onNavigateToConversation;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ [LocalNotificationService] Already initialized');
      return;
    }

    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initializationSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _notifications.initialize(initializationSettings, onDidReceiveNotificationResponse: _onNotificationTapped);

      _isInitialized = true;
      debugPrint('✅ [LocalNotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('❌ [LocalNotificationService] Initialization error: $e');
    }
  }

  /// Set the callback for handling navigation when notifications are tapped
  /// This should be called from your app's main context where navigation is available
  void setNavigationCallback(NotificationNavigationCallback callback) {
    _onNavigateToConversation = callback;
    debugPrint('✅ [LocalNotificationService] Navigation callback registered');
  }

  /// Request notification permissions (iOS specific, Android auto-grants)
  Future<bool> requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        debugPrint('📱 [LocalNotificationService] iOS permissions granted: $granted');
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        // Request POST_NOTIFICATIONS permission for Android 13+
        final bool? granted = await androidImplementation?.requestNotificationsPermission();
        debugPrint('🤖 [LocalNotificationService] Android permissions granted: $granted');
        return granted ?? true; // true for Android < 13
      }
      return true;
    } catch (e) {
      debugPrint('❌ [LocalNotificationService] Permission request error: $e');
      return false;
    }
  }

  /// Show a notification for a new message
  Future<void> showMessageNotification({
    required String senderName,
    required String messageText,
    required String conversationId,
    String? jobId,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ [LocalNotificationService] Not initialized, skipping notification');
      return;
    }

    try {
      // Create unique notification ID based on conversation
      final notificationId = conversationId.hashCode;

      // Android notification details
      const androidDetails = AndroidNotificationDetails(
        'messages_channel', // Channel ID
        'Messages', // Channel name
        channelDescription: 'Notifications for new messages',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/notification_icon',
        enableVibration: true,
        playSound: true,
        ticker: 'New message',
        styleInformation: BigTextStyleInformation(''),
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      // Truncate message if too long
      final displayMessage = messageText.length > 100 ? '${messageText.substring(0, 100)}...' : messageText;

      await _notifications.show(
        notificationId,
        senderName,
        displayMessage,
        notificationDetails,
        payload: 'conversation:$conversationId${jobId != null ? '|job:$jobId' : ''}',
      );

      debugPrint('🔔 [LocalNotificationService] Notification shown: $senderName - $displayMessage');
    } catch (e) {
      debugPrint('❌ [LocalNotificationService] Error showing notification: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('🔕 [LocalNotificationService] Cancelled notification: $id');
    } catch (e) {
      debugPrint('❌ [LocalNotificationService] Error canceling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🔕 [LocalNotificationService] All notifications cancelled');
    } catch (e) {
      debugPrint('❌ [LocalNotificationService] Error canceling all notifications: $e');
    }
  }

  /// Handle notification tap (when user taps on notification)
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('👆 [LocalNotificationService] Notification tapped: $payload');

    if (payload != null) {
      // Parse payload to navigate to conversation
      // Format: "conversation:<conversationId>|job:<jobId>"
      _handleNotificationPayload(payload);
    }
  }

  /// Handle notification payload and navigate accordingly
  void _handleNotificationPayload(String payload) {
    try {
      // Parse the payload
      final parts = payload.split('|');
      String? conversationId;
      String? jobId;

      for (final part in parts) {
        if (part.startsWith('conversation:')) {
          conversationId = part.replaceFirst('conversation:', '');
        } else if (part.startsWith('job:')) {
          jobId = part.replaceFirst('job:', '');
        }
      }

      if (conversationId != null) {
        debugPrint('🚀 [LocalNotificationService] Navigate to conversation: $conversationId (job: $jobId)');

        // Use the callback to navigate if it's set
        if (_onNavigateToConversation != null) {
          _onNavigateToConversation!(conversationId, jobId);
        } else {
          debugPrint(
            '⚠️ [LocalNotificationService] Navigation callback not set. Call setNavigationCallback() from your app.',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [LocalNotificationService] Error parsing payload: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation = _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidImplementation?.areNotificationsEnabled() ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosImplementation = _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final settings = await iosImplementation?.requestPermissions();
        return settings ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('❌ [LocalNotificationService] Error checking notification status: $e');
      return false;
    }
  }
}
