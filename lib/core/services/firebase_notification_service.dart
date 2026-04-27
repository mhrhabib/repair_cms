import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';
import 'package:repair_cms/features/notifications/repository/fcm_token_repository.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/firebase_options.dart';
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
        // Suppress iOS's built-in foreground presentation — we show our own
        // local notification in _handleForegroundMessage so the user can tap
        // it and trigger navigation. Leaving this on causes duplicate banners.
        await _fcm.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );

        // On iOS, we need to wait for the APNS token before getting FCM token
        await _retrieveFCMToken();

        // Listen for token refreshes (handles cases where initial token wasn't available)
        _fcm.onTokenRefresh.listen((newToken) async {
          debugPrint(
            '🔄 [FirebaseNotificationService] FCM Token refreshed: $newToken',
          );
          await _syncTokenToBackend(newToken);
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
      if (token != null) {
        await _syncTokenToBackend(token);
      }
    } catch (e) {
      debugPrint(
        '⚠️ [FirebaseNotificationService] Could not get FCM token: $e. '
        'Will be retrieved on token refresh.',
      );
    }
  }

  /// Sync FCM token to the backend
  Future<void> _syncTokenToBackend(String token) async {
    try {
      // REQUIREMENT: Only call the sync API if the user is authenticated.
      final authToken = storage.read('token');
      if (authToken == null) {
        debugPrint(
          '⏭️ [FirebaseNotificationService] Skipping FCM sync: User not authenticated',
        );
        return;
      }

      debugPrint(
        '⬆️ [FirebaseNotificationService] Syncing FCM token to backend...',
      );
      final fcmRepo = SetUpDI.getIt<FcmTokenRepository>();
      await fcmRepo.registerToken(token: token);
      debugPrint(
        '✅ [FirebaseNotificationService] FCM token synced successfully',
      );
    } catch (e) {
      debugPrint(
        '❌ [FirebaseNotificationService] Failed to sync FCM token: $e',
      );
    }
  }

  /// Manually trigger FCM token synchronization with the backend.
  /// Typically called after successful login or during app startup if already logged in.
  Future<void> syncToken() async {
    final token = await getToken();
    if (token != null) {
      await _syncTokenToBackend(token);
    }
  }

  /// Handle messages received while the app is in the foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      '📩 [FirebaseNotificationService] Foreground message received: ${message.messageId}',
    );
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
    debugPrint('   Data: ${message.data}');

    final localNotify = SetUpDI.getIt<LocalNotificationService>();

    // Prefer the standard notification payload, but support data-only messages
    final senderName =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'RepairCMS';
    final messageText =
        message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';
    final conversationId = message.data['conversationId']?.toString() ?? '';
    final jobNo = message.data['jobNo']?.toString();
    final type = message.data['type']?.toString();
    final action = message.data['action']?.toString();
    final notifMessage = message.data['message']?.toString();

    // Only show a local notification if there's something to display
    if ((message.notification != null) || messageText.isNotEmpty) {
      debugPrint(
        '🔔 [FirebaseNotificationService] Showing local notification for foreground message',
      );
      localNotify.showMessageNotification(
        senderName: senderName,
        messageText: messageText,
        conversationId: conversationId,
        jobNo: jobNo,
        type: type,
        action: action,
        notifMessage: notifMessage,
      );
    } else {
      debugPrint(
        '⚠️ [FirebaseNotificationService] Foreground message has no notification payload or displayable body in data',
      );
    }
  }

  /// Handle messages that opened the app from background/terminated state
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint(
      '🚀 [FirebaseNotificationService] App opened via notification: ${message.messageId}',
    );

    final conversationId = message.data['conversationId']?.toString() ?? '';
    final jobNo = message.data['jobNo']?.toString();
    final type = message.data['type']?.toString();
    final action = message.data['action']?.toString();
    final notifMessage = message.data['message']?.toString();

    debugPrint(
      '🚀 [FirebaseNotificationService] Deep link → conversation:$conversationId job:$jobNo type:$type action:$action',
    );

    SetUpDI.getIt<LocalNotificationService>().showMessageNotification(
      senderName: '',
      messageText: '',
      conversationId: conversationId,
      jobNo: jobNo,
      type: type,
      action: action,
      notifMessage: notifMessage,
    );
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
  // Background isolate spawns fresh — Firebase must be re-initialized
  // before any FCM services can be used here.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  debugPrint('🌙 [FCM] Background message received: ${message.messageId}');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');
}
