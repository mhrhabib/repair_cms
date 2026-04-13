import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/ten/job_booking_add_items_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/features/jobBooking/widgets/job_booking_top_bar.dart';

class JobBookingProblemDescriptionScreen extends StatefulWidget {
  const JobBookingProblemDescriptionScreen({super.key});

  @override
  State<JobBookingProblemDescriptionScreen> createState() =>
      _JobBookingProblemDescriptionScreenState();
}

class _JobBookingProblemDescriptionScreenState
    extends State<JobBookingProblemDescriptionScreen> {
  final TextEditingController _problemDescriptionController =
      TextEditingController();
  final TextEditingController _internalNoteController = TextEditingController();

  bool _isProblemDescriptionValid = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _problemDescriptionController.addListener(_validateProblemDescription);
  }

  void _loadExistingData() {
    final state = context.read<JobBookingCubit>().state;
    if (state is JobBookingData) {
      // Load existing defect description
      if (state.defect.defect.isNotEmpty) {
        // _problemDescriptionController.text = state.defect.defect.first.description;
      }

      // Load existing internal notes
      if (state.defect.internalNote.isNotEmpty) {
        _internalNoteController.text = state.defect.internalNote.join('\n');
      }

      // Validate existing problem description
      _validateProblemDescription();
    }
  }

  void _validateProblemDescription() {
    setState(() {
      _isProblemDescriptionValid = _problemDescriptionController.text
          .trim()
          .isNotEmpty;
    });
  }

  void _saveDataAndNavigate() {
    if (_isProblemDescriptionValid) {
      final cubit = context.read<JobBookingCubit>();

      // Prepare defect items

      // Prepare internal notes
      final internalNotes = _internalNoteController.text.trim().isNotEmpty
          ? [_internalNoteController.text.trim()]
          : <String>[];

      // Update defect information in cubit
      cubit.updateDefectInfo(internalNote: internalNotes);

      // Navigate to next screen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const JobBookingAddItemsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else {
      // Show error message
      showCustomToast('Please describe the problem', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBookingCubit, JobBookingState>(
      listener: (context, state) {
        // Handle any state changes if needed
        if (state is JobBookingData) {}
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 16,
                    right: 16,
                    bottom: 0,
                  ),
                  child: JobBookingTopBar(
                    padding: 2,
                    stepNumber: 9,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 24)),

              // Title and subtitle
              SliverToBoxAdapter(
                child: const Column(
                  children: [
                    Text(
                      'Problem Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '(Describe the defect and issue)',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 32)),

              // Form content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Problem Description field
                      const Text(
                        'Problem Description*',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _problemDescriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe the problem in detail',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          //errorText: _isProblemDescriptionValid ? null : 'Problem description is required',
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (value) => _validateProblemDescription(),
                      ),

                      const SizedBox(height: 24),

                      // Internal Note field
                      const Text(
                        'Internal Note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _internalNoteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add internal notes (optional)',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            left: 24,
            right: 24,
          ),
          child: BottomButtonsGroup(onPressed: _saveDataAndNavigate),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _problemDescriptionController.dispose();
    _internalNoteController.dispose();
    super.dispose();
  }
}
