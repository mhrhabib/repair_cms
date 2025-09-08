import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/assets_constant.dart';
import 'package:repair_cms/core/constants/padding_constants.dart';
import 'package:repair_cms/core/utils/buttons/custom_button.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Get Started')),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 22.h),
              Image.asset(AssetsConstant.logo1PNG, height: 55.39.h, width: 123.w),

              SizedBox(height: 18.h),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(AssetsConstant.startingGraphicsPNG),
                  Positioned(
                    bottom: -20.h,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'WORLD’S ',
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'SF Pro Text',
                                color: AppColors.fontMainColor,
                              ),
                            ),
                            Text(
                              'MOST USER-FRIENDLY',
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontFamily: 'SF Pro Text',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2589F6),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'REPAIR MANAGER',

                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: TextStyle(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SF Pro Text',
                            color: AppColors.fontMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: PaddingConstants.lg),
                child: CustomButton(
                  trailingIcon: Icon(Icons.login, size: 24.sp),
                  text: 'Log In',
                  onPressed: () {
                    // Handle button press
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Legal Disclosure | Privacy Policy | Terms Of Service',
                style: GoogleFonts.roboto(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.blackColor),
              ),
              Text(
                'Copyright © Candy Melon Software GmbH',
                style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w400, color: Color(0xFF2B2B2B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
