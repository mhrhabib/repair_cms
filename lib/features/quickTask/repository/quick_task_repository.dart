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

  Future<void> completeTodo(String taskId) async {
    dio.Response response = await BaseClient.put(url: ApiEndpoints.completeTodo.replaceAll('<id>', taskId));

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

  Future<void> createTodo(QuickTask todo) async {
    dio.Response response = await BaseClient.post(url: ApiEndpoints.createTodo, payload: todo.toJson());

    if (response.statusCode != 201) {
      throw Exception('Failed to create todo');
    }
  }
}
