import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/services/socket_service.dart';
import 'package:repair_cms/features/moreSettings/labelContent/label_content_screen.dart';
import 'package:repair_cms/features/moreSettings/notificationSetting/notification_settings_screen.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/printer_settings_screen.dart';
import 'package:repair_cms/set_up_di.dart';
import 'package:repair_cms/main.dart';
import 'package:solar_icons/solar_icons.dart';

class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({super.key});

  // Method to show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.kBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          content: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _performLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Method to perform logout
  Future<void> _performLogout(BuildContext context) async {
    try {
      debugPrint('🚺 [Logout] Starting logout process');

      // Close the confirmation dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CupertinoActivityIndicator());
          },
        );
      }

      try {
        await _clearUserData();

        debugPrint('✅ [Logout] Logout successful, restarting app');

        // Allow some time for state to settle - production safe
        await Future.delayed(const Duration(milliseconds: 300));

        if (context.mounted) {
          // Restart the app to clear all memory (cubits/blocs)
          RestartWidget.restartApp(context);
        }
      } catch (error) {
        debugPrint('❌ [Logout] Error during logout: $error');

        if (context.mounted) {
          // Close loading dialog if it's still open
          Navigator.of(context).pop();
          _showLogoutError(context, error.toString());
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Logout] Critical error in logout: $e');
      debugPrint('📋 Stack trace: $stackTrace');
    }
  }

  // Method to clear user data and tokens
  Future<void> _clearUserData() async {
    try {
      // Disconnect socket FIRST to prevent memory leaks
      debugPrint('🔌 [Logout] Disconnecting socket');
      SetUpDI.getIt<SocketService>().disconnect();

      // Clear all local storage data
      await clearLocalStorage();

      // Optional: Call logout API if needed
      // await ApiService.logout();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Method to show logout error
  void _showLogoutError(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange),
              SizedBox(width: 12),
              Text('Logout Error'),
            ],
          ),
          content: Text('There was an issue during logout: $error'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 72.h,
              left: 10.0,
              right: 10.0,
              bottom: 10.0,
            ),
            child: Column(
              children: [
                // Printer Settings
                _buildSettingsItem(
                  iconsWidget: Icon(SolarIconsOutline.printer, color: Colors.blue),
                  title: 'Printer Settings',
                  onTap: () {
                    try {
                      debugPrint('🔄 [MoreSettings] Navigating to Printer Settings');
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => const PrinterSettingsScreen()));
                    } catch (e) {
                      debugPrint('❌ [MoreSettings] Error navigating to Printer Settings: $e');
                    }
                  },
                ),

                Container(
                  height: 1,
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * .78,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.deviderColor, width: 0.5)),
                  ),
                ),

                // Label Content
                _buildSettingsItem(
                  iconsWidget: Image.asset('assets/icon/label.png', width: 24, height: 24),
                  title: 'Label Content',
                  onTap: () {
                    try {
                      debugPrint('🔄 [MoreSettings] Navigating to Label Content');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => LabelContentScreen()));
                    } catch (e) {
                      debugPrint('❌ [MoreSettings] Error navigating to Label Content: $e');
                    }
                  },
                ),

                Container(
                  height: 1,
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * .78,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.deviderColor, width: 0.5)),
                  ),
                ),

                // Notification Settings
                _buildSettingsItem(
                  iconsWidget: Icon(SolarIconsOutline.bell, color: Colors.blue),
                  title: 'Notification Settings',
                  onTap: () {
                    try {
                      debugPrint('🔄 [MoreSettings] Navigating to Notification Settings');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationSettingsScreen()));
                    } catch (e) {
                      debugPrint('❌ [MoreSettings] Error navigating to Notification Settings: $e');
                    }
                  },
                ),

                Container(
                  height: 1,
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * .78,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.deviderColor, width: 0.5)),
                  ),
                ),

                // Debug Logs - For remote troubleshooting
                _buildSettingsItem(
                  iconsWidget: Icon(SolarIconsOutline.bug, color: Colors.purple),
                  title: 'Debug Logs',
                  subtitle: 'Printer troubleshooting',
                  onTap: () {
                    try {
                      debugPrint('🔄 [MoreSettings] Navigating to Debug Logs');
                      context.push(RouteNames.logsViewer);
                    } catch (e) {
                      debugPrint('❌ [MoreSettings] Error navigating to Debug Logs: $e');
                    }
                  },
                ),

                Container(
                  height: 1,
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * .78,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.deviderColor, width: 0.5)),
                  ),
                ),

                // Logout Button - Added at the bottom
                _buildLogoutItem(context),
              ],
            ),
          ),

          // Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16.w, right: 16.w, bottom: 8.h),
              decoration: BoxDecoration(color: AppColors.scaffoldBackgroundColor.withValues(alpha: 0.1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('More', style: AppTypography.sfProHeadLineTextStyle22)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required Widget iconsWidget,

    required String title,
    String? subtitle,
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
                child: iconsWidget,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.sfProText15.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.fontMainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: AppTypography.sfProText15.copyWith(fontSize: 12, color: AppColors.fontMainColor),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.fontMainColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLogoutDialog(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: const Icon(SolarIconsOutline.logout, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
