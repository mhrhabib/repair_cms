import 'package:repair_cms/core/app_exports.dart';

/// A consistent top bar for all inner job booking screens.
///
/// Contains:
///   - Back arrow (top-left)
///   - "Step X of Y" label (centered)
///   - A red "Cancel" pill (top-right) that exits the entire flow.
///   - A Typeform-style slim animated linear progress bar below the row.
class JobBookingTopBar extends StatefulWidget {
  const JobBookingTopBar({
    super.key,
    required this.stepNumber,
    required this.onBack,
    this.showCancelButton = true,
    this.totalSteps = 14,
    this.padding = 12,
  });

  final int stepNumber;
  final VoidCallback onBack;
  final bool showCancelButton;
  final int totalSteps;
  final double padding;

  @override
  State<JobBookingTopBar> createState() => _JobBookingTopBarState();
}

class _JobBookingTopBarState extends State<JobBookingTopBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late double _targetProgress;

  @override
  void initState() {
    super.initState();
    _targetProgress = widget.stepNumber / widget.totalSteps;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _progressAnimation = Tween<double>(
      begin: _targetProgress,
      end: _targetProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Animate in from 0 on first build
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _targetProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant JobBookingTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepNumber != widget.stepNumber) {
      final double oldProgress = oldWidget.stepNumber / widget.totalSteps;
      _targetProgress = widget.stepNumber / widget.totalSteps;

      _progressAnimation = Tween<double>(
        begin: oldProgress,
        end: _targetProgress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCancel(BuildContext context) {
    Navigator.of(
      context,
    ).popUntil((route) => route.isFirst || route.settings.name != null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Row: back button + step label + cancel button ─────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.padding.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ← Back arrow
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B4B69),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),

              // Step label
              Text(
                'Step ${widget.stepNumber} of ${widget.totalSteps}',
                style: AppTypography.fontSize12.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // ✕ Cancel
              if (widget.showCancelButton)
                GestureDetector(
                  onTap: () => _onCancel(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.red.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          color: Colors.red.shade700,
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Cancel',
                          style: AppTypography.fontSize12.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(width: 72.w),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // ── Typeform-style animated progress bar ──────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.padding.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              height: 5.h,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        SizedBox(height: 6.h),
      ],
    );
  }
}
