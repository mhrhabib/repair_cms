import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/constants/app_colors.dart';

class CustomNavButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double? size;
  final Color? iconColor;
  final Color? backgroundColor;

  const CustomNavButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 42.w,
        height: 42.h,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFF7F7F8),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.whiteColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1C000000),
              blurRadius: 20.r,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.lightFontColor,
          size: size ?? 20.sp,
        ),
      ),
    );
  }
}
