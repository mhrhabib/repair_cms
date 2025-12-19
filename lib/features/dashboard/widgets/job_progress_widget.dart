import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/dashboard/cubits/dashboard_cubit.dart';
import 'package:repair_cms/features/myJobs/screens/my_jobs_screen.dart';
import 'dart:math' as math;

class JobProgressWidget extends StatelessWidget {
  const JobProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        int totalActiveJobs = 0;
        int onHoldJobs = 0;
        int repairInProgressJobs = 0;
        int quotationConfirmedJobs = 0;
        int quotationRejectedJobs = 0;
        bool isLoading = state is DashboardLoading;

        if (state is DashboardLoaded && state.jobProgress != null) {
          final progress = state.jobProgress!;
          totalActiveJobs = progress.totalJobs;
          onHoldJobs = progress.partsNotAvailableJobs;
          repairInProgressJobs = progress.inProgressJobs;
          quotationConfirmedJobs = progress.acceptedQuotesJobs;
          quotationRejectedJobs = progress.rejectQuotesJobs;
        }

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              if (isLoading)
                _buildLoadingChart()
              else
                _buildDonutChart(
                  totalActiveJobs: totalActiveJobs,
                  onHoldJobs: onHoldJobs,
                  repairInProgressJobs: repairInProgressJobs,
                  quotationConfirmedJobs: quotationConfirmedJobs,
                  quotationRejectedJobs: quotationRejectedJobs,
                ),
              SizedBox(height: 8.h),
              _buildLegend(
                context: context,
                onHoldJobs: onHoldJobs,
                repairInProgressJobs: repairInProgressJobs,
                quotationConfirmedJobs: quotationConfirmedJobs,
                quotationRejectedJobs: quotationRejectedJobs,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Job Progress', style: AppTypography.fontSize16Bold),
        Text(
          'Live Status',
          style: AppTypography.fontSize14.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLoadingChart() {
    return Center(
      child: SizedBox(
        width: 180.w,
        height: 180.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12.h),
            Text('Loading job progress...', style: AppTypography.fontSize14),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart({
    required int totalActiveJobs,
    required int onHoldJobs,
    required int repairInProgressJobs,
    required int quotationConfirmedJobs,
    required int quotationRejectedJobs,
  }) {
    return Center(
      child: SizedBox(
        width: 180.w,
        height: 180.h,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(200.w, 180.h),
              painter: DonutChartPainter(
                onHoldJobs: onHoldJobs,
                repairInProgressJobs: repairInProgressJobs,
                quotationConfirmedJobs: quotationConfirmedJobs,
                quotationRejectedJobs: quotationRejectedJobs,
                totalActiveJobs: totalActiveJobs,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    totalActiveJobs.toString(),
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

  Widget _buildLegend({
    required BuildContext context,
    required int onHoldJobs,
    required int repairInProgressJobs,
    required int quotationConfirmedJobs,
    required int quotationRejectedJobs,
  }) {
    return Column(
      children: [
        _buildLegendItem(context, 'On Hold ($onHoldJobs)', const Color(0xFFB84343), 'parts_not_available'),
        SizedBox(height: 4.h),
        _buildLegendItem(context, 'Repair in Progress ($repairInProgressJobs)', const Color(0xFFF39C12), 'in_progress'),
        SizedBox(height: 4.h),
        _buildLegendItem(
          context,
          'Quotation Confirmed ($quotationConfirmedJobs)',
          const Color(0xFF27AE60),
          'accepted_quotes',
        ),
        SizedBox(height: 4.h),
        _buildLegendItem(context, 'Quotation Rejected ($quotationRejectedJobs)', const Color(0xFFFF5F5F), 'rejected'),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, String statusFilter) {
    return InkWell(
      onTap: () {
        // Navigate directly to MyJobsScreen with the respective status filter
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyJobsScreen(initialStatus: statusFilter)));
      },
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 12.h,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(label, style: AppTypography.fontSize16)),
            Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int onHoldJobs;
  final int repairInProgressJobs;
  final int quotationConfirmedJobs;
  final int quotationRejectedJobs;
  final int totalActiveJobs;

  DonutChartPainter({
    required this.onHoldJobs,
    required this.repairInProgressJobs,
    required this.quotationConfirmedJobs,
    required this.quotationRejectedJobs,
    required this.totalActiveJobs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.7;

    if (totalActiveJobs == 0) {
      _drawEmptyChart(canvas, size, center, radius, innerRadius);
      return;
    }

    // Calculate total segments (sum of all job types)
    final int totalSegments = onHoldJobs + repairInProgressJobs + quotationConfirmedJobs + quotationRejectedJobs;

    // If no segments, draw empty chart
    if (totalSegments == 0) {
      _drawEmptyChart(canvas, size, center, radius, innerRadius);
      return;
    }

    // Create data with actual counts
    final data = [
      ChartData(value: onHoldJobs.toDouble(), color: const Color(0xFFB84343)),
      ChartData(value: repairInProgressJobs.toDouble(), color: const Color(0xFFF39C12)),
      ChartData(value: quotationConfirmedJobs.toDouble(), color: const Color(0xFF27AE60)),
      ChartData(value: quotationRejectedJobs.toDouble(), color: const Color(0xFFFF5F5F)),
    ];

    double startAngle = -math.pi / 2; // Start from top

    for (final segment in data) {
      if (segment.value > 0) {
        // Calculate sweep angle as percentage of total segments (not totalActiveJobs)
        final sweepAngle = (segment.value / totalSegments) * 2 * math.pi;

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

        // Draw value text on segments (ADDED THIS PART)
        final textAngle = startAngle + sweepAngle / 2;
        final textRadius = (radius + innerRadius) / 2;
        final textX = center.dx + textRadius * math.cos(textAngle);
        final textY = center.dy + textRadius * math.sin(textAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: segment.value.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto', // Optional: specify font family for consistency
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));

        startAngle += sweepAngle;
      }
    }

    // Draw inner circle with primary color
    final innerCirclePaint = Paint()
      ..color = const Color(0xFF3498DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;

    canvas.drawCircle(center, innerRadius - 12, innerCirclePaint);
  }

  void _drawEmptyChart(Canvas canvas, Size size, Offset center, double radius, double innerRadius) {
    // Draw empty gray circle
    final emptyPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
      0,
      2 * math.pi,
      false,
      emptyPaint,
    );

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = const Color(0xFF3498DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;

    canvas.drawCircle(center, innerRadius - 12, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChartData {
  final double value;
  final Color color;

  ChartData({required this.value, required this.color});
}
