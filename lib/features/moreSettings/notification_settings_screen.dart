import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Push Notification Section
                  const Text(
                    'Push Notification',
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
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
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
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
                style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w400),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Container(height: 1, color: Colors.grey.shade100, margin: const EdgeInsets.symmetric(vertical: 4)),
      ],
    );
  }
}
