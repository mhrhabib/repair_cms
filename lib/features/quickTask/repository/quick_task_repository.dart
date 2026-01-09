import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/rendering.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/quickTask/models/quick_task.dart';

class QuickTaskException implements Exception {
  final String message;
  final int? statusCode;

  QuickTaskException({required this.message, this.statusCode});

  @override
  String toString() => 'QuickTaskException: $message';
}

class QuickTaskRepository {
  Future<List<Task>> getTodos({required String userId}) async {
    debugPrint('🚀 [QuickTaskRepository] Fetching todos for user: $userId');
    try {
      final url = ApiEndpoints.getAllQuickTasks.replaceAll('<id>', userId);
      debugPrint('🌐 [QuickTaskRepository] API endpoint: $url');

      dio.Response response = await BaseClient.get(url: url);
      debugPrint(
        '📊 [QuickTaskRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Handle JSON string parsing
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint(
            '🔄 [QuickTaskRepository] Response is String, parsing JSON...',
          );
          jsonData = jsonDecode(response.data as String);
        }
        final data = QuickTask.fromJson(jsonData);
        debugPrint(
          '✅ [QuickTaskRepository] Fetched ${data.data?.length ?? 0} todos successfully',
        );
        return data.data!.map((task) => task).toList();
      } else {
        debugPrint(
          '❌ [QuickTaskRepository] Failed with status: ${response.statusCode}',
        );
        throw QuickTaskException(
          message: 'Failed to load todos',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [QuickTaskRepository] DioException: ${e.type}');
      debugPrint('📍 [QuickTaskRepository] Error details: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '📊 [QuickTaskRepository] Response status: ${e.response?.statusCode}',
        );
        throw QuickTaskException(
          message: 'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw QuickTaskException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskRepository] Unexpected error: $e');
      debugPrint('📋 [QuickTaskRepository] Stack trace: $stackTrace');
      throw QuickTaskException(message: 'Unexpected error: $e');
    }
  }

  Future<void> completeTodo(String taskId, Map<String, dynamic> updates) async {
    debugPrint('🚀 [QuickTaskRepository] Completing todo: $taskId');
    debugPrint('📝 [QuickTaskRepository] Updates: $updates');
    try {
      final url = ApiEndpoints.completeTodo.replaceAll('<id>', taskId);
      debugPrint('🌐 [QuickTaskRepository] API endpoint: $url');

      dio.Response response = await BaseClient.patch(
        url: url,
        payload: updates,
      );
      debugPrint(
        '📊 [QuickTaskRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [QuickTaskRepository] Todo completed successfully');
      } else {
        debugPrint(
          '❌ [QuickTaskRepository] Failed with status: ${response.statusCode}',
        );
        throw QuickTaskException(
          message: 'Failed to complete todo',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [QuickTaskRepository] DioException: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '📊 [QuickTaskRepository] Response status: ${e.response?.statusCode}',
        );
        throw QuickTaskException(
          message: 'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw QuickTaskException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskRepository] Unexpected error: $e');
      debugPrint('📋 [QuickTaskRepository] Stack trace: $stackTrace');
      throw QuickTaskException(message: 'Unexpected error: $e');
    }
  }

  Future<void> deleteTodo(String taskId) async {
    debugPrint('🚀 [QuickTaskRepository] Deleting todo: $taskId');
    try {
      final url = ApiEndpoints.deleteTodo.replaceAll('<id>', taskId);
      debugPrint('🌐 [QuickTaskRepository] API endpoint: $url');

      dio.Response response = await BaseClient.delete(url: url);
      debugPrint(
        '📊 [QuickTaskRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [QuickTaskRepository] Todo deleted successfully');
      } else {
        debugPrint(
          '❌ [QuickTaskRepository] Failed with status: ${response.statusCode}',
        );
        throw QuickTaskException(
          message: 'Failed to delete todo',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [QuickTaskRepository] DioException: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '📊 [QuickTaskRepository] Response status: ${e.response?.statusCode}',
        );
        throw QuickTaskException(
          message: 'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw QuickTaskException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskRepository] Unexpected error: $e');
      debugPrint('📋 [QuickTaskRepository] Stack trace: $stackTrace');
      throw QuickTaskException(message: 'Unexpected error: $e');
    }
  }

  Future<void> createTodo(Map<String, dynamic> todo) async {
    debugPrint('🚀 [QuickTaskRepository] Creating new todo');
    debugPrint('📝 [QuickTaskRepository] Todo data: $todo');
    try {
      final url = ApiEndpoints.createTodo;
      debugPrint('🌐 [QuickTaskRepository] API endpoint: $url');

      dio.Response response = await BaseClient.post(url: url, payload: todo);
      debugPrint(
        '📊 [QuickTaskRepository] Response status: ${response.statusCode}',
      );
      debugPrint('📊 [QuickTaskRepository] Response data: ${response.data}');

      if (response.statusCode == 201) {
        debugPrint('✅ [QuickTaskRepository] Todo created successfully');
        return;
      } else {
        debugPrint(
          '❌ [QuickTaskRepository] Failed with status: ${response.statusCode}',
        );
        throw QuickTaskException(
          message: 'Failed to create todo',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [QuickTaskRepository] DioException: ${e.type}');
      debugPrint('📍 [QuickTaskRepository] Error details: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '📊 [QuickTaskRepository] Response status: ${e.response?.statusCode}',
        );
        throw QuickTaskException(
          message: 'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw QuickTaskException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskRepository] Unexpected error: $e');
      debugPrint('📋 [QuickTaskRepository] Stack trace: $stackTrace');
      throw QuickTaskException(message: 'Unexpected error: $e');
    }
  }
}
