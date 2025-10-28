import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/constants/app_typography.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/quickTask/cubit/quick_task_cubit.dart';
import 'package:repair_cms/features/quickTask/models/quick_task.dart';

class QuickTaskScreen extends StatefulWidget {
  const QuickTaskScreen({Key? key}) : super(key: key);

  @override
  State<QuickTaskScreen> createState() => _QuickTaskScreenState();
}

class _QuickTaskScreenState extends State<QuickTaskScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuickTaskCubit>().getTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do\'s', style: AppTypography.fontSize20.copyWith(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 24.sp),
            onPressed: _showAddTodoDialog,
          ),
        ],
      ),
      body: BlocBuilder<QuickTaskCubit, QuickTaskState>(
        builder: (context, state) {
          if (state is QuickTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuickTaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16.h),
                  ElevatedButton(onPressed: () => context.read<QuickTaskCubit>().getTodos(), child: Text('Retry')),
                ],
              ),
            );
          }

          if (state is QuickTaskLoaded) {
            final todos = state.todos;
            final incompleteTodos = todos.where((task) => !task.complete!).toList();
            final completedTodos = todos.where((task) => task.complete!).toList();

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    // padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.lightFontColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8.r)),
                      labelColor: AppColors.whiteColor,
                      unselectedLabelColor: AppColors.borderColor,
                      tabs: [
                        Container(
                          margin: EdgeInsets.only(top: 4.h, bottom: 4.h),
                          padding: const EdgeInsets.all(8.0),
                          child: Tab(text: 'Incomplete (${incompleteTodos.length})'),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4.h, bottom: 4.h),
                          padding: const EdgeInsets.all(8.0),
                          child: Tab(text: 'Completed (${completedTodos.length})'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [_buildTodoList(incompleteTodos, false), _buildTodoList(completedTodos, true)],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTodoList(List<Task> todos, bool isCompleted) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/empty_todos.svg', width: 120.w, height: 120.h),
            SizedBox(height: 16.h),
            Text(
              isCompleted ? 'No completed tasks' : 'No incomplete tasks',
              style: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final task = todos[index];
        return _buildTodoItem(task, isCompleted);
      },
    );
  }

  Widget _buildTodoItem(Task task, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              if (!isCompleted) {
                context.read<QuickTaskCubit>().completeTodo(task.sId!, {'complete': true, 'title': task.title});
              }
            },
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : AppColors.whiteColor,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: isCompleted ? AppColors.primary : AppColors.borderColor),
              ),
              child: isCompleted ? Icon(Icons.check, color: AppColors.whiteColor, size: 16.sp) : null,
            ),
          ),
          SizedBox(width: 12.w),
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? '',
                  style: AppTypography.fontSize16.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isCompleted ? AppColors.lightFontColor : AppColors.fontMainColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDateTime(task.createdAt),
                  style: AppTypography.fontSize12.copyWith(color: AppColors.lightFontColor),
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            onPressed: () => _showDeleteDialog(task),
            icon: Icon(Icons.delete_outline, color: AppColors.warningColor, size: 20.sp),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';

    final parsedDate = DateTime.tryParse(dateTime);
    if (parsedDate == null) return '';

    final now = DateTime.now();
    final difference = now.difference(parsedDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        return AlertDialog(
          title: Text('Add New To-Do'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter your to-do...',
              hintStyle: TextStyle(color: AppColors.lightFontColor),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  context.read<QuickTaskCubit>().createTodo({
                    'title': textController.text.trim(),
                    'complete': false,
                    'dateTime': DateTime.now().toIso8601String(),
                    'createdBy': storage.read('fullName'),
                    'createdAt': DateTime.now().toIso8601String(),
                    'userId': storage.read('userId'),
                    'send': false,
                    'email': storage.read('email'),
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete To-Do'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<QuickTaskCubit>().deleteTodo(task.sId!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warningColor),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
