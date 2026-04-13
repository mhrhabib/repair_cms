import 'package:repair_cms/core/app_exports.dart';

class BottomButtonsGroup extends StatelessWidget {
  const BottomButtonsGroup({super.key, required this.onPressed, this.onBack, this.okButtonText = 'OK'});

  final VoidCallback? onPressed;
  final VoidCallback? onBack;
  final String okButtonText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).pop(),
          child: SizedBox(width: 81.w, height: 60.h, child: Image.asset(AssetsConstant.liquiedButton)),
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
              child: Text(okButtonText, style: AppTypography.fontSize16Bold.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
