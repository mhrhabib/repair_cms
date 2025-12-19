import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/assets_constant.dart';
import 'package:repair_cms/core/constants/padding_constants.dart';
import 'package:repair_cms/core/routes/route_names.dart';
import 'package:repair_cms/core/utils/buttons/custom_button.dart';
import 'package:repair_cms/features/auth/widgets/three_dots_pointer_widget.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      Image.asset(AssetsConstant.logo1PNG, height: 55.39.h, width: 123.w),

                      SizedBox(height: 30.h),
                      Image.asset(
                        AssetsConstant.startingGraphicsPNG,
                        height: isTablet ? 400.h : (constraints.maxHeight * 0.4),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20.h),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Spacer(),
                      SizedBox(height: 10.h),
                      ThreeDotsPointerWidget(
                        primaryColor: AppColors.primary,
                        secondaryColor: AppColors.secondary,
                        activeIndex: 0,
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: PaddingConstants.lg),
                        child: CustomButton(
                          text: 'Log In',
                          onPressed: () {
                            context.go(RouteNames.signIn);
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Legal Disclosure | Privacy Policy | Terms Of Service',
                        style: GoogleFonts.roboto(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackColor,
                        ),
                      ),
                      Text(
                        'Copyright © Candy Melon Software GmbH',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
