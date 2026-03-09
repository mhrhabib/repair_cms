import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 9 – Problem Description (Required) and Internal Note (Optional)
class StepProblemWidget extends StatefulWidget {
  const StepProblemWidget({super.key, required this.onCanProceedChanged});

  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepProblemWidget> createState() => StepProblemWidgetState();
}

class StepProblemWidgetState extends State<StepProblemWidget> {
  final TextEditingController _problemDescriptionController = TextEditingController();
  final TextEditingController _internalNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _problemDescriptionController.addListener(_updateCanProceed);

    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(_problemDescriptionController.text.trim().isNotEmpty);
    });
  }

  void _loadExistingData() {
    final state = context.read<JobBookingCubit>().state;
    if (state is JobBookingData) {
      if (state.defect.defect.isNotEmpty) {
        // Find the description in defect list if needed - original screen had it commented out
        // For now we assume description is tracked separately or from first defect
      }
      if (state.defect.internalNote.isNotEmpty) {
        _internalNoteController.text = state.defect.internalNote.join('\n');
      }
    }
  }

  void _updateCanProceed() {
    if (mounted) {
      widget.onCanProceedChanged(_problemDescriptionController.text.trim().isNotEmpty);
    }
  }

  void _saveToCubit() {
    final internalNotes = _internalNoteController.text.trim().isNotEmpty
        ? [_internalNoteController.text.trim()]
        : <String>[];

    // Update internal notes in cubit
    context.read<JobBookingCubit>().updateDefectInfo(
      internalNote: internalNotes,
      // Problem description itself might need to be added as a defect item
      // depending on how backend expects it.
    );
  }

  /// Exposed for wizard navigation
  bool validate() {
    if (_problemDescriptionController.text.trim().isNotEmpty) {
      _saveToCubit();
      return true;
    }
    showCustomToast('Please describe the problem', isError: true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 24.h),
              TitleWidget(stepNumber: 9, title: 'Problem Description', subTitle: '(Describe the defect and issue)'),
              SizedBox(height: 32.h),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Problem Description*', style: AppTypography.fontSize16),
                SizedBox(height: 8.h),
                TextField(
                  controller: _problemDescriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Describe the problem in detail',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text('Internal Note', style: AppTypography.fontSize16),
                SizedBox(height: 8.h),
                TextField(
                  controller: _internalNoteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add internal notes (optional)',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
        const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
      ],
    );
  }

  @override
  void dispose() {
    _problemDescriptionController.dispose();
    _internalNoteController.dispose();
    super.dispose();
  }
}
