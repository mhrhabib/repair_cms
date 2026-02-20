import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';
import 'package:repair_cms/set_up_di.dart';

/// Service for managing Firebase Cloud Messaging (FCM).
/// Handles permissions, token retrieval, and message handling.
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _isInitialized = false;

  /// Initialize the Firebase Messaging service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ [FirebaseNotificationService] Already initialized');
      return;
    }

    try {
      // Request permissions for iOS and Android 13+
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '📱 [FirebaseNotificationService] User granted permission: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Tell iOS to show notification banners even when app is in foreground
        await _fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // On iOS, we need to wait for the APNS token before getting FCM token
        await _retrieveFCMToken();

        // Listen for token refreshes (handles cases where initial token wasn't available)
        _fcm.onTokenRefresh.listen((newToken) {
          debugPrint(
            '🔄 [FirebaseNotificationService] FCM Token refreshed: $newToken',
          );
          // To be implemented: Send updated token to your backend
        });

        // Set up foreground message handler
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Set up background/terminated message handler (when app is opened via notification)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        _isInitialized = true;
        debugPrint('✅ [FirebaseNotificationService] Initialized successfully');
      }
    } catch (e) {
      debugPrint('❌ [FirebaseNotificationService] Initialization error: $e');
    }
  }

  /// Retrieve FCM token, waiting for APNS token on iOS if needed
  Future<void> _retrieveFCMToken() async {
    // On iOS, the APNS token may not be ready immediately after permission is granted.
    // We retry a few times with a delay to allow the system to register the APNS token.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apnsToken;
      for (int attempt = 1; attempt <= 5; attempt++) {
        apnsToken = await _fcm.getAPNSToken();
        if (apnsToken != null) {
          debugPrint(
            '✅ [FirebaseNotificationService] APNS token ready (attempt $attempt)',
          );
          break;
        }
        debugPrint(
          '⏳ [FirebaseNotificationService] APNS token not ready, retrying ($attempt/5)...',
        );
        await Future.delayed(Duration(seconds: attempt)); // Progressive backoff
      }

      if (apnsToken == null) {
        debugPrint(
          '⚠️ [FirebaseNotificationService] APNS token still not available after retries. '
          'FCM token will be retrieved on next token refresh.',
        );
        return;
      }
    }

    try {
      String? token = await _fcm.getToken();
      debugPrint('🔑 [FirebaseNotificationService] FCM Token: $token');
      // To be implemented: Send token to your backend
    } catch (e) {
      debugPrint(
        '⚠️ [FirebaseNotificationService] Could not get FCM token: $e. '
        'Will be retrieved on token refresh.',
      );
    }
  }

  /// Handle messages received while the app is in the foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      '📩 [FirebaseNotificationService] Foreground message received: ${message.messageId}',
    );
    debugPrint(
      'Title: ${message.notification?.title}, Body: ${message.notification?.body}',
    );
    debugPrint('Data: ${message.data}');

    // If there's a notification object, show a local notification
    if (message.notification != null) {
      final localNotify = SetUpDI.getIt<LocalNotificationService>();

      // Extract data for navigation if present
      final conversationId = message.data['conversationId']?.toString();
      final jobId = message.data['jobId']?.toString();

      // You might want to customize how specific types of notifications are shown
      localNotify.showMessageNotification(
        senderName: message.notification?.title ?? 'New Notification',
        messageText: message.notification?.body ?? '',
        conversationId: conversationId ?? '',
        jobId: jobId,
      );
    }
  }

  /// Handle messages that opened the app from background/terminated state
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint(
      '🚀 [FirebaseNotificationService] App opened via notification: ${message.messageId}',
    );

    final conversationId = message.data['conversationId']?.toString();
    final jobId = message.data['jobId']?.toString();

    if (conversationId != null) {
      debugPrint(
        '🚀 [FirebaseNotificationService] Navigating to: $conversationId, Job: $jobId',
      );
      // Trigger navigation via LocalNotificationService's logic
      SetUpDI.getIt<LocalNotificationService>().showMessageNotification(
        senderName: 'Opening...',
        messageText: 'Navigating to conversation',
        conversationId: conversationId,
        jobId: jobId,
      );
    }
  }

  /// Get the current FCM token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}

/// Top-level background message handler for FCM
/// This must be a top-level function (not a class member)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // It's recommended to initialize Firebase if you need to use its services here
  // await Firebase.initializeApp();
  debugPrint('🌙 [FCM] Background message received: ${message.messageId}');
}
