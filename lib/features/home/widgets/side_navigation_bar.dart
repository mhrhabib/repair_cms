import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/app_typography.dart';
import 'package:solar_icons/solar_icons.dart';

class SideNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;
  final VoidCallback onAddPressed;

  const SideNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          // App Logo / Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(SolarIconsOutline.screencast, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  'RepairCMS',
                  style: AppTypography.fontSize20.copyWith(
                    color: AppColors.fontMainColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48.h),

          // Express Job Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: onAddPressed,
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 24.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Express Job',
                        style: AppTypography.fontSize16.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Nav Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              children: [
                _buildNavItem(0, SolarIconsOutline.pieChart, 'Dashboard'),
                _buildNavItem(1, SolarIconsOutline.suitcaseTag, 'My Jobs'),
                _buildNavItem(2, SolarIconsOutline.dialog2, 'Messages'),
                _buildNavItem(3, SolarIconsOutline.menuDots, 'More Settings'),
              ],
            ),
          ),

          // Version / Footer
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Text(
              'v1.2.2',
              style: AppTypography.fontSize12.copyWith(color: AppColors.lightFontColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.lightFontColor,
                  size: 24.sp,
                ),
                SizedBox(width: 16.w),
                Text(
                  label,
                  style: AppTypography.fontSize16.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.fontMainColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
