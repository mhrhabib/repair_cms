import 'package:feather_icons/feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/notifications/notifications_screen.dart';
import 'package:solar_icons/solar_icons.dart';
import 'dart:math' as math;
import '../profile/profile_options_screen.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Color(0xFFDEE3E8)),
                ),

                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search job',
                    hintStyle: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor),
                    prefixIcon: Icon(FeatherIcons.search, color: Colors.black, size: 22.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 6.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsScreen()));
                  },
                  child: Icon(Icons.notifications_none, color: Colors.grey.shade600, size: 24.sp),
                ),
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
                backgroundImage: const AssetImage('assets/images/logo.png'),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section
                _buildGreetingSection(),
                SizedBox(height: 12.h),

                // Incomplete To-Do's Card
                _buildIncompleteToDoCard(),
                SizedBox(height: 12.h),

                // Completed Jobs Card
                _buildCompletedJobsCard(),
                SizedBox(height: 16.h),

                // Job Progress Card
                _buildJobProgressCard(),

                // Add bottom padding for FAB
                SizedBox(height: 100.h),
              ],
            ),
          ),

          // Expandable FAB
        ],
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
                decoration: BoxDecoration(color: Color(0xFFC507FF), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.work_outline, color: Colors.white, size: 30.sp),
              ),
              SizedBox(width: 16.w),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(8.r)),
                child: Row(
                  children: [
                    Text('Today, 2025', style: AppTypography.fontSize16),
                    SizedBox(width: 2.w),
                    Container(height: 28.h, color: Color(0x898FA0B2), width: 2.w),
                    SizedBox(width: 2.w),
                    Icon(Icons.calendar_month),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20.sp),
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

                  // SizedBox(height: 4.h),
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

  Widget _buildJobProgressCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
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
          SizedBox(height: 12.h),

          // Donut Chart
          Center(
            child: SizedBox(
              width: 180.w,
              height: 180.h,
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
