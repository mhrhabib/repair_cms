import 'package:flutter/cupertino.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/core/utils/widgets/custom_text_button.dart';
import 'package:repair_cms/features/quickTask/cubit/quick_task_cubit.dart';
import 'package:repair_cms/features/quickTask/models/quick_task.dart';

class QuickTaskScreen extends StatefulWidget {
  const QuickTaskScreen({super.key});

  @override
  State<QuickTaskScreen> createState() => _QuickTaskScreenState();
}

class _QuickTaskScreenState extends State<QuickTaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          debugPrint('🔄 [QuickTaskScreen] Loading todos');
          context.read<QuickTaskCubit>().getTodos();
        } catch (e) {
          debugPrint('❌ [QuickTaskScreen] Error loading todos: $e');
        }
      }
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging && mounted) {
      try {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      } catch (e) {
        debugPrint('❌ [QuickTaskScreen] Error updating tab index: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        middle: Text(
          'To-Do\'s',
          style: AppTypography.fontSize20.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.fontMainColor,
          ),
        ),
        leading: CustomNavButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CupertinoIcons.back,
        ),

        trailing: CustomTextButton(
          text: 'Add',
          textColor: AppColors.fontSecondaryColor,
          onPressed: _showAddTodoDialog,
          // backgroundColor: Colors.blue.shade200,
        ),
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
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.warningColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Something went wrong',
                    style: AppTypography.fontSize16.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Error: ${state.message}',
                    style: AppTypography.fontSize14.copyWith(
                      color: AppColors.lightFontColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => context.read<QuickTaskCubit>().getTodos(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: AppTypography.fontSize14.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is QuickTaskLoaded) {
            final todos = state.todos;
            final incompleteTodos = todos
                .where((task) => !task.complete!)
                .toList();
            final completedTodos = todos
                .where((task) => task.complete!)
                .toList();

            return Column(
              children: [
                // Custom Tab Bar
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightFontColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildCustomTab(
                        index: 0,
                        label: 'Incomplete',
                        count: incompleteTodos.length,
                        isActive: _currentTabIndex == 0,
                      ),
                      _buildCustomTab(
                        index: 1,
                        label: 'Completed',
                        count: completedTodos.length,
                        isActive: _currentTabIndex == 1,
                      ),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentTabIndex == 0
                        ? _buildTodoList(incompleteTodos, false)
                        : _buildTodoList(completedTodos, true),
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCustomTab({
    required int index,
    required String label,
    required int count,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!mounted) return;
          try {
            debugPrint('🔄 [QuickTaskScreen] Switching to tab $index');
            _tabController.animateTo(index);
            setState(() {
              _currentTabIndex = index;
            });
          } catch (e) {
            debugPrint('❌ [QuickTaskScreen] Error switching tab: $e');
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.fontSize14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.whiteColor
                      : AppColors.lightFontColor,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.whiteColor.withValues(alpha: .2)
                      : AppColors.lightFontColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  count.toString(),
                  style: AppTypography.fontSize12.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.whiteColor
                        : AppColors.lightFontColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Task> todos, bool isCompleted) {
    if (todos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/empty_todos.svg',
                width: 150.w,
                height: 150.h,
                colorFilter: ColorFilter.mode(
                  AppColors.lightFontColor.withValues(alpha: 0.5),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                isCompleted ? 'No completed tasks yet' : 'No tasks to do',
                style: AppTypography.fontSize20.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.fontMainColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isCompleted
                    ? 'Tasks you complete will appear here'
                    : 'Add a new task to get started',
                style: AppTypography.fontSize14.copyWith(
                  color: AppColors.lightFontColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              if (!isCompleted)
                ElevatedButton(
                  onPressed: _showAddTodoDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'Add Your First Task',
                    style: AppTypography.fontSize14.copyWith(
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final task = todos[index];
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _buildTodoItem(task, isCompleted),
        );
      },
    );
  }

  Widget _buildTodoItem(Task task, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: ShapeDecoration(
        color: AppColors.kCardBg,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 28.r,
            cornerSmoothing: 1.0,
          ),
          side: BorderSide(color: AppColors.borderColor),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Checkbox
          GestureDetector(
            onTap: () {
              if (!mounted) return;
              if (!isCompleted) {
                try {
                  debugPrint(
                    '✅ [QuickTaskScreen] Completing todo: ${task.sId}',
                  );
                  context.read<QuickTaskCubit>().completeTodo(task.sId!, {
                    'complete': true,
                    'title': task.title,
                  });
                } catch (e) {
                  debugPrint('❌ [QuickTaskScreen] Error completing todo: $e');
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24.w,
              height: 24.h,
              decoration: ShapeDecoration(
                color: isCompleted ? AppColors.primary : AppColors.whiteColor,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 8.r,
                    cornerSmoothing: 1.0,
                  ),
                  side: BorderSide(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.borderColor,
                    width: 2,
                  ),
                ),
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: AppColors.whiteColor, size: 16.sp)
                  : null,
            ),
          ),

          SizedBox(width: 16.w),

          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? '',
                  style: AppTypography.fontSize16.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted
                        ? AppColors.lightFontColor
                        : AppColors.fontMainColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.sp,
                      color: AppColors.lightFontColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDateTime(task.createdAt),
                      style: AppTypography.fontSize12.copyWith(
                        color: AppColors.lightFontColor,
                      ),
                    ),
                    if (task.createdBy != null) ...[
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.person,
                        size: 12.sp,
                        color: AppColors.lightFontColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        task.createdBy!,
                        style: AppTypography.fontSize12.copyWith(
                          color: AppColors.lightFontColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Delete button with better styling
          Container(
            decoration: ShapeDecoration(
              color: AppColors.warningColor.withValues(alpha: 0.1),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 8.r,
                  cornerSmoothing: 1.0,
                ),
              ),
            ),
            child: IconButton(
              onPressed: () => _showDeleteDialog(task),
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.warningColor,
                size: 18.sp,
              ),
              padding: EdgeInsets.all(8.w),
              constraints: BoxConstraints(),
            ),
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
    final textController = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4.resolveFrom(context),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  // Header with Cancel and Add buttons
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextButton(
                          onPressed: () {
                            if (!mounted) return;
                            try {
                              debugPrint(
                                '🔄 [QuickTaskScreen] Closing add todo sheet',
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              debugPrint(
                                '❌ [QuickTaskScreen] Error closing sheet: $e',
                              );
                            }
                          },
                          text: 'Cancel',
                          textColor: CupertinoColors.systemGrey,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                        ),

                        Text(
                          'Add Task',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.fontMainColor,
                          ),
                        ),
                        CustomTextButton(
                          onPressed: () {
                            if (!mounted) return;
                            if (textController.text.trim().isNotEmpty) {
                              try {
                                debugPrint(
                                  '✅ [QuickTaskScreen] Creating todo from button',
                                );
                                _addTodo(textController.text.trim());
                                Navigator.pop(context);
                              } catch (e) {
                                debugPrint(
                                  '❌ [QuickTaskScreen] Error creating todo: $e',
                                );
                              }
                            }
                          },
                          text: 'Add',
                          textColor: CupertinoColors.systemGrey,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.h, thickness: 0.5),
                  SizedBox(height: 16.h),
                  // Text input
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CupertinoTextField(
                      controller: textController,
                      placeholder: 'What needs to be done?',
                      placeholderStyle: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 17.sp,
                      ),
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: AppColors.fontMainColor,
                      ),
                      maxLines: 5,
                      minLines: 3,
                      textInputAction: TextInputAction.done,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.resolveFrom(context),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      autofocus: true,
                      onSubmitted: (value) {
                        if (!mounted) return;
                        if (value.trim().isNotEmpty) {
                          try {
                            debugPrint(
                              '✅ [QuickTaskScreen] Creating todo from keyboard',
                            );
                            _addTodo(textController.text.trim());
                            Navigator.pop(context);
                          } catch (e) {
                            debugPrint(
                              '❌ [QuickTaskScreen] Error creating todo: $e',
                            );
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addTodo(String title) {
    if (!mounted) {
      debugPrint(
        '⚠️ [QuickTaskScreen] Widget not mounted, aborting todo creation',
      );
      return;
    }

    try {
      debugPrint('🚀 [QuickTaskScreen] Creating todo: $title');
      context.read<QuickTaskCubit>().createTodo({
        'title': title,
        'complete': false,
        'dateTime': DateTime.now().toIso8601String(),
        'createdBy': storage.read('fullName'),
        'createdAt': DateTime.now().toIso8601String(),
        'userId': storage.read('userId'),
        'send': false,
        'email': storage.read('email'),
      });
    } catch (e) {
      debugPrint('❌ [QuickTaskScreen] Error creating todo: $e');
    }
  }

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 30.sp,
                  color: AppColors.warningColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Delete Task?',
                style: AppTypography.fontSize20.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.fontMainColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
                style: AppTypography.fontSize14.copyWith(
                  color: AppColors.lightFontColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (!mounted) return;
                        try {
                          debugPrint('🔄 [QuickTaskScreen] Canceling delete');
                          Navigator.pop(context);
                        } catch (e) {
                          debugPrint(
                            '❌ [QuickTaskScreen] Error closing delete dialog: $e',
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTypography.fontSize14.copyWith(
                          color: AppColors.lightFontColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!mounted) return;
                        try {
                          debugPrint(
                            '🗑️ [QuickTaskScreen] Deleting todo: ${task.sId}',
                          );
                          context.read<QuickTaskCubit>().deleteTodo(task.sId!);
                          Navigator.pop(context);
                        } catch (e) {
                          debugPrint(
                            '❌ [QuickTaskScreen] Error deleting todo: $e',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warningColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Delete',
                        style: AppTypography.fontSize14.copyWith(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
