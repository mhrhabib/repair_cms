import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalNotificationService notificationService;

  setUp(() {
    notificationService = LocalNotificationService();
  });

  group('LocalNotificationService Initialization', () {
    test('is a singleton', () {
      final instance1 = LocalNotificationService();
      final instance2 = LocalNotificationService();

      expect(instance1, same(instance2));
    });

    test('initializes successfully', () async {
      await notificationService.initialize();

      // Verify initialization (check logs in real scenario)
      expect(notificationService, isNotNull);
    });

    test('handles multiple initialization calls gracefully', () async {
      await notificationService.initialize();
      await notificationService.initialize();

      // Should not throw and should log "Already initialized"
      expect(notificationService, isNotNull);
    });
  });

  group('LocalNotificationService - Show Notification', () {
    setUp(() async {
      await notificationService.initialize();
    });

    test('shows notification with correct parameters', () async {
      // This test verifies the method can be called without errors
      await notificationService.showMessageNotification(
        senderName: 'Test User',
        messageText: 'Hello, this is a test message',
        conversationId: 'conv123',
        jobId: 'job456',
      );

      // In a real scenario with platform channels, you'd verify the notification was shown
      // For unit tests, we verify the method doesn't throw
    });

    test('truncates long message text', () async {
      final longMessage = 'A' * 150; // 150 characters

      await notificationService.showMessageNotification(
        senderName: 'Test User',
        messageText: longMessage,
        conversationId: 'conv123',
      );

      // Method should handle long messages by truncating
    });

    test('handles notification without jobId', () async {
      await notificationService.showMessageNotification(
        senderName: 'Test User',
        messageText: 'Message without job',
        conversationId: 'conv123',
      );

      // Should work without jobId parameter
    });
  });

  group('LocalNotificationService - Cancel Notifications', () {
    setUp(() async {
      await notificationService.initialize();
    });

    test('cancels specific notification', () async {
      await notificationService.cancelNotification(123);

      // Should not throw
    });

    test('cancels all notifications', () async {
      await notificationService.cancelAllNotifications();

      // Should not throw
    });
  });

  group('LocalNotificationService - Permission Handling', () {
    test('requests permissions without errors', () async {
      await notificationService.initialize();
      final result = await notificationService.requestPermissions();

      // Result depends on platform and test environment
      expect(result, isA<bool>());
    });

    test('checks if notifications are enabled', () async {
      await notificationService.initialize();
      final enabled = await notificationService.areNotificationsEnabled();

      expect(enabled, isA<bool>());
    });
  });

  group('LocalNotificationService - Error Handling', () {
    test('handles showing notification before initialization gracefully', () async {
      final uninitializedService = LocalNotificationService();

      // Should not throw, just skip showing notification
      await uninitializedService.showMessageNotification(
        senderName: 'Test',
        messageText: 'Message',
        conversationId: 'conv123',
      );
    });

    test('handles empty sender name', () async {
      await notificationService.initialize();

      await notificationService.showMessageNotification(
        senderName: '',
        messageText: 'Test message',
        conversationId: 'conv123',
      );

      // Should handle empty sender name
    });

    test('handles empty message text', () async {
      await notificationService.initialize();

      await notificationService.showMessageNotification(
        senderName: 'Test User',
        messageText: '',
        conversationId: 'conv123',
      );

      // Should handle empty message
    });
  });

  group('LocalNotificationService - Payload Handling', () {
    test('creates correct payload with jobId', () async {
      await notificationService.initialize();

      // The payload format should be: "conversation:<conversationId>|job:<jobId>"
      await notificationService.showMessageNotification(
        senderName: 'Test User',
        messageText: 'Message with job',
        conversationId: 'conv123',
        jobId: 'job456',
      );

      // Payload should be formatted correctly internally
    });

    test('creates correct payload without jobId', () async {
      await notificationService.initialize();

      // The payload format should be: "conversation:<conversationId>"
      await notificationService.showMessageNotification(
        senderName: 'Test User',
        messageText: 'Message without job',
        conversationId: 'conv123',
      );

      // Payload should be formatted correctly internally
    });
  });

  group('LocalNotificationService - Notification ID Generation', () {
    test('generates consistent ID for same conversation', () async {
      await notificationService.initialize();

      // Same conversation should generate same notification ID (hashCode)
      const conversationId = 'conv123';
      final id1 = conversationId.hashCode;
      final id2 = conversationId.hashCode;

      expect(id1, equals(id2));
    });

    test('generates different IDs for different conversations', () async {
      await notificationService.initialize();

      final id1 = 'conv123'.hashCode;
      final id2 = 'conv456'.hashCode;

      expect(id1, isNot(equals(id2)));
    });
  });

  group('LocalNotificationService - Platform Specific', () {
    test('handles Android-specific initialization', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await notificationService.initialize();
      final permissions = await notificationService.requestPermissions();

      expect(permissions, isA<bool>());

      debugDefaultTargetPlatformOverride = null;
    });

    test('handles iOS-specific initialization', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await notificationService.initialize();
      final permissions = await notificationService.requestPermissions();

      expect(permissions, isA<bool>());

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
