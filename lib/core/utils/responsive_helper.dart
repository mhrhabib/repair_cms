import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileLimit = 768.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileLimit;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileLimit;

  // Helper for responsive values
  static double responsiveValue({
    required BuildContext context,
    required double mobile,
    required double tablet,
  }) {
    return isMobile(context) ? mobile : tablet;
  }
}
