import 'package:repair_cms/core/app_exports.dart';

/// A consistent top bar for all inner job booking screens.
///
/// Contains:
///   - Back arrow (top-left)
///   - An inline compact stepper showing steps 1…[totalSteps] with
///     connecting lines, highlighting the current [stepNumber].
///   - A red "Cancel" pill (top-right) that exits the entire flow.
class JobBookingTopBar extends StatelessWidget {
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
        // ── Row: back button + cancel button ──────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ← Back arrow
              GestureDetector(
                onTap: onBack,
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

              // Step label text
              Text(
                'Step $stepNumber of $totalSteps',
                style: AppTypography.fontSize12.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // ✕ Cancel
              if (showCancelButton)
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

        SizedBox(height: 12.h),

        // ── Compact stepper ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _StepperBar(currentStep: stepNumber, totalSteps: totalSteps),
        ),

        SizedBox(height: 6.h),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Internal compact stepper widget
// ──────────────────────────────────────────────────────────────────────────────

class _StepperBar extends StatelessWidget {
  const _StepperBar({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        // Even indexes → step dots; Odd indexes → connector lines
        if (index.isOdd) {
          final stepBefore = (index ~/ 2) + 1; // step to the left of this line
          final isDone = stepBefore < currentStep;
          return Expanded(
            child: Container(
              height: 2.5.h,
              decoration: BoxDecoration(
                gradient: isDone
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primary],
                      )
                    : null,
                color: isDone ? null : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }

        final step = index ~/ 2 + 1;
        final isDone = step < currentStep;
        final isCurrent = step == currentStep;

        return _StepDot(step: step, isDone: isDone, isCurrent: isCurrent);
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.isDone,
    required this.isCurrent,
  });

  final int step;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final double dotSize = isCurrent ? 28.w : (isDone ? 20.w : 16.w);

    if (isDone) {
      // Completed step: filled primary circle with check
      return Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: Colors.white, size: 10.sp),
      );
    }

    if (isCurrent) {
      // Current step: outer glow ring + filled center
      return Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(
          child: Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Future step: small grey dot
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
    );
  }
}
