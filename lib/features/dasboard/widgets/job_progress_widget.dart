import 'package:intl/intl.dart' as intl;
import 'package:repair_cms/core/app_exports.dart';
import 'dart:math' as math;

class JobProgressWidget extends StatelessWidget {
  const JobProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          SizedBox(height: 12.h),
          _buildDonutChart(),
          SizedBox(height: 8.h),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Job Progress', style: AppTypography.fontSize16Bold),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(8.r)),
          child: Row(
            children: [
              Text('Today, ${intl.DateFormat('yyyy').format(DateTime.now())}', style: AppTypography.fontSize16),
              SizedBox(width: 2.w),
              Container(height: 28.h, color: const Color(0x898FA0B2), width: 2.w),
              SizedBox(width: 2.w),
              const Icon(Icons.calendar_month, color: Color(0xFF2589F6)),
              Icon(Icons.keyboard_arrow_down, color: const Color(0xFF2589F6), size: 20.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart() {
    return Center(
      child: SizedBox(
        width: 180.w,
        height: 180.h,
        child: Stack(
          children: [
            CustomPaint(size: Size(200.w, 180.h), painter: DonutChartPainter()),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '50',
                    style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  Text('Active Jobs', style: AppTypography.fontSize10.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem('On Hold', Colors.red),
        SizedBox(height: 4.h),
        _buildLegendItem('Repair in Progress', Colors.orange),
        SizedBox(height: 4.h),
        _buildLegendItem('Quotation Confirmed', Colors.green),
        SizedBox(height: 4.h),
        _buildLegendItem('Quotation Rejected', Colors.red.shade300),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24.w,
          height: 12.h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        ),
        SizedBox(width: 8.w),
        Expanded(child: Text(label, style: AppTypography.fontSize16)),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<ChartData> data = [
    ChartData(value: 24, color: const Color(0xFFB84343)), // On Hold
    ChartData(value: 28, color: const Color(0xFF27AE60)), // Quotation Confirmed
    ChartData(value: 20, color: const Color(0xFFFF5F5F)), // Quotation Rejected
    ChartData(value: 26, color: const Color(0xFFF39C12)), // Repair in Progress
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
