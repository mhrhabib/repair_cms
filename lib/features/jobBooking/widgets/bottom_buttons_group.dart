import 'package:flutter/material.dart';
import 'package:repair_cms/core/app_exports.dart';

class BottomButtonsGroup extends StatelessWidget {
  const BottomButtonsGroup({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 81.w,
            height: 52.h,
            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            child: Image.asset(AssetsConstant.liquiedButton),
          ),
        ),

        SizedBox(width: 16.w),

        // OK button
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                elevation: 0,
              ),
              child: Text('OK', style: AppTypography.fontSize16Bold.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
