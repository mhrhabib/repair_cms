import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:solar_icons/solar_icons.dart';
import 'dart:math' as math;
import 'widgets/enhanced_search_widget.dart';
import 'widgets/job_progress_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xFFDB00FF), Color(0xFF432BFF)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  void initState() {
    print(context.read<SignInCubit>().userType);
    print(context.read<SignInCubit>().userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(context.read<SignInCubit>().userType);
    print(context.read<SignInCubit>().userId);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // _buildAppBar(),
                SizedBox(height: 28.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        // Greeting Section
                        _buildGreetingSection(),
                        SizedBox(height: 12.h),

                        // Incomplete To-Do's Card
                        _buildIncompleteToDoCard(),
                        SizedBox(height: 12.h),

                        // Completed Jobs Card
                        _buildCompletedJobsCard(),
                        SizedBox(height: 16.h),

                        // Job Progress Card - Using the new widget
                        const JobProgressWidget(),

                        // Add bottom padding for FAB
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Enhanced Search Widget positioned at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: EnhancedSearchWidget(
                onSearchChanged: (query) {
                  // Handle search query changes
                  print('Search query: $query');
                },
                onQRScanPressed: () {
                  // Handle QR scan button press
                  _showQRScanDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Good Morning, John',
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: AppTypography.fontSize22.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 8.w),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Text('👋', style: TextStyle(fontSize: 24.sp)),
            ),
          ],
        ),
        Text(
          '3. August, 2023',
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: AppTypography.fontSize14.copyWith(color: AppColors.lightFontColor),
        ),
      ],
    );
  }

  Widget _buildIncompleteToDoCard() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Incomplete To-Do\'s', style: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor)),
                SizedBox(height: 8.h),
                Text('5', style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.today_rounded, color: AppColors.primary, size: 22.sp),
                SizedBox(width: 4.w),
                Text(
                  'See All To-Do\'s',
                  style: AppTypography.fontSize16.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedJobsCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(color: const Color(0xFFC507FF), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(SolarIconsBold.caseMinimalistic, color: Colors.white, size: 30.sp),
              ),
              SizedBox(width: 16.w),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(8.r)),
                child: Row(
                  children: [
                    Text('Today, 2025', style: AppTypography.fontSize16),
                    SizedBox(width: 2.w),
                    Container(height: 28.h, color: const Color(0x898FA0B2), width: 2.w),
                    SizedBox(width: 2.w),
                    const Icon(Icons.calendar_month, color: Color(0xFF2589F6)),
                    Icon(Icons.keyboard_arrow_down, color: const Color(0xFF2589F6), size: 20.sp),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text(
                    '01.02.2024 - 28.02.2024',
                    style: AppTypography.fontSize14.copyWith(color: AppColors.fontMainColor),
                  ),
                  Text(
                    'Completed Jobs',
                    style: AppTypography.fontSize24.copyWith(
                      fontWeight: FontWeight.w500,
                      foreground: Paint()..shader = linearGradient,
                    ),
                  ),
                ],
              ),
              Text('156', style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  void _showQRScanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Scanner'),
          content: const Text('QR Scanner functionality would be implemented here.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
        );
      },
    );
  }
}
