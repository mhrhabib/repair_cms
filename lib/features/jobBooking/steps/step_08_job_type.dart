import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/core/utils/widgets/shimmer_loader.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/jobType/job_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';
import 'package:repair_cms/features/jobBooking/models/job_type_model.dart';

/// Step 8 – Job Type Selection (e.g., Warranty, Repair, etc.)
class StepJobTypeWidget extends StatefulWidget {
  const StepJobTypeWidget({super.key, required this.onCanProceedChanged});

  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepJobTypeWidget> createState() => StepJobTypeWidgetState();
}

class StepJobTypeWidgetState extends State<StepJobTypeWidget> {
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  String? selectedJobType;
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

    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Restore state from Cubit
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        final savedJobType = bookingState.defect.jobType;
        if (savedJobType.isNotEmpty) {
          setState(() {
            selectedJobType = savedJobType;
            _jobTypeController.text = savedJobType;
          });
        }
      }
      widget.onCanProceedChanged(selectedJobType != null);
    });
  }

  void _loadJobTypes() {
    if (_userId.isNotEmpty) {
      context.read<JobTypeCubit>().getJobTypes(userId: _userId).then((_) {
        if (mounted) setState(() => _isLoading = false);
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addNewJobType(String jobTypeName) async {
    setState(() => _isAddingJobType = true);
    try {
      await context.read<JobTypeCubit>().createJobType(
        name: jobTypeName,
        userId: _userId,
        locationId: _locationId,
      );
      if (!mounted) return;
      final state = context.read<JobTypeCubit>().state;
      if (state is JobTypeLoaded) {
        setState(() {
          selectedJobType = jobTypeName;
          _jobTypeController.text = jobTypeName;
        });
        widget.onCanProceedChanged(true);
      }
    } catch (e) {
      showCustomToast('Failed to add job type: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAddingJobType = false);
    }
  }

  void _saveToCubit() {
    if (selectedJobType != null) {
      context.read<JobBookingCubit>().updateDefectInfo(
        jobType: selectedJobType,
        // Assuming reference also goes here if needed,
        // though original screen didn't save reference to cubit in _saveJobTypeToCubit
      );
    }
  }

  /// Exposed for wizard navigation
  bool validate() {
    if (selectedJobType != null) {
      _saveToCubit();
      return true;
    }
    showCustomToast('Please select a job type', isError: true);
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
                  stepNumber: 8,
                  title: 'Job Type',
                  subTitle: '(Warranty, ReRepair, Quote req...)',
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
                BlocBuilder<JobTypeCubit, JobTypeState>(
                  builder: (context, state) {
                    if (_isLoading) {
                      return const Center(child: ShimmerLoader());
                    }
                    if (state is JobTypeError) {
                      return Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }

                    final jobTypes = state is JobTypeLoaded
                        ? state.jobTypes
                        : <JobType>[];
                    return CustomDropdownSearch<JobType>(
                      controller: _jobTypeController,
                      items: jobTypes,
                      hintText: 'Answer here',
                      noItemsText: 'No job types found',
                      displayAllSuggestionWhenTap: true,
                      onSuggestionSelected: (jt) async {
                        if (jt.sId == null &&
                            jt.name?.startsWith('Add "') == true) {
                          final name = jt.name?.split('"')[1] ?? '';
                          if (name.isNotEmpty) await _addNewJobType(name);
                        } else {
                          setState(() {
                            selectedJobType = jt.name;
                            _jobTypeController.text = jt.name ?? '';
                          });
                          widget.onCanProceedChanged(true);
                        }
                      },
                      itemBuilder: (ctx, jt) {
                        final isNew =
                            jt.sId == null &&
                            jt.name?.startsWith('Add "') == true;
                        if (isNew) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: ListTile(
                              title: Text(
                                jt.name?.split('"')[1] ?? '',
                                style: GoogleFonts.roboto(
                                  fontSize: 22.sp,
                                  color: AppColors.fontMainColor,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListTile(
                          title: Text(
                            jt.name ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: 22.sp,
                              color: AppColors.fontMainColor,
                            ),
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        if (pattern.isEmpty) return jobTypes;
                        final filtered = jobTypes
                            .where(
                              (jt) => (jt.name ?? '').toLowerCase().contains(
                                pattern.toLowerCase(),
                              ),
                            )
                            .toList();
                        if (!filtered.any(
                              (jt) =>
                                  jt.name?.toLowerCase() ==
                                  pattern.toLowerCase(),
                            ) &&
                            pattern.isNotEmpty) {
                          filtered.insert(
                            0,
                            JobType(
                              sId: null,
                              name: 'Add "$pattern" as new job type',
                            ),
                          );
                        }
                        return filtered;
                      },
                    );
                  },
                ),
                if (_isAddingJobType)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: const Text(
                      'Adding...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                SizedBox(height: 24.h),

                TextField(
                  controller: _referenceController,
                  style: AppTypography.fontSize22.copyWith(fontSize: 32.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter reference',
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 32.sp,
                      color: Color(0xFFB2B5BE),
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightFontColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightFontColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightFontColor,
                        width: 1,
                      ),
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
    _jobTypeController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
