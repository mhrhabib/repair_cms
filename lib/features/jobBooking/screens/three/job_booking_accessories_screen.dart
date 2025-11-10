import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/enhanced_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/cubits/accessories/accessories_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/accessories_model.dart';
import 'package:repair_cms/features/jobBooking/screens/four/job_booking_imei_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingAccessoriesScreen extends StatefulWidget {
  const JobBookingAccessoriesScreen({super.key});

  @override
  State<JobBookingAccessoriesScreen> createState() => _JobBookingAccessoriesScreenState();
}

class _JobBookingAccessoriesScreenState extends State<JobBookingAccessoriesScreen> {
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

    // You can store the accessory ID if needed for your job booking
    // context.read<JobBookingCubit>().updateAccessoryInfo(accessory: accessoryName, accessoryId: accessoryId);
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

      // The cubit will automatically refresh the list

      // Select the newly created accessory
      _selectAccessory(accessoryName, ''); // The ID will be available after refresh

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Accessory "$accessoryName" created successfully'), backgroundColor: Colors.green),
      // );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create accessory: $e'), backgroundColor: Colors.red));
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * .071 * 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF71788F),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                        ),
                      ),
                    ),

                    // Step indicator
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 42.w,
                        height: 42.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('3', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Question text
                    Text('Any Accessories included?', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                    SizedBox(height: 4.h),

                    Text(
                      '(Cable, Battery, Case...)',
                      style: AppTypography.fontSize22.copyWith(fontWeight: FontWeight.normal),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
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
                              style: AppTypography.fontSize14.copyWith(color: Colors.red),
                            ),
                            SizedBox(height: 8.h),
                            ElevatedButton(
                              onPressed: () {
                                context.read<AccessoriesCubit>().getAccessories(userId: _userId);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is AccessoriesLoaded || state is AccessoriesSearchResult) {
                      final accessories = state is AccessoriesLoaded
                          ? state.accessories
                          : (state as AccessoriesSearchResult).accessories;

                      return EnhancedDropdownSearch<Data>(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        items: accessories,
                        hintText: 'Search and select accessory...',
                        noItemsText: 'No accessories found',
                        onSuggestionSelected: (accessory) {
                          _selectAccessory(accessory.label ?? 'Unknown Accessory', accessory.sId ?? '');
                        },
                        itemBuilder: (context, accessory) => ListTile(
                          title: Text(
                            accessory.label ?? 'Unknown Accessory',
                            style: AppTypography.fontSize14.copyWith(color: Colors.black),
                          ),
                          subtitle: accessory.value != null
                              ? Text(
                                  'Value: ${accessory.value}',
                                  style: AppTypography.fontSize12.copyWith(color: Colors.grey),
                                )
                              : null,
                        ),
                        suggestionsCallback: (pattern) {
                          if (pattern.isEmpty) {
                            return accessories;
                          }

                          // Use cubit search functionality
                          if (pattern.isNotEmpty) {
                            context.read<AccessoriesCubit>().searchAccessories(pattern);
                          } else {
                            context.read<AccessoriesCubit>().clearSearch();
                          }

                          final currentState = context.read<AccessoriesCubit>().state;
                          if (currentState is AccessoriesLoaded || currentState is AccessoriesSearchResult) {
                            final availableAccessories = currentState is AccessoriesLoaded
                                ? currentState.accessories
                                : (currentState as AccessoriesSearchResult).accessories;

                            return availableAccessories
                                .where(
                                  (accessory) => (accessory.label ?? '').toLowerCase().contains(pattern.toLowerCase()),
                                )
                                .toList();
                          }
                          return [];
                        },
                        noItemsFoundBuilder: (context, pattern) {
                          if (pattern.isEmpty) return const SizedBox();

                          return ListTile(
                            leading: Icon(Icons.add_circle_outline, color: AppColors.primary),
                            title: Text(
                              'Create "$pattern"',
                              style: AppTypography.fontSize14.copyWith(color: AppColors.primary),
                            ),
                            subtitle: Text(
                              'Add as new accessory',
                              style: AppTypography.fontSize12.copyWith(color: Colors.grey),
                            ),
                            onTap: () {
                              _createNewAccessory(pattern);
                            },
                          );
                        },
                        customSuggestionBuilder: (context, pattern, filteredItems) {
                          if (pattern.isNotEmpty && filteredItems.isEmpty && !_isCreatingAccessory) {
                            return Column(
                              children: [
                                const Divider(height: 1),
                                ListTile(
                                  leading: Icon(Icons.add_circle_outline, color: AppColors.primary),
                                  title: Text(
                                    'Create "$pattern"',
                                    style: AppTypography.fontSize14.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Add as new accessory',
                                    style: AppTypography.fontSize12.copyWith(color: Colors.grey),
                                  ),
                                  trailing: _isCreatingAccessory
                                      ? SizedBox(
                                          width: 16.w,
                                          height: 16.h,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.primary),
                                  onTap: () {
                                    _createNewAccessory(pattern);
                                  },
                                ),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      );
                    }

                    // Initial state
                    return EnhancedDropdownSearch<Data>(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      items: [],
                      hintText: 'Loading accessories...',
                      noItemsText: 'No accessories available',
                      onSuggestionSelected: (accessory) {},
                      itemBuilder: (context, accessory) => ListTile(title: Text(accessory.label ?? 'Unknown')),
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
                        SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Creating new accessory...',
                            style: AppTypography.fontSize14.copyWith(color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Show selected accessory info
            if (_selectedAccessory.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Accessory',
                                style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
                              ),
                              Text(
                                _selectedAccessory,
                                style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary),
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
                          },
                          child: Icon(Icons.close, color: Colors.grey, size: 20.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Show accessories count when loaded
            BlocBuilder<AccessoriesCubit, AccessoriesState>(
              builder: (context, state) {
                if (state is AccessoriesLoaded && state.accessories.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        '${state.accessories.length} accessories available',
                        style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
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

      // Fixed bottom navigation bar with keyboard handling
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8.h, left: 24.w, right: 24.w),
        child: BottomButtonsGroup(
          onPressed: _selectedAccessory.isNotEmpty && !_isCreatingAccessory
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => JobBookingImeiScreen()));
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text('Selected accessory: $_selectedAccessory'),
                  //     backgroundColor: AppColors.primary,
                  //   ),
                  // );
                }
              : null,
        ),
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
