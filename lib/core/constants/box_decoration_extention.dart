//box decoration extension

import 'package:repair_cms/core/app_exports.dart';

BoxDecoration boxDecoration({
  Color? color,
  double? radius,
  double? borderWidth,
  Color? borderColor,
  BoxShape? shape,
}) {
  return BoxDecoration(
    color: color ?? AppColors.whiteColor,
    shape: shape ?? BoxShape.rectangle,
    borderRadius: BorderRadius.circular(radius ?? 46.r),
    border: Border.all(
      color: borderColor ?? AppColors.whiteColor,
      width: borderWidth ?? 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(2, 0),
      ),
    ],
  );
}
