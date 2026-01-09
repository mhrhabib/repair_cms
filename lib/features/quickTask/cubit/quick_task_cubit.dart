import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/quickTask/models/quick_task.dart';
import 'package:repair_cms/features/quickTask/repository/quick_task_repository.dart';

part 'quick_task_state.dart';

class QuickTaskCubit extends Cubit<QuickTaskState> {
  final QuickTaskRepository _repository;

  QuickTaskCubit(this._repository) : super(QuickTaskInitial());

  // Get all todos
  Future<void> getTodos() async {
    debugPrint('🔄 [QuickTaskCubit] Getting todos...');
    emit(QuickTaskLoading());
    try {
      final response = await _repository.getTodos(
        userId: storage.read('userId'),
      );
      debugPrint(
        '✅ [QuickTaskCubit] Loaded ${response.length} todos successfully',
      );
      emit(QuickTaskLoaded(response));
    } on QuickTaskException catch (e) {
      debugPrint('❌ [QuickTaskCubit] QuickTaskException: ${e.message}');
      emit(QuickTaskError(e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskCubit] Unexpected error: $e');
      debugPrint('📋 [QuickTaskCubit] Stack trace: $stackTrace');
      emit(QuickTaskError(e.toString()));
    }
  }

  // Get incomplete todos count
  int getIncompleteTodosCount() {
    if (state is QuickTaskLoaded) {
      final loadedState = state as QuickTaskLoaded;
      return loadedState.todos.where((task) => !task.complete!).length;
    }
    return 0;
  }

  // Mark todo as complete
  Future<void> completeTodo(String taskId, Map<String, dynamic> updates) async {
    debugPrint('🔄 [QuickTaskCubit] Completing todo: $taskId');
    try {
      await _repository.completeTodo(taskId, updates);
      debugPrint('✅ [QuickTaskCubit] Todo completed, refreshing list');
      // Refresh the list
      await getTodos();
    } on QuickTaskException catch (e) {
      debugPrint('❌ [QuickTaskCubit] QuickTaskException: ${e.message}');
      emit(QuickTaskError(e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskCubit] Unexpected error: $e');
      debugPrint('📋 [QuickTaskCubit] Stack trace: $stackTrace');
      emit(QuickTaskError(e.toString()));
    }
  }

  // Delete todo
  Future<void> deleteTodo(String taskId) async {
    debugPrint('🔄 [QuickTaskCubit] Deleting todo: $taskId');
    try {
      await _repository.deleteTodo(taskId);
      debugPrint('✅ [QuickTaskCubit] Todo deleted, refreshing list');
      // Refresh the list
      await getTodos();
    } on QuickTaskException catch (e) {
      debugPrint('❌ [QuickTaskCubit] QuickTaskException: ${e.message}');
      emit(QuickTaskError(e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskCubit] Unexpected error: $e');
      debugPrint('📋 [QuickTaskCubit] Stack trace: $stackTrace');
      emit(QuickTaskError(e.toString()));
    }
  }

  // Create new todo
  Future<void> createTodo(Map<String, dynamic> todo) async {
    debugPrint('🔄 [QuickTaskCubit] Creating new todo');
    try {
      await _repository.createTodo(todo);
      debugPrint('✅ [QuickTaskCubit] Todo created, refreshing list');
      // Refresh the list
      await getTodos();
    } on QuickTaskException catch (e) {
      debugPrint('❌ [QuickTaskCubit] QuickTaskException: ${e.message}');
      emit(QuickTaskError(e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [QuickTaskCubit] Unexpected error: $e');
      debugPrint('📋 [QuickTaskCubit] Stack trace: $stackTrace');
      emit(QuickTaskError(e.toString()));
    }
  }
}
