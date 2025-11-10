import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/moreSettings/labelContent/label_content_screen.dart';
import 'package:repair_cms/features/moreSettings/notificationSetting/notification_settings_screen.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/printer_settings_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({super.key});

  // Method to show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
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
  void _performLogout(BuildContext context) {
    // Close the dialog first
    Navigator.of(context).pop();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Perform logout operations
    _clearUserData()
        .then((_) {
          // Navigate to login screen and remove all routes
          GoRouter.of(context).go(
            RouteNames.signIn, // Replace with your actual login route
          );
        })
        .catchError((error) {
          // Handle any errors during logout
          Navigator.of(context).pop(); // Close loading dialog
          _showLogoutError(context, error.toString());
        });
  }

  // Method to clear user data and tokens
  Future<void> _clearUserData() async {
    try {
      // Clear authentication token
      await storage.remove('token');

      // Clear any other user-related data
      await storage.remove('user');
      await storage.remove('userId');
      await storage.remove('userType');
      // Clear any other cached data if needed
      // await StorageService.clearAll();

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
              title: 'A4 Printer Settings',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrinterSettingsScreen()));
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

            // Logout Button - Added at the bottom
            _buildLogoutItem(context),
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
              const Icon(Icons.chevron_right, color: Colors.red, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
