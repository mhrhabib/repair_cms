import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/features/profile/password&security/password_security_screen.dart';
import 'package:repair_cms/features/profile/personalDetails/personal_details_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileOptionsScreen extends StatelessWidget {
  const ProfileOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 72.h,
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Personal Details
            _buildProfileOption(
              icon: SolarIconsOutline.userId,
              iconColor: Colors.blue,
              title: 'Personal Details',
              onTap: () {
                try {
                  debugPrint(
                    '🔄 [ProfileOptionsScreen] Navigating to Personal Details',
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PersonalDetailsScreen(),
                    ),
                  );
                } catch (e) {
                  debugPrint(
                    '❌ [ProfileOptionsScreen] Error navigating to Personal Details: $e',
                  );
                }
              },
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.deviderColor, width: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language & Region
            _buildProfileOption(
              icon: SolarIconsOutline.globus,
              iconColor: Colors.blue,
              title: 'Language & Region',
              onTap: () {
                //coming soon feature on toast center
                showCustomToast('Coming Soon!', isError: false);
              },
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.deviderColor, width: 0.5),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Password & Security
            _buildProfileOption(
              icon: SolarIconsOutline.shield,
              iconColor: Colors.blue,
              title: 'Password & Security',
              onTap: () {
                try {
                  debugPrint(
                    '🔄 [ProfileOptionsScreen] Navigating to Password & Security',
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PasswordSecurityScreen(),
                    ),
                  );
                } catch (e) {
                  debugPrint(
                    '❌ [ProfileOptionsScreen] Error navigating to Password & Security: $e',
                  );
                }
              },
            ),
            Container(
              height: 1,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.deviderColor, width: 0.5),
                ),
              ),
            ),
            ],
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CupertinoIcons.back,
                  ),
                  Text(
                    'My Profile',
                    style: AppTypography.sfProHeadLineTextStyle22,
                  ),
                  const SizedBox(width: 48), // Spacer for centering title
                ],
              ),
            ),
          ),
        ],
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
              const SizedBox(width: 8),
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
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.fontMainColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
