import 'package:flutter/material.dart';
import 'package:repair_cms/features/moreSettings/labelContent/label_content_screen.dart';
import 'package:repair_cms/features/moreSettings/notificationSetting/notification_settings_screen.dart';

class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'More',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: Container(), // Empty container to hide back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Printer Settings
            _buildSettingsItem(
              icon: Icons.print,
              iconColor: Colors.blue,
              title: 'Printer Settings',
              onTap: () {
                // Navigate to printer settings
              },
            ),

            const SizedBox(height: 16),

            // Label Content
            _buildSettingsItem(
              icon: Icons.label,
              iconColor: Colors.blue,
              title: 'Label Content',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LabelContentScreen()));
              },
            ),

            const SizedBox(height: 16),

            // Notification Settings
            _buildSettingsItem(
              icon: Icons.notifications,
              iconColor: Colors.blue,
              title: 'Notification Settings',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationSettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black26, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
