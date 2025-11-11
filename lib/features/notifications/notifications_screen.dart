// ignore_for_file: unused_element

import 'package:flutter_svg/svg.dart';
import 'package:repair_cms/core/app_exports.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications data - set to empty list to show empty state
  List<NotificationItem> notifications = [
    NotificationItem(
      icon: Icons.inventory_2_outlined,
      title: 'Minimum stock level has been reached for item iPhone 13 LCD Black',
      timestamp: '06.12.2023, 09:32',
      type: NotificationType.stock,
    ),
    NotificationItem(
      icon: Icons.description_outlined,
      title: 'Joe Doe has accepted the quotation',
      subtitle: 'Job ID : 54646',
      timestamp: '06.12.2023, 09:32',
      type: NotificationType.job,
    ),
    NotificationItem(
      icon: Icons.message_outlined,
      title: 'Joe Doe has sent you a message',
      subtitle: 'Job ID : 54646',
      timestamp: '06.12.2023, 09:32',
      type: NotificationType.message,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      body: notifications.isEmpty ? _buildEmptyState() : _buildNotificationsList(),
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
            'When you get notifications, they\'l\nshow up here',
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notifications[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: _getNotificationIcon(notification.type),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.3),
                ),
                if (notification.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 8),
                Text(notification.timestamp, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
            onSelected: (value) {
              if (value == 'delete') {
                setState(() {
                  notifications.remove(notification);
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

  SvgPicture _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.stock:
        return SvgPicture.asset('assets/icons/Layers_Minimalistic.svg');
      case NotificationType.job:
        return SvgPicture.asset('aassets/icons/job.svg');
      case NotificationType.message:
        return SvgPicture.asset('assets/icons/messge.svg');
    }
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
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mark as read or delete all notifications',
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.done_all, color: Color(0xFF4A90E2), size: 18),
              ),
              title: const Text('Mark all as "Read"', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read'), backgroundColor: Color(0xFF4A90E2)),
                );
              },
            ),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              ),
              title: const Text(
                'Delete all notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAllDialog();
              },
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
                notifications.clear();
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

  void _showDeleteNotificationDialog(NotificationItem notification) {
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
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: _getNotificationIcon(notification.type),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (notification.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(notification.subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              ),
              title: const Text(
                'Delete this notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  notifications.remove(notification);
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Notification deleted'), backgroundColor: Colors.red));
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

enum NotificationType { stock, job, message }

class NotificationItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String timestamp;
  final NotificationType type;

  NotificationItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.timestamp,
    required this.type,
  });
}
