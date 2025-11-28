import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/notifications/models/notificaiton_model.dart';

abstract class NotificationRepository {
  Future<List<Notifications>> getNotifications({required String userId});
  Future<void> deleteNotification({required String notificationId});
}

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<Notifications>> getNotifications({required String userId}) async {
    try {
      debugPrint('🚀 [NotificationRepository] Fetching notifications list');
      debugPrint('   📍 URL: ${ApiEndpoints.getAllNotifications.replaceAll('<id>', userId)}');
      debugPrint('   👤 User ID: $userId');

      dio.Response response = await BaseClient.get(url: ApiEndpoints.getAllNotifications.replaceAll('<id>', userId));

      debugPrint('✅ [NotificationRepository] Notifications response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final notifications = (response.data as List).map((json) => Notifications.fromJson(json)).toList();
          debugPrint('   📦 Parsed ${notifications.length} notifications');
          return notifications;
        } else if (response.data is Map) {
          final data = response.data as Map;
          if (data.containsKey('notifications') && data['notifications'] is List) {
            final notifications = (data['notifications'] as List).map((json) => Notifications.fromJson(json)).toList();
            debugPrint('   📦 Parsed ${notifications.length} notifications from "notifications" key');
            return notifications;
          } else if (data.containsKey('data') && data['data'] is List) {
            final notifications = (data['data'] as List).map((json) => Notifications.fromJson(json)).toList();
            debugPrint('   📦 Parsed ${notifications.length} notifications from "data" key');
            return notifications;
          }
        }

        debugPrint('   ⚠️ Unexpected response format: ${response.data}');
        throw NotificationException(message: 'Unexpected response format from server');
      } else {
        throw NotificationException(
          message: 'Failed to load notifications: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [NotificationRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw NotificationException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [NotificationRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw NotificationException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteNotification({required String notificationId}) async {
    try {
      debugPrint('🚀 [NotificationRepository] Deleting notification');
      debugPrint('   📍 URL: ${ApiEndpoints.deleteNotification.replaceAll('<id>', notificationId)}');
      debugPrint('   🗑️ Notification ID: $notificationId');

      dio.Response response = await BaseClient.delete(
        url: ApiEndpoints.deleteNotification.replaceAll('<id>', notificationId),
      );

      debugPrint('✅ [NotificationRepository] Delete notification response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('   ✅ Notification deleted successfully');
        return;
      } else {
        throw NotificationException(
          message: 'Failed to delete notification: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [NotificationRepository] DioException during delete:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw NotificationException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [NotificationRepository] Unexpected error during delete:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw NotificationException(message: 'Unexpected error: $e');
    }
  }
}

class NotificationException implements Exception {
  final String message;
  final int? statusCode;

  NotificationException({required this.message, this.statusCode});

  @override
  String toString() => 'NotificationException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
