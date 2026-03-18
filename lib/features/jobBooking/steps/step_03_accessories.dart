import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/core/utils/widgets/shimmer_loader.dart';
import 'package:repair_cms/features/jobBooking/cubits/accessories/accessories_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/accessories_model.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

class StepAccessoriesWidget extends StatefulWidget {
  const StepAccessoriesWidget({super.key, required this.onCanProceedChanged});

  // Step 3: Accessories is always "can proceed" (can skip with no selection)
  // But original screen required a selection. We match original: enabled only when selected.
  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepAccessoriesWidget> createState() => StepAccessoriesWidgetState();
}

class StepAccessoriesWidgetState extends State<StepAccessoriesWidget> {
  String _selectedAccessory = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isCreatingAccessory = false;
  final String _userId = '64106cddcfcedd360d7096cc';

  bool validate() {
    if (_selectedAccessory.isNotEmpty) {
      context.read<JobBookingCubit>().updateDeviceInfo(
        condition: [ConditionItem(value: _selectedAccessory, id: '')],
      );
      return true;
    }
    showCustomToast('Please select or add an accessory', isError: true);
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccessoriesCubit>().getAccessories(userId: _userId);

      // Restore state from Cubit
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        final condition = bookingState.device.condition;
        if (condition.isNotEmpty) {
          setState(() {
            _selectedAccessory = condition.first.value;
            _searchController.text = condition.first.value;
          });
          widget.onCanProceedChanged(true);
        }
      }
    });
  }

  void _selectAccessory(String accessoryName, String accessoryId) {
    setState(() {
      _selectedAccessory = accessoryName;
      _searchController.text = accessoryName;
    });
    widget.onCanProceedChanged(accessoryName.isNotEmpty);
  }

  Future<void> _createNewAccessory(String accessoryName) async {
    setState(() => _isCreatingAccessory = true);
    try {
      await context.read<AccessoriesCubit>().createAccessory(
        value: accessoryName,
        label: accessoryName,
        userId: _userId,
      );
      if (!mounted) return;
      _selectAccessory(accessoryName, '');
    } catch (e) {
      showCustomToast('Failed to create accessory: $e', isError: true);
    } finally {
      setState(() => _isCreatingAccessory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                TitleWidget(
                  title: 'Any Accessories included?',
                  subTitle: '(Cable, Battery, Case...)',
                  stepNumber: 3,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: BlocBuilder<AccessoriesCubit, AccessoriesState>(
              builder: (context, state) {
                if (state is AccessoriesLoading) {
                  return SizedBox(
                    height: 60.h,
                    child: const Center(child: ShimmerLoader()),
                  );
                }
                if (state is AccessoriesError) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Failed to load accessories',
                          style: AppTypography.fontSize14.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () => context
                              .read<AccessoriesCubit>()
                              .getAccessories(userId: _userId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AccessoriesLoaded ||
                    state is AccessoriesSearchResult) {
                  final accessories = state is AccessoriesLoaded
                      ? state.accessories
                      : (state as AccessoriesSearchResult).accessories;
                  final allAccessories = state is AccessoriesLoaded
                      ? state.accessories
                      : (state as AccessoriesSearchResult).allAccessories;

                  return CustomDropdownSearch<Data>(
                    controller: _searchController,
                    items: accessories,
                    hintText: 'Answer here',
                    noItemsText: 'No accessories found',
                    displayAllSuggestionWhenTap: true,
                    isMultiSelectDropdown: false,
                    suggestionsBoxColor: AppColors.whiteColor,
                    onSuggestionSelected: (accessory) async {
                      if (accessory.sId == null &&
                          accessory.label?.startsWith('Add "') == true) {
                        final accessoryName =
                            accessory.label?.split('"')[1] ?? '';
                        if (accessoryName.isNotEmpty) {
                          await _createNewAccessory(accessoryName);
                        }
                      } else {
                        _selectAccessory(
                          accessory.label ?? 'Unknown Accessory',
                          accessory.sId ?? '',
                        );
                      }
                    },
                    itemBuilder: (context, accessory) {
                      final isNewOption =
                          accessory.sId == null &&
                          accessory.label?.startsWith('Add "') == true;

                      if (isNewOption) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  accessory.label?.split('"')[1] ?? '',
                                  style: GoogleFonts.roboto(
                                    fontSize: 22.sp,
                                    color: AppColors.fontMainColor,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
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
                          color: _selectedAccessory == accessory.label
                              ? const Color(0xFFFFF59D)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ListTile(
                          title: Text(
                            accessory.label ?? 'Unknown Accessory',
                            style: GoogleFonts.roboto(
                              fontSize: 22.sp,
                              color: AppColors.fontMainColor,
                            ),
                          ),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) {
                      if (pattern.isEmpty) return allAccessories;

                      final filtered = allAccessories
                          .where(
                            (a) => (a.label ?? '').toLowerCase().contains(
                              pattern.toLowerCase(),
                            ),
                          )
                          .toList();

                      final exactMatch = filtered.any(
                        (a) => a.label?.toLowerCase() == pattern.toLowerCase(),
                      );

                      if (!exactMatch && pattern.isNotEmpty) {
                        filtered.insert(
                          0,
                          Data(
                            sId: null,
                            label: 'Add "$pattern" as new accessory',
                          ),
                        );
                      }

                      return filtered;
                    },
                  );
                }

                return CustomDropdownSearch<Data>(
                  controller: _searchController,
                  items: [],
                  hintText: 'Loading accessories...',
                  noItemsText: 'No accessories available',
                  displayAllSuggestionWhenTap: false,
                  isMultiSelectDropdown: false,
                  onSuggestionSelected: (a) {},
                  itemBuilder: (context, a) =>
                      ListTile(title: Text(a.label ?? 'Unknown')),
                  suggestionsCallback: (p) => [],
                );
              },
            ),
          ),
        ),

        if (_isCreatingAccessory)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Creating new accessory...',
                        style: AppTypography.fontSize14.copyWith(
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // if (_selectedAccessory.isNotEmpty)
        //   SliverToBoxAdapter(
        //     child: Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        //       child: Container(
        //         padding: EdgeInsets.all(16.w),
        //         decoration: BoxDecoration(
        //           color: AppColors.primary.withValues(alpha: 0.1),
        //           borderRadius: BorderRadius.circular(12.r),
        //           border: Border.all(color: AppColors.primary),
        //         ),
        //         child: Row(
        //           children: [
        //             Icon(
        //               Icons.check_circle,
        //               color: AppColors.primary,
        //               size: 20.sp,
        //             ),
        //             SizedBox(width: 12.w),
        //             Expanded(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(
        //                     'Selected Accessory',
        //                     style: AppTypography.fontSize12.copyWith(
        //                       color: Colors.grey.shade600,
        //                     ),
        //                   ),
        //                   Text(
        //                     _selectedAccessory,
        //                     style: AppTypography.fontSize16Bold.copyWith(
        //                       color: AppColors.primary,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             GestureDetector(
        //               onTap: () {
        //                 setState(() {
        //                   _selectedAccessory = '';
        //                   _searchController.clear();
        //                 });
        //                 widget.onCanProceedChanged(false);
        //               },
        //               child: Icon(Icons.close, color: Colors.grey, size: 20.sp),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // BlocBuilder<AccessoriesCubit, AccessoriesState>(
        //   builder: (context, state) {
        //     if (state is AccessoriesLoaded && state.accessories.isNotEmpty) {
        //       return SliverToBoxAdapter(
        //         child: Padding(
        //           padding: EdgeInsets.symmetric(horizontal: 24.w),
        //           child: Text(
        //             '${state.accessories.length} accessories available',
        //             style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //       );
        //     }
        //     return const SliverToBoxAdapter(child: SizedBox.shrink());
        //   },
        // ),
        const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
