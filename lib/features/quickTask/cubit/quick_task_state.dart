part of 'quick_task_cubit.dart';

abstract class QuickTaskState {
  const QuickTaskState();
}

class QuickTaskInitial extends QuickTaskState {}

class QuickTaskLoading extends QuickTaskState {}

class QuickTaskLoaded extends QuickTaskState {
  final List<Task> todos;
  const QuickTaskLoaded(this.todos);
}

class QuickTaskError extends QuickTaskState {
  final String message;
  const QuickTaskError(this.message);
}
