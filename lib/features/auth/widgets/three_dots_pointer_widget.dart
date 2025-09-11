import 'package:repair_cms/core/app_exports.dart';

class ThreeDotsPointerWidget extends StatelessWidget {
  const ThreeDotsPointerWidget({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.activeIndex,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.w,
      children: [
        // First dot
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: activeIndex == 0 ? primaryColor : secondaryColor),
        ),

        // Second dot
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: activeIndex == 1 ? primaryColor : secondaryColor),
        ),

        // Third dot
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: activeIndex == 2 ? primaryColor : secondaryColor),
        ),
      ],
    );
  }
}
