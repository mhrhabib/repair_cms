import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/notifications/cubits/notification_cubit.dart';
import 'package:repair_cms/features/notifications/models/notificaiton_model.dart';
import 'package:solar_icons/solar_icons.dart';

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
    final userId = storage.read('userId') ?? '';
    if (userId != null && userId.toString().isNotEmpty) {
      // Trigger cubit to fetch notifications
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NotificationCubit>().getNotifications(userId: userId.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        border: null,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.back, size: 28.r, color: AppColors.fontMainColor),
              SizedBox(width: 4.w),
              Text(
                'Back',
                style: TextStyle(fontSize: 17.sp, color: AppColors.fontMainColor),
              ),
            ],
          ),
        ),
        middle: Text(
          'Notifications',
          style: TextStyle(color: AppColors.fontMainColor, fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        trailing: GestureDetector(
          onTap: _showNotificationSettings,
          child: Icon(SolarIconsBold.settings, size: 24.r, color: AppColors.fontMainColor),
        ),
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationLoaded) {
            setState(() => _notifications = state.notifications);
          }
          if (state is NotificationError) {
            // optionally show a snackbar on error
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
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
            child: SvgPicture.asset(AssetsConstant.noNotificationIconsSVG, width: 60, height: 60),
          ),
          const SizedBox(height: 32),
          Text(
            'No Notifications Yet',
            style: AppTypography.sfProHeadLineTextStyle28.copyWith(fontWeight: FontWeight.w500),
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
              style: AppTypography.sfProHeadLineTextStyle22.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refreshNotifications, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  void _refreshNotifications() {
    final userId = storage.read('userId') ?? '';
    if (userId != null && userId.toString().isNotEmpty) {
      context.read<NotificationCubit>().getNotifications(userId: userId.toString());
    }
  }

  Widget _buildNotificationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'App Notification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(_notifications[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(Notifications notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead! ? Colors.white : Color(0xFFCDE3FF),
        // borderRadius: BorderRadius.circular(12),
        //boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: _getNotificationIconWidget(notification),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.3),
                ),
                if ((notification.quotationNo ?? '').isNotEmpty || (notification.conversationId ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.quotationNo ?? notification.conversationId ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 8),
                Text(_formatDate(notification.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
            onSelected: (value) {
              if (value == 'delete') {
                _showNotificationOptions(notification);
              } else if (value == 'mark_read') {
                setState(() {
                  notification.isRead = true;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(value: 'mark_read', child: Text('Mark as Read')),
              const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getNotificationIconWidget(Notifications notification) {
    final type = (notification.messageType ?? '').toLowerCase();
    switch (type) {
      case 'stock':
        return const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.black);
      case 'job':
        return const Icon(Icons.layers_outlined, size: 20, color: Colors.black);
      case 'message':
        return const Icon(Icons.message_outlined, size: 20, color: Colors.black);
      default:
        return const Icon(Icons.notifications_none, size: 20, color: Colors.black);
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
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
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
                        notification.message ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
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
                            Navigator.pop(context);
                            final userId = storage.read('userId') ?? '';
                            final notificationId = notification.sId ?? '';

                            if (notificationId.isNotEmpty && userId.toString().isNotEmpty) {
                              context.read<NotificationCubit>().deleteNotification(
                                notificationId: notificationId,
                                userId: userId.toString(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notification deleted'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.h,
                                height: 24.h,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                                child: Image.asset('assets/icon/xmark.bin.fill.png'),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Delete this notification',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
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
                      Navigator.pop(context);
                      setState(() {
                        for (var n in _notifications) {
                          n.isRead = true;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications marked as read'),
                          backgroundColor: Color(0xFF4A90E2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24.h,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset('assets/icon/checkmark.bubble.fill (1).png'),
                        ),
                        const SizedBox(width: 12),
                        const Text('Mark all as "Read"', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                          child: Image.asset('assets/icon/xmark.bin.fill.png'),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Delete all notifications',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        title: const Text('Delete All Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('All notifications deleted'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
