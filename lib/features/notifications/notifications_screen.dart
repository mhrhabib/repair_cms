import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/label_formatter.dart';
import 'package:repair_cms/features/notifications/cubits/notification_cubit.dart';
import 'package:repair_cms/features/notifications/models/notificaiton_model.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:repair_cms/features/notifications/widgets/notification_list_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Notifications> _notifications = [];

  @override
  void initState() {
    super.initState();
    try {
      final userId = storage.read('userId') ?? '';
      if (userId != null && userId.toString().isNotEmpty) {
        debugPrint(
          '🔄 [NotificationsScreen] Loading notifications for user: $userId',
        );
        // Trigger cubit to fetch notifications
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<NotificationCubit>().getNotifications(
              userId: userId.toString(),
            );
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [NotificationsScreen] Error in initState: $e');
      debugPrint('📋 Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          BlocConsumer<NotificationCubit, NotificationState>(
            listener: (context, state) {
              if (!mounted) return;
              try {
                if (state is NotificationLoaded) {
                  setState(() => _notifications = state.notifications);
                  debugPrint(
                    '✅ [NotificationsScreen] Loaded ${state.notifications.length} notifications',
                  );
                }
                if (state is NotificationError) {
                  debugPrint('❌ [NotificationsScreen] Error: ${state.message}');
                  showCustomToast(state.message, isError: true);
                }
              } catch (e) {
                debugPrint('❌ [NotificationsScreen] Error in listener: $e');
              }
            },
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const Center(child: CupertinoActivityIndicator(color: AppColors.fontSecondaryColor,));
              }

              if (state is NotificationLoaded) {
                if (state.notifications.isEmpty) return _buildEmptyState();
                return _buildNotificationsList();
              }

              if (state is NotificationError) {
                return _buildErrorState(state.message);
              }

              // initial or fallback
              return _buildEmptyState();
            },
          ),

          // Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16.w,
                right: 16.w,
                bottom: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.kBg.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomNavButton(
                    onPressed: () {
                      if (!mounted) return;
                      try {
                        debugPrint('🔄 [NotificationsScreen] Navigating back');
                        Navigator.pop(context);
                      } catch (e) {
                        debugPrint(
                          '❌ [NotificationsScreen] Error navigating back: $e',
                        );
                      }
                    },
                    icon: CupertinoIcons.back,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: AppColors.whiteColor, // Figma: border #FFFFFF
                        width: 1, // Figma: border-width 1px
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            28,
                            116,
                            115,
                            115,
                          ), // Figma: #0000001C
                          blurRadius: 2, // Figma: blur 20px
                          offset: Offset(0, 0), // Figma: 0px 0px (no offset)
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'Notifications',
                      style: AppTypography.sfProHeadLineTextStyle22,
                    ),
                  ),
                  if (_notifications.isNotEmpty)
                    CustomNavButton(
                      onPressed: _showNotificationSettings,
                      icon: SolarIconsOutline.settings,
                      size: 24.sp,
                    )
                  else
                    SizedBox(width: 40.w), // Spacer to balance the back button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 220.w,
            height: 170.h,
            child: SvgPicture.asset(
              AssetsConstant.noNotificationIconsSVG,
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Notifications Yet',
            style: AppTypography.sfProHeadLineTextStyle28.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll\nshow up here',
            textAlign: TextAlign.center,
            style: AppTypography.sfProHeadLineTextStyle22.copyWith(
              color: AppColors.lightFontColor,
              height: 1.5,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load notifications',
              style: AppTypography.sfProHeadLineTextStyle22.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshNotifications() {
    if (!mounted) {
      debugPrint(
        '⚠️ [NotificationsScreen] Widget not mounted, skipping refresh',
      );
      return;
    }

    try {
      final userId = storage.read('userId') ?? '';
      if (userId != null && userId.toString().isNotEmpty) {
        debugPrint('🔄 [NotificationsScreen] Refreshing notifications');
        context.read<NotificationCubit>().getNotifications(
          userId: userId.toString(),
        );
      }
    } catch (e) {
      debugPrint('❌ [NotificationsScreen] Error refreshing: $e');
    }
  }

  Widget _buildNotificationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 60.h),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'App Notification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return NotificationListItem(
                notification: notification,
                onMarkAsRead: () {
                  debugPrint(
                    '✅ [NotificationsScreen] Marking notification as read',
                  );
                    // Optimistically update UI
                    if (mounted) {
                      setState(() {
                        _notifications[index].isRead = true;
                      });
                    }
                  final userId = storage.read('userId') ?? '';
                  final notificationId = notification.sId ?? '';

                  if (notificationId.isNotEmpty &&
                      userId.toString().isNotEmpty) {
                    context.read<NotificationCubit>().markAsRead(
                      notificationId: notificationId,
                      userId: userId.toString(),
                    );
                  }
                },
                onDelete: () => _showNotificationOptions(notification),
                formatDate: _formatDate,
                getIcon: _getNotificationIconWidget,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getNotificationIconWidget(Notifications notification) {
    final type = (notification.messageType ?? '').toLowerCase();
    switch (type) {
      case 'stock':
        return const Icon(
          Icons.inventory_2_outlined,
          size: 20,
          color: Colors.black,
        );
      case 'job':
        return const Icon(Icons.layers_outlined, size: 20, color: Colors.black);
      case 'message':
        return const Icon(
          Icons.message_outlined,
          size: 20,
          color: Colors.black,
        );
      default:
        return const Icon(
          SolarIconsOutline.bell,
          size: 20,
          color: Colors.black,
        );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return '${date.day}/${date.month}/${date.year} $hh:$mm';
    } catch (e) {
      return dateString;
    }
  }

  void _showNotificationOptions(Notifications notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      child: Text(
                      LabelFormatter
                      .formatLabel(  notification.message ?? ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!mounted) return;
                            try {
                              debugPrint(
                                '🗑️ [NotificationsScreen] Deleting notification',
                              );
                              Navigator.pop(context);
                              final userId = storage.read('userId') ?? '';
                              final notificationId = notification.sId ?? '';

                              if (notificationId.isNotEmpty &&
                                  userId.toString().isNotEmpty) {
                                context
                                    .read<NotificationCubit>()
                                    .deleteNotification(
                                      notificationId: notificationId,
                                      userId: userId.toString(),
                                    );
                                if (mounted) {
                                  showCustomToast('Notification deleted');
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                '❌ [NotificationsScreen] Error deleting notification: $e',
                              );
                              if (mounted) {
                                showCustomToast(
                                  'Failed to delete notification',
                                  isError: true,
                                );
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.h,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  'assets/icon/xmark.bin.fill.png',
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Delete this notification',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      try {
                        debugPrint(
                          '✅ [NotificationsScreen] Marking all as read',
                        );
                        Navigator.pop(context);
                        if (mounted) {
                          setState(() {
                            for (var n in _notifications) {
                              n.isRead = true;
                            }
                          });
                          showCustomToast(
                            'All notifications marked as read',
                            isError: false,
                          );
                        }
                      } catch (e) {
                        debugPrint(
                          '❌ [NotificationsScreen] Error marking all as read: $e',
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24.h,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A90E2,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/icon/checkmark.bubble.fill (1).png',
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Mark all as "Read"',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteAllDialog();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24.h,
                          height: 24.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset('assets/icon/xmark.bin.fill.png'),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Delete all notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete All Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (!mounted) return;
              try {
                debugPrint(
                  '🗑️ [NotificationsScreen] Deleting all notifications',
                );
                Navigator.pop(context);
                if (mounted) {
                  setState(() {
                    _notifications.clear();
                  });
                  showCustomToast('All notifications deleted');
                }
              } catch (e) {
                debugPrint('❌ [NotificationsScreen] Error deleting all: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
