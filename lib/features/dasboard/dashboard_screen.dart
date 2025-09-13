import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/app_typography.dart';
import 'dart:math' as math;

import '../profile/profile_options_screen.dart';
// Import your typography file here
// import 'package:repair_cms/core/constants/app_typography.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(12.r)),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search job',
                    hintStyle: AppTypography.fontSize14.copyWith(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Stack(
              children: [
                Icon(Icons.notifications_outlined, color: Colors.grey.shade600, size: 24.sp),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileOptionsScreen()));
              },
              child: CircleAvatar(
                radius: 16.r,
                backgroundImage: const AssetImage('assets/images/logo.png'), // Add your image
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            _buildGreetingSection(),
            SizedBox(height: 24.h),

            // Incomplete To-Do's Card
            _buildIncompleteToDoCard(),
            SizedBox(height: 16.h),

            // Completed Jobs Card
            _buildCompletedJobsCard(),
            SizedBox(height: 16.h),

            // Job Progress Card
            _buildJobProgressCard(),
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
            Text('Good Morning, John', style: AppTypography.fontSize24.copyWith(fontWeight: FontWeight.w500)),
            SizedBox(width: 8.w),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Text('👋', style: TextStyle(fontSize: 24.sp)),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text('3. August, 2023', style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildIncompleteToDoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Incomplete To-Do\'s', style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600)),
                SizedBox(height: 8.h),
                Text('5', style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.list_alt, color: AppColors.primary, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  'See All To-Do\'s',
                  style: AppTypography.fontSize10.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(Icons.work_outline, color: Colors.purple, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today, 2025', style: AppTypography.fontSize16Bold),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20.sp),
                  ],
                ),
                SizedBox(height: 4.h),
                Text('01.02.2024 - 28.02.2024', style: AppTypography.fontSize10.copyWith(color: Colors.grey.shade600)),
                SizedBox(height: 4.h),
                Text(
                  'Completed Jobs',
                  style: AppTypography.fontSize10.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Text('156', style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildJobProgressCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Job Progress', style: AppTypography.fontSize16Bold),
              Row(
                children: [
                  Text('Today, 2025', style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600)),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20.sp),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Donut Chart
          Center(
            child: SizedBox(
              width: 200.w,
              height: 200.h,
              child: Stack(
                children: [
                  CustomPaint(size: Size(200.w, 200.h), painter: DonutChartPainter()),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '50',
                          style: AppTypography.fontSize28.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text('Active Jobs', style: AppTypography.fontSize10.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem('On Hold', Colors.red, '20'),
        SizedBox(height: 8.h),
        _buildLegendItem('Repair in Progress', Colors.orange, ''),
        SizedBox(height: 8.h),
        _buildLegendItem('Quotation Confirmed', Colors.green, '28'),
        SizedBox(height: 8.h),
        _buildLegendItem('Quotation Rejected', Colors.red.shade300, '24'),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(child: Text(label, style: AppTypography.fontSize10)),
        if (value.isNotEmpty) Text(value, style: AppTypography.fontSize10.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// Custom Painter for Donut Chart

class DonutChartPainter extends CustomPainter {
  final List<ChartData> data = [
    ChartData(value: 24, color: const Color(0xFFE74C3C)), // On Hold
    ChartData(value: 26, color: const Color(0xFFF39C12)), // Repair in Progress
    ChartData(value: 28, color: const Color(0xFF27AE60)), // Quotation Confirmed
    ChartData(value: 20, color: const Color(0xFFE67E22)), // Quotation Rejected
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.7;

    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    double startAngle = -math.pi / 2; // Start from top

    for (final segment in data) {
      final sweepAngle = (segment.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Draw value text on segments
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = (radius + innerRadius) / 2;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: segment.value.toInt().toString(),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));

      startAngle += sweepAngle;
    }

    // Draw inner circle with primary color
    final innerCirclePaint = Paint()
      ..color =
          const Color(0xFF3498DB) // Primary blue color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;

    canvas.drawCircle(center, innerRadius - 12, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChartData {
  final double value;
  final Color color;

  ChartData({required this.value, required this.color});
}
