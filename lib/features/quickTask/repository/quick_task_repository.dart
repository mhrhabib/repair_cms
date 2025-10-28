import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/quickTask/models/quick_task.dart';

class QuickTaskRepository {
  Future<List<Task>> getTodos({required String userId}) async {
    dio.Response response = await BaseClient.get(url: ApiEndpoints.getAllQuickTasks.replaceAll('<id>', userId));

    if (response.statusCode == 200) {
      final data = QuickTask.fromJson(response.data);
      return data.data!.map((task) => task).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<void> completeTodo(String taskId, Map<String, dynamic> updates) async {
    dio.Response response = await BaseClient.patch(
      url: ApiEndpoints.completeTodo.replaceAll('<id>', taskId),
      payload: updates,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete todo');
    }
  }

  Future<void> deleteTodo(String taskId) async {
    dio.Response response = await BaseClient.delete(url: ApiEndpoints.deleteTodo.replaceAll('<id>', taskId));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }

  Future<void> createTodo(Map<String, dynamic> todo) async {
    try {
      dio.Response response = await BaseClient.post(url: ApiEndpoints.createTodo, payload: todo);

      print(response.data);

      if (response.statusCode == 201) {
        return response.data;
      }

      if (response.statusCode != 201) {
        throw Exception('Failed to create todo');
      }
    } catch (e, trace) {
      print('Error creating todo: $e');
      print('Stack trace: $trace');
      throw Exception('Failed to create todo');
    }
  }
}
