import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/features/moreSettings/labelContent/label_content_screen.dart';
import 'package:repair_cms/features/moreSettings/notificationSetting/notification_settings_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'More',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: Container(), // Empty container to hide back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Printer Settings
            _buildSettingsItem(
              icon: SolarIconsOutline.printer,
              iconColor: Colors.blue,
              title: 'Printer Settings',
              onTap: () {
                // Navigate to printer settings
              },
            ),

            Container(
              height: 1,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.diviverColor, width: 0.5)),
              ),
            ),

            // Label Content
            _buildSettingsItem(
              icon: SolarIconsOutline.laptopMinimalistic,
              iconColor: Colors.blue,
              title: 'Label Content',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LabelContentScreen()));
              },
            ),

            Container(
              height: 1,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.diviverColor, width: 0.5)),
              ),
            ),

            // Notification Settings
            _buildSettingsItem(
              icon: SolarIconsOutline.bell,
              iconColor: Colors.blue,
              title: 'Notification Settings',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationSettingsScreen()));
              },
            ),
            Container(
              height: 1,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.diviverColor, width: 0.5)),
              ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.fontMainColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
