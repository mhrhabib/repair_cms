import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/app_typography.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Push Notification Settings
  bool pushQuotesAccepted = false;
  bool pushQuotesRejected = true;
  bool pushJobOverdue = true;
  bool pushJobAssigned = true;
  bool pushNewMessage = true;
  bool pushStockLevelAlert = true;

  // Email Notification Settings
  bool emailQuotesAccepted = false;
  bool emailQuotesRejected = true;
  bool emailJobOverdue = true;
  bool emailJobAssigned = true;
  bool emailNewMessage = true;
  bool emailStockLevelAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 82.h),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Push Notification Section
                      Text(
                        'Push Notification',
                        style: AppTypography.sfProHeadLineTextStyle22,
                      ),
                      const SizedBox(height: 20),

                      _buildNotificationItem(
                        title: 'Quotes accepted',
                        value: pushQuotesAccepted,
                        onChanged: (value) {
                          setState(() {
                            pushQuotesAccepted = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Quotes rejected',
                        value: pushQuotesRejected,
                        onChanged: (value) {
                          setState(() {
                            pushQuotesRejected = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Job overdue',
                        value: pushJobOverdue,
                        onChanged: (value) {
                          setState(() {
                            pushJobOverdue = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Job assigned',
                        value: pushJobAssigned,
                        onChanged: (value) {
                          setState(() {
                            pushJobAssigned = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'New message',
                        value: pushNewMessage,
                        onChanged: (value) {
                          setState(() {
                            pushNewMessage = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Stock level alert',
                        value: pushStockLevelAlert,
                        onChanged: (value) {
                          setState(() {
                            pushStockLevelAlert = value;
                          });
                        },
                        isLast: false,
                      ),

                      const SizedBox(height: 32),

                      // Email Notification Section
                      const Text(
                        'Email Notification',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildNotificationItem(
                        title: 'Quotes accepted',
                        value: emailQuotesAccepted,
                        onChanged: (value) {
                          setState(() {
                            emailQuotesAccepted = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Quotes rejected',
                        value: emailQuotesRejected,
                        onChanged: (value) {
                          setState(() {
                            emailQuotesRejected = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Job overdue',
                        value: emailJobOverdue,
                        onChanged: (value) {
                          setState(() {
                            emailJobOverdue = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Job assigned',
                        value: emailJobAssigned,
                        onChanged: (value) {
                          setState(() {
                            emailJobAssigned = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'New message',
                        value: emailNewMessage,
                        onChanged: (value) {
                          setState(() {
                            emailNewMessage = value;
                          });
                        },
                      ),

                      _buildNotificationItem(
                        title: 'Stock level alert',
                        value: emailStockLevelAlert,
                        onChanged: (value) {
                          setState(() {
                            emailStockLevelAlert = value;
                          });
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                    onPressed: () => Navigator.pop(context),
                    icon: CupertinoIcons.back,
                  ),
                  Text(
                    'Notification Settings',
                    style: AppTypography.sfProHeadLineTextStyle22,
                  ),
                  const SizedBox(width: 44), // Spacer
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            color: Colors.grey.shade100,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),
      ],
    );
  }
}
