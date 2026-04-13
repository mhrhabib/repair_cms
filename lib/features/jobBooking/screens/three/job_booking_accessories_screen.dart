import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/cubits/accessories/accessories_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/accessories_model.dart';
import 'package:repair_cms/features/jobBooking/screens/four/job_booking_imei_screen.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/features/jobBooking/widgets/job_booking_top_bar.dart';

class JobBookingAccessoriesScreen extends StatefulWidget {
  const JobBookingAccessoriesScreen({super.key});

  @override
  State<JobBookingAccessoriesScreen> createState() =>
      _JobBookingAccessoriesScreenState();
}

class _JobBookingAccessoriesScreenState
    extends State<JobBookingAccessoriesScreen> {
  String _selectedAccessory = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late String _userId;
  bool _isCreatingAccessory = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);

    // Get user ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userId = _getUserId();

      // Load accessories when screen initializes
      context.read<AccessoriesCubit>().getAccessories(userId: _userId);
    });
  }

  String _getUserId() {
    // Replace this with your actual user ID retrieval logic
    return '64106cddcfcedd360d7096cc'; // Example user ID
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      // Handle focus loss if needed
    }
  }

  void _selectAccessory(String accessoryName, String accessoryId) {
    setState(() {
      _selectedAccessory = accessoryName;
      _searchController.text = accessoryName;
    });

    context.read<JobBookingCubit>().updateDeviceInfo(
      condition: [ConditionItem(value: accessoryName, id: accessoryId)],
    );
  }

  Future<void> _createNewAccessory(String accessoryName) async {
    setState(() {
      _isCreatingAccessory = true;
    });

    try {
      // Use AccessoriesCubit to create the accessory
      await context.read<AccessoriesCubit>().createAccessory(
        value: accessoryName,
        label: accessoryName,
        userId: _userId,
      );

      if (!mounted) return;

      // The cubit will automatically refresh the list

      // Select the newly created accessory
      _selectAccessory(
        accessoryName,
        '',
      ); // The ID will be available after refresh

      // showCustomToast('Accessory "$accessoryName" created successfully', isError: false);
    } catch (e) {
      showCustomToast('Failed to create accessory: $e', isError: true);
    } finally {
      setState(() {
        _isCreatingAccessory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),
                  JobBookingTopBar(
                    stepNumber: 3,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Any Accessories included?',
                          style: AppTypography.fontSize22,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '(Cable, Battery, Case...)',
                          style: AppTypography.fontSize22.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dropdown section with AccessoriesCubit integration
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<AccessoriesCubit, AccessoriesState>(
                  builder: (context, state) {
                    if (state is AccessoriesLoading) {
                      return SizedBox(
                        height: 60.h,
                        child: const Center(child: CircularProgressIndicator()),
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
                              onPressed: () {
                                context.read<AccessoriesCubit>().getAccessories(
                                  userId: _userId,
                                );
                              },
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
                        hintText: 'Search and select accessory...',
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
                                      style: AppTypography.fontSize16.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
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
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        'NEW',
                                        style:
                                            AppTypography.fontSize12.copyWith(
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
                                style: AppTypography.fontSize16.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
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
                            (a) =>
                                a.label?.toLowerCase() == pattern.toLowerCase(),
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

                    // Initial state
                    return CustomDropdownSearch<Data>(
                      controller: _searchController,
                      items: [],
                      hintText: 'Loading accessories...',
                      noItemsText: 'No accessories available',
                      displayAllSuggestionWhenTap: false,
                      isMultiSelectDropdown: false,
                      onSuggestionSelected: (accessory) {},
                      itemBuilder: (context, accessory) =>
                          ListTile(title: Text(accessory.label ?? 'Unknown')),
                      suggestionsCallback: (pattern) => [],
                    );
                  },
                ),
              ),
            ),

            // Show creating state
            if (_isCreatingAccessory)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
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

            // Show selected accessory info
            BlocBuilder<JobBookingCubit, JobBookingState>(
              builder: (context, bookingState) {
                final selectedAccessories =
                    bookingState is JobBookingData
                        ? bookingState.device.condition
                        : <ConditionItem>[];
                final accessoryName =
                    selectedAccessories.isNotEmpty
                        ? selectedAccessories.first.value
                        : '';

                if (accessoryName.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Accessory',
                                    style: AppTypography.fontSize12.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    accessoryName,
                                    style: AppTypography.fontSize16Bold
                                        .copyWith(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAccessory = '';
                                  _searchController.clear();
                                });
                                context.read<JobBookingCubit>().updateDeviceInfo(
                                  condition: [],
                                );
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Show accessories count when loaded
            BlocBuilder<AccessoriesCubit, AccessoriesState>(
              builder: (context, state) {
                if (state is AccessoriesLoaded &&
                    state.accessories.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        '${state.accessories.length} accessories available',
                        style: AppTypography.fontSize12.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Spacer to push buttons to bottom
            const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
          ],
        ),
      ),

      bottomNavigationBar: BlocBuilder<JobBookingCubit, JobBookingState>(
        builder: (context, bookingState) {
          final hasSelectedAccessory =
              bookingState is JobBookingData &&
              bookingState.device.condition.isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 8.h,
              left: 24.w,
              right: 24.w,
            ),
            child: BottomButtonsGroup(
              onPressed: hasSelectedAccessory && !_isCreatingAccessory
                  ? () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  JobBookingImeiScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
