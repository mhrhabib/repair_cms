import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/jobType/job_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/nine/job_booking_problem_description_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/models/job_type_model.dart';

class JobBookingJobTypeScreen extends StatefulWidget {
  const JobBookingJobTypeScreen({super.key});

  @override
  State<JobBookingJobTypeScreen> createState() =>
      _JobBookingJobTypeScreenState();
}

class _JobBookingJobTypeScreenState extends State<JobBookingJobTypeScreen> {
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  String? selectedJobType;
  String? selectedJobTypeId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobTypes();
  }

  void _loadJobTypes() {
    final userId = storage.read('userId') ?? '';
    if (userId.isNotEmpty) {
      context.read<JobTypeCubit>().getJobTypes(userId: userId).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveJobTypeToCubit() {
    if (selectedJobType != null) {
      final jobBookingCubit = context.read<JobBookingCubit>();
      jobBookingCubit.updateDefectInfo(jobType: selectedJobType);

      debugPrint('✅ Job type saved to JobBookingCubit: $selectedJobType');
    }
  }

  void _handleContinue() {
    if (selectedJobType != null) {
      _saveJobTypeToCubit();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const JobBookingProblemDescriptionScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a job type'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<String> _getJobTypeNames(List<JobType> jobTypes) {
    return jobTypes
        .map((jobType) => jobType.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Progress bar
            SliverToBoxAdapter(
              child: Container(
                height: 12.h,
                width: double.infinity,
                color: Colors.grey[300],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * .071 * 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Step indicator
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 24)),

            // Title and subtitle
            SliverToBoxAdapter(
              child: const Column(
                children: [
                  Text(
                    'Job Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '(Warranty, ReRepair, Quote req...)',
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
                    // Job Type Dropdown (Custom Search)
                    BlocBuilder<JobTypeCubit, JobTypeState>(
                      builder: (context, state) {
                        if (_isLoading) {
                          return Container(
                            height: 60,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          );
                        }

                        if (state is JobTypeError) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Failed to load job types: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        List<String> jobTypeNames = [];
                        List<JobType> jobTypes = [];

                        if (state is JobTypeLoaded) {
                          jobTypes = state.jobTypes;
                          jobTypeNames = _getJobTypeNames(jobTypes);

                          if (jobTypeNames.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'No job types available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                        }

                        return CustomDropdownSearch<String>(
                          controller: _jobTypeController,
                          items: jobTypeNames,
                          hintText: 'Select job type',
                          noItemsText: 'No job types found',
                          onSuggestionSelected: (String jobTypeName) {
                            final selectedJob = jobTypes.firstWhere(
                              (job) => job.name == jobTypeName,
                              orElse: () => JobType(),
                            );

                            setState(() {
                              selectedJobType = jobTypeName;
                              selectedJobTypeId = selectedJob.sId;
                              _jobTypeController.text = jobTypeName;
                            });
                          },
                          itemBuilder: (BuildContext context, String jobType) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Text(
                                jobType,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          },
                          suggestionsCallback: (String pattern) {
                            return jobTypeNames
                                .where(
                                  (jobType) => jobType.toLowerCase().contains(
                                    pattern.toLowerCase(),
                                  ),
                                )
                                .toList();
                          },
                          displayAllSuggestionWhenTap: true,
                          isMultiSelectDropdown: false,
                          maxHeight: 200.h,
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Reference field
                    const Text(
                      'Reference',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _referenceController,
                      decoration: InputDecoration(
                        hintText: 'Enter reference',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    // Selected job type info (optional)
                    if (selectedJobType != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selected: $selectedJobType',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(
                      height: 100,
                    ), // Extra space for bottom button
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
        child: BottomButtonsGroup(onPressed: _handleContinue),
      ),
    );
  }

  @override
  void dispose() {
    _jobTypeController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
