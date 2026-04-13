import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class PrinterEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const PrinterEmptyState({
    super.key,
    required this.title,
    this.subtitle = "Your printer isn't set up yet.",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            SolarIconsOutline.printer2,
            size: 180.sp,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),

          SizedBox(height: 24.h),
          Text(
            title,
            style: AppTypography.sfProHeadLineTextStyle22.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: AppTypography.sfProText15.copyWith(
              color: AppColors.fontSecondaryColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
