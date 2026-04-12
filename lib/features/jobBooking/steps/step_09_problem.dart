import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 9 – Problem Description (Required) and Internal Note (Optional)
class StepProblemWidget extends StatefulWidget {
  const StepProblemWidget({super.key, required this.onCanProceedChanged});

  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepProblemWidget> createState() => StepProblemWidgetState();
}

class StepProblemWidgetState extends State<StepProblemWidget> {
  final TextEditingController _problemDescriptionController =
      TextEditingController();
  final TextEditingController _internalNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _problemDescriptionController.addListener(_updateCanProceed);

    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(
        _problemDescriptionController.text.trim().isNotEmpty,
      );
    });
  }

  void _loadExistingData() {
    final state = context.read<JobBookingCubit>().state;
    if (state is JobBookingData) {
      if (state.defect.defect.isNotEmpty) {
        // We use the first defect item's value as the problem description
        _problemDescriptionController.text = state.defect.defect.first.value;
      }
      if (state.defect.internalNote.isNotEmpty) {
        // Each note may be a Map (new structured format) or a plain String
        // (legacy). Extract the text field for display either way.
        _internalNoteController.text = state.defect.internalNote
            .map((note) {
              if (note is Map) return (note['text'] ?? '').toString();
              return note?.toString() ?? '';
            })
            .where((text) => text.isNotEmpty)
            .join('\n');
      }
    }
  }

  void _updateCanProceed() {
    if (mounted) {
      widget.onCanProceedChanged(
        _problemDescriptionController.text.trim().isNotEmpty,
      );
    }
  }

  void _saveToCubit() {
    final noteText = _internalNoteController.text.trim();

    final List<dynamic> internalNotes;
    if (noteText.isNotEmpty) {
      final storage = GetStorage();
      final String userId = (storage.read('userId') ?? '').toString();
      final String userName = (storage.read('fullName') ?? '').toString();
      final String createdAt = DateTime.now().toIso8601String();
      final String idSuffix = userId.length >= 8
          ? userId.substring(0, 8)
          : userId;
      final String noteId =
          '${DateTime.now().millisecondsSinceEpoch}-$idSuffix';

      internalNotes = [
        {
          'text': noteText,
          'userId': userId,
          'createdAt': createdAt,
          'userName': userName,
          'id': noteId,
        },
      ];
    } else {
      internalNotes = <dynamic>[];
    }

    // Update internal notes and defect description in cubit
    context.read<JobBookingCubit>().updateDefectInfo(
      internalNote: internalNotes,
      defect: [
        DefectItem(
          value: _problemDescriptionController.text.trim(),
          id: 'problem_description', // Placeholder ID if backend doesn't require a real one here
        ),
      ],
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TitleWidget(
                  stepNumber: 9,
                  title: 'Problem Description',
                  subTitle: '(Describe the defect and issue)',
                ),
              ),
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
                  cursorColor: AppColors.warningColor,
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
                  cursorColor: AppColors.warningColor,
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
