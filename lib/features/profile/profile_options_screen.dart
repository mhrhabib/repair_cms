import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/profile/password&security/password_security_screen.dart';
import 'package:repair_cms/features/profile/personalDetails/personal_details_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileOptionsScreen extends StatelessWidget {
  const ProfileOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Personal Details
            _buildProfileOption(
              icon: SolarIconsOutline.userId,
              iconColor: Colors.blue,
              title: 'Personal Details',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalDetailsScreen()));
              },
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.diviverColor, width: 0.5)),
              ),
            ),
            const SizedBox(height: 16),

            // Language & Region
            _buildProfileOption(
              icon: SolarIconsOutline.globus,
              iconColor: Colors.blue,
              title: 'Language & Region',
              onTap: () {
                storage.write('token', null);
                context.go(RouteNames.signIn);
              },
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.diviverColor, width: 0.5)),
              ),
            ),

            const SizedBox(height: 16),

            // Password & Security
            _buildProfileOption(
              icon: SolarIconsOutline.shield,
              iconColor: Colors.blue,
              title: 'Password & Security',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PasswordSecurityScreen()));
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

  Widget _buildProfileOption({
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
                decoration: BoxDecoration(
                  // color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.sfProHintTextStyle17.copyWith(
                    color: AppColors.fontMainColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
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
