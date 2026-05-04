import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/notifications/models/notificaiton_model.dart';

abstract class NotificationRepository {
  Future<List<Notifications>> getNotifications({required String userId});
  Future<void> deleteNotification({required String notificationId});
  Future<void> markAsRead({required String notificationId});
  Future<void> markAllAsRead({required String loginUserId});
  Future<void> deleteAllNotifications({required String loginUserId});
}

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<Notifications>> getNotifications({required String userId}) async {
    try {
      debugPrint('🚀 [NotificationRepository] Fetching notifications list');
      debugPrint(
        '   📍 URL: ${ApiEndpoints.getAllNotifications.replaceAll('<id>', userId)}',
      );
      debugPrint('   👤 User ID: $userId');

      dio.Response response = await BaseClient.get(
        url: ApiEndpoints.getAllNotifications.replaceAll('<id>', userId),
      );

      debugPrint('✅ [NotificationRepository] Notifications response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Handle String response that needs decoding
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('   📄 Response is String, decoding...');
          responseData = jsonDecode(responseData);
        }

        if (responseData is List) {
          final notifications = (responseData)
              .map((json) => Notifications.fromJson(json))
              .toList();
          debugPrint('   📦 Parsed ${notifications.length} notifications');
          return notifications;
        } else if (responseData is Map) {
          final data = responseData;
          if (data.containsKey('notifications') &&
              data['notifications'] is List) {
            final notifications = (data['notifications'] as List)
                .map((json) => Notifications.fromJson(json))
                .toList();
            debugPrint(
              '   📦 Parsed ${notifications.length} notifications from "notifications" key',
            );
            return notifications;
          } else if (data.containsKey('data') && data['data'] is List) {
            final notifications = (data['data'] as List)
                .map((json) => Notifications.fromJson(json))
                .toList();
            debugPrint(
              '   📦 Parsed ${notifications.length} notifications from "data" key',
            );
            return notifications;
          }
        }

        debugPrint('   ⚠️ Unexpected response format: $responseData');
        throw NotificationException(
          message: 'Unexpected response format from server',
        );
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
      throw NotificationException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
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
      debugPrint(
        '   📍 URL: ${ApiEndpoints.deleteNotification.replaceAll('<id>', notificationId)}',
      );
      debugPrint('   🗑️ Notification ID: $notificationId');

      dio.Response response = await BaseClient.delete(
        url: ApiEndpoints.deleteNotification.replaceAll('<id>', notificationId),
      );

      debugPrint(
        '✅ [NotificationRepository] Delete notification response received:',
      );
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
      throw NotificationException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [NotificationRepository] Unexpected error during delete:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw NotificationException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    try {
      debugPrint('🚀 [NotificationRepository] Marking notification as read');
      debugPrint(
        '   📍 URL: ${ApiEndpoints.markNotificationAsRead.replaceAll('<id>', notificationId)}',
      );
      debugPrint('   🔔 Notification ID: $notificationId');

      // Preferred payload: isRead + locationId (if available)
      final storage = GetStorage();
      final locationId = storage.read('locationId');
      final payload = {
        'isRead': true,
        'locationId': ?locationId,
      };

      dio.Response response = await BaseClient.patch(
        url: ApiEndpoints.markNotificationAsRead.replaceAll('<id>', notificationId),
        payload: payload,
      );

      // If server responds with 404, try the alternate '/read' route (some envs use this)
      if (response.statusCode == 404) {
        final altUrl = '${ApiEndpoints.markNotificationAsRead.replaceAll('<id>', notificationId)}/read';
        debugPrint('   ⚠️ Received 404, retrying with alternate URL: $altUrl');
        response = await BaseClient.patch(url: altUrl, payload: payload);
      }

      debugPrint(
        '✅ [NotificationRepository] Mark as read response received:',
      );
      debugPrint('   📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('   ✅ Notification marked as read successfully');
        return;
      } else {
        throw NotificationException(
          message: 'Failed to mark notification as read: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [NotificationRepository] DioException during mark as read:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw NotificationException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [NotificationRepository] Unexpected error during mark as read:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw NotificationException(message: 'Unexpected error: $e');
    }
  }
  
  @override
  Future<void> deleteAllNotifications({required String loginUserId}) {
    try {
      debugPrint('🚀 [NotificationRepository] Deleting all notifications for user: $loginUserId');
      final url = ApiEndpoints.deleteAllNotifications.replaceAll('<id>', loginUserId);
      debugPrint('   📍 URL: $url');

      return BaseClient.delete(url: url).then((response) {
        debugPrint('✅ [NotificationRepository] Delete all response status: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 204) return;
        throw NotificationException(
          message: 'Failed to delete all notifications: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      });
    } catch (e) {
      debugPrint('💥 [NotificationRepository] Unexpected error during deleteAllNotifications: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> markAllAsRead({required String loginUserId}) {
    try {
      debugPrint('🚀 [NotificationRepository] Marking all notifications as read for user: $loginUserId');
       
      final payload = {
        
      };

      final url = ApiEndpoints.markAllAsRead.replaceAll('<id>', loginUserId);
      debugPrint('   📍 URL: $url');

      return BaseClient.patch(url: url, payload: payload).then((response) async {
        debugPrint('✅ [NotificationRepository] Mark all as read response status: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 204) return;
        // Some envs may return 404 for this route; surface as exception
        throw NotificationException(
          message: 'Failed to mark all as read: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      });
    } catch (e) {
      debugPrint('💥 [NotificationRepository] Unexpected error during markAllAsRead: $e');
      rethrow;
    }
  }


  // Additional methods for marking all as read and deleting all notifications can be implemented similarly, following the same pattern of detailed logging and error handling.


}

class NotificationException implements Exception {
  final String message;
  final int? statusCode;

  NotificationException({required this.message, this.statusCode});

  @override
  String toString() =>
      'NotificationException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
