import 'package:repair_cms/core/app_exports.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, required this.title, required this.subTitle, required this.stepNumber});
  final String title;
  final String subTitle;
  final int stepNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 12.w),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary,
          child: Text(stepNumber.toString(), style: AppTypography.fontSize22.copyWith(color: Colors.white)),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: AppTypography.fontSize22, textAlign: TextAlign.center),
            ),
            SizedBox(height: 1.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subTitle,
                style: AppTypography.fontSize16.copyWith(
                  fontWeight: FontWeight.normal,
                  color: AppColors.fontSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
