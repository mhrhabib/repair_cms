import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_text_button.dart';

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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Typeform-style animated progress bar at the very top ──────────
        Container(
          height: 12.h,
          width: double.infinity,
          color: const Color(0xFFE3F2FD),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF2196F3)),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        // ── Close button on the right ─────────────────────────────────────
        if (widget.showCancelButton)
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CustomTextButton(
              onPressed: () => _onCancel(context),
              text: 'Close',
            ),
          ),

        SizedBox(height: 8.h),
      ],
    );
  }
}
