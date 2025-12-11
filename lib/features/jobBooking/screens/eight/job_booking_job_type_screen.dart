// ignore_for_file: use_build_context_synchronously

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
  State<JobBookingJobTypeScreen> createState() => _JobBookingJobTypeScreenState();
}

class _JobBookingJobTypeScreenState extends State<JobBookingJobTypeScreen> {
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  String? selectedJobType;
  String? selectedJobTypeId;
  bool _isLoading = true;
  bool _isAddingJobType = false;
  late String _userId;
  late String _locationId;

  @override
  void initState() {
    super.initState();
    _userId = storage.read('userId') ?? '';
    _locationId = storage.read('locationId') ?? '';
    _loadJobTypes();
  }

  void _loadJobTypes() {
    if (_userId.isNotEmpty) {
      context.read<JobTypeCubit>().getJobTypes(userId: _userId).then((_) {
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

  Future<void> _addNewJobType(String jobTypeName) async {
    setState(() => _isAddingJobType = true);

    try {
      await context.read<JobTypeCubit>().createJobType(name: jobTypeName, userId: _userId, locationId: _locationId);

      final state = context.read<JobTypeCubit>().state;
      if (state is JobTypeLoaded) {
        final newJobType = state.jobTypes.firstWhere(
          (jobType) => jobType.name?.toLowerCase() == jobTypeName.toLowerCase(),
          orElse: () => JobType(),
        );

        setState(() {
          selectedJobType = jobTypeName;
          selectedJobTypeId = newJobType.sId;
          _jobTypeController.text = jobTypeName;
        });

        showCustomToast('Job type "$jobTypeName" added successfully!', isError: false);
      } else if (state is JobTypeError) {
        showCustomToast('Failed to add job type: ${state.message}', isError: true);
      }
    } catch (e) {
      showCustomToast('Failed to add job type: $e', isError: true);
    } finally {
      setState(() => _isAddingJobType = false);
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
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const JobBookingProblemDescriptionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else {
      showCustomToast('Please select a job type', isError: true);
    }
  }

  List<String> _getJobTypeNames(List<JobType> jobTypes) {
    return jobTypes.map((jobType) => jobType.name ?? '').where((name) => name.isNotEmpty).toList();
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
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
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
                        decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
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
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Center(
                    child: Text(
                      '8',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text('(Warranty, ReRepair, Quote req...)', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'Failed to load job types: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        List<JobType> jobTypes = [];
                        List<JobType> allJobTypes = [];

                        if (state is JobTypeLoaded) {
                          jobTypes = state.jobTypes;
                          allJobTypes = state.jobTypes;
                        }

                        return CustomDropdownSearch<JobType>(
                          controller: _jobTypeController,
                          items: jobTypes,
                          hintText: 'Search and select job type...',
                          noItemsText: 'No job types found',
                          displayAllSuggestionWhenTap: true,
                          isMultiSelectDropdown: false,
                          onSuggestionSelected: (JobType jobType) async {
                            if (jobType.sId == null && jobType.name?.startsWith('Add "') == true) {
                              final jobTypeName = jobType.name?.split('"')[1] ?? '';
                              if (jobTypeName.isNotEmpty) {
                                await _addNewJobType(jobTypeName);
                              }
                            } else {
                              setState(() {
                                selectedJobType = jobType.name;
                                selectedJobTypeId = jobType.sId;
                                _jobTypeController.text = jobType.name ?? '';
                              });
                            }
                          },
                          itemBuilder: (BuildContext context, JobType jobType) {
                            final isNewOption = jobType.sId == null && jobType.name?.startsWith('Add "') == true;

                            if (isNewOption) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        jobType.name?.split('"')[1] ?? '',
                                        style: AppTypography.fontSize16.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          'NEW',
                                          style: AppTypography.fontSize12.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: selectedJobType == jobType.name ? const Color(0xFFFFF59D) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ListTile(
                                title: Text(
                                  jobType.name ?? 'Unknown Job Type',
                                  style: AppTypography.fontSize16.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                          suggestionsCallback: (String pattern) {
                            if (pattern.isEmpty) return allJobTypes;

                            final filteredJobTypes = allJobTypes
                                .where((jobType) => (jobType.name ?? '').toLowerCase().contains(pattern.toLowerCase()))
                                .toList();

                            final exactMatch = filteredJobTypes.any(
                              (jobType) => jobType.name?.toLowerCase() == pattern.toLowerCase(),
                            );

                            if (!exactMatch && pattern.isNotEmpty) {
                              filteredJobTypes.insert(0, JobType(sId: null, name: 'Add "$pattern" as new job type'));
                            }

                            return filteredJobTypes;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Show adding indicator
                    if (_isAddingJobType)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 16.w, height: 16.h, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8.w),
                            Text('Adding job type...', style: AppTypography.fontSize14.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Reference field
                    const Text(
                      'Reference',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _referenceController,
                      decoration: InputDecoration(
                        hintText: 'Enter reference',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selected: $selectedJobType',
                                style: TextStyle(fontSize: 14, color: Colors.green[800], fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 100), // Extra space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8, left: 24, right: 24),
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
