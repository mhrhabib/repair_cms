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
    emit(QuickTaskLoading());
    try {
      final response = await _repository.getTodos(userId: storage.read('userId'));
      emit(QuickTaskLoaded(response));
    } catch (e) {
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
    try {
      await _repository.completeTodo(taskId, updates);
      // Refresh the list
      await getTodos();
    } catch (e) {
      emit(QuickTaskError(e.toString()));
    }
  }

  // Delete todo
  Future<void> deleteTodo(String taskId) async {
    try {
      await _repository.deleteTodo(taskId);
      // Refresh the list
      await getTodos();
    } catch (e) {
      emit(QuickTaskError(e.toString()));
    }
  }

  // Create new todo
  Future<void> createTodo(Map<String, dynamic> todo) async {
    try {
      await _repository.createTodo(todo);
      // Refresh the list
      await getTodos();
    } catch (e) {
      emit(QuickTaskError(e.toString()));
    }
  }
}
