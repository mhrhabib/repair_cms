import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/constants/app_colors.dart';

abstract class AppTypography {
  static const String fontFamilyRoboto = 'Roboto';
  static const String fontFamilySFProText = 'SF Pro Text';

  static TextStyle fontSize28 = GoogleFonts.roboto(
    fontSize: 28.sp,
    fontWeight: FontWeight.w400,
    color: Color(0xFF000000),
  );

  static TextStyle fontSize24 = GoogleFonts.roboto(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
    color: Color(0xFF000000),
  );
  static TextStyle fontSize20 = GoogleFonts.roboto(
    fontSize: 20.sp,
    fontWeight: FontWeight.w400,
    color: Color(0xFF000000),
  );
  static TextStyle fontSize16Normal = GoogleFonts.roboto(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: Color(0xFF000000),
  );
  static TextStyle fontSize16Bold = GoogleFonts.roboto(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: Color(0xFF000000),
  );
  static TextStyle fontSize14 = GoogleFonts.roboto(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,

    color: Color(0xFF000000),
  );
  static TextStyle fontSize12 = GoogleFonts.roboto(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: Color(0xFF000000),
  );

  //button text style
  static TextStyle primaryButtonTextStyle = GoogleFonts.roboto(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,

    color: Color(0xFFFFFFFF),
  );

  static TextStyle sfProHeadLineTextStyle = GoogleFonts.getFont(
    fontFamilySFProText,
    fontSize: 28.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.fontMainColor,
  );
}
