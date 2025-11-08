// ignore_for_file: use_build_context_synchronously

import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/cubits/brands/brand_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/brand_model.dart';
import 'package:repair_cms/features/jobBooking/screens/two/job_booking_device_model_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingStartBookingJobScreen extends StatefulWidget {
  const JobBookingStartBookingJobScreen({super.key});
  @override
  State<JobBookingStartBookingJobScreen> createState() => _JobBookingStartBookingJobScreenState();
}

class _JobBookingStartBookingJobScreenState extends State<JobBookingStartBookingJobScreen> {
  String _selectedBrand = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late String _userId;
  bool _isAddingBrand = false;
  String? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _userId = _getUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandCubit>().getBrands(userId: _userId);
    });
  }

  String _getUserId() {
    return '64106cddcfcedd360d7096cc';
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      // Handle focus loss if needed
    }
  }

  void _selectBrand(String brandName) {
    setState(() {
      _selectedBrand = brandName;
      _searchController.text = brandName;
    });
    context.read<JobBookingCubit>().updateDeviceInfo(brand: brandName);
  }

  Future<void> _addNewBrand(String brandName) async {
    setState(() => _isAddingBrand = true);

    await context.read<BrandCubit>().addBrand(userId: _userId, name: brandName);

    final state = context.read<BrandCubit>().state;
    if (state is BrandAdded) {
      _selectBrand(brandName);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Brand "$brandName" added successfully!'), backgroundColor: Colors.green));
    } else if (state is BrandAddError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add brand: ${state.message}'), backgroundColor: Colors.red));
    }

    setState(() => _isAddingBrand = false);
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
                    width: MediaQuery.of(context).size.width * .071,
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

                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 42.w,
                        height: 42.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('1', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text('What is the device brand', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                    SizedBox(height: 4.h),

                    Text(
                      '(E.g. Samsung, Apple, Cannon)',
                      style: AppTypography.fontSize22.copyWith(fontWeight: FontWeight.normal),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Dropdown section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<BrandCubit, BrandState>(
                  builder: (context, state) {
                    if (state is BrandLoading) {
                      return SizedBox(
                        height: 60.h,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (state is BrandError) {
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          children: [
                            Text('Failed to load brands', style: AppTypography.fontSize14.copyWith(color: Colors.red)),
                            SizedBox(height: 8.h),
                            ElevatedButton(
                              onPressed: () => context.read<BrandCubit>().getBrands(userId: _userId),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is BrandLoaded || state is BrandSearchResult) {
                      final brands = state is BrandLoaded ? state.brands : (state as BrandSearchResult).brands;
                      final allBrands = state is BrandLoaded ? state.brands : (state as BrandSearchResult).allBrands;

                      return CustomDropdownSearch<BrandModel>(
                        controller: _searchController,
                        items: brands,
                        hintText: 'Search and select brand...',
                        noItemsText: 'No brands found',
                        displayAllSuggestionWhenTap: true,
                        isMultiSelectDropdown: false,
                        onSuggestionSelected: (brand) async {
                          // Check if this is the "Add new" option
                          if (brand.id == null && brand.name?.startsWith('Add "') == true) {
                            // Extract the brand name from 'Add "BrandName" as new brand'

                            final brandName = brand.name?.split('"')[1] ?? '';
                            if (brandName.isNotEmpty) {
                              await _addNewBrand(brandName);
                            }
                          } else {
                            setState(() {
                              _selectedBrandId = brand.id;
                            });
                            _selectBrand(brand.name ?? 'Unknown Brand');
                          }
                        },
                        itemBuilder: (context, brand) {
                          // Check if this is a "new" brand (add new option)
                          final isNewOption = brand.id == null && brand.name?.startsWith('Add "') == true;

                          if (isNewOption) {
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD), // Light blue background
                                border: Border.all(color: AppColors.primary, width: 1.5),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      brand.name?.split('"')[1] ?? '',
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

                          // Regular brand item with yellow highlight for selected
                          return Container(
                            decoration: BoxDecoration(
                              color: _selectedBrand == brand.name
                                  ? const Color(0xFFFFF59D) // Yellow highlight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: ListTile(
                              title: Text(
                                brand.name ?? 'Unknown Brand',
                                style: AppTypography.fontSize16.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                        suggestionsCallback: (pattern) {
                          if (pattern.isEmpty) {
                            return allBrands;
                          }

                          final filteredBrands = allBrands
                              .where((brand) => (brand.name ?? '').toLowerCase().contains(pattern.toLowerCase()))
                              .toList();

                          // Add "Add new" option if no exact match
                          final exactMatch = filteredBrands.any(
                            (brand) => brand.name?.toLowerCase() == pattern.toLowerCase(),
                          );

                          if (!exactMatch && pattern.isNotEmpty) {
                            filteredBrands.insert(0, BrandModel(id: null, name: 'Add "$pattern" as new brand'));
                          }

                          return filteredBrands;
                        },
                      );
                    }

                    return CustomDropdownSearch<BrandModel>(
                      controller: _searchController,
                      items: [],
                      hintText: 'Loading brands...',
                      noItemsText: 'No brands available',
                      displayAllSuggestionWhenTap: false,
                      isMultiSelectDropdown: false,
                      onSuggestionSelected: (brand) {},
                      itemBuilder: (context, brand) => ListTile(title: Text(brand.name ?? 'Unknown')),
                      suggestionsCallback: (pattern) => [],
                    );
                  },
                ),
              ),
            ),

            // Show selected brand info
            BlocBuilder<JobBookingCubit, JobBookingState>(
              builder: (context, bookingState) {
                final deviceBrand = bookingState is JobBookingData ? bookingState.device.brand : '';

                if (deviceBrand.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
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
                                    'Selected Brand',
                                    style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    deviceBrand,
                                    style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBrand = '';
                                  _searchController.clear();
                                });
                                context.read<JobBookingCubit>().updateDeviceInfo(brand: '');
                              },
                              child: Icon(Icons.close, color: Colors.grey, size: 20.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Show adding indicator
            if (_isAddingBrand)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16.w, height: 16.h, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8.w),
                      Text('Adding brand...', style: AppTypography.fontSize14.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

            // Show brands count
            BlocBuilder<BrandCubit, BrandState>(
              builder: (context, state) {
                if (state is BrandLoaded && state.brands.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        '${state.brands.length} brands available',
                        style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
          ],
        ),
      ),

      bottomNavigationBar: BlocBuilder<JobBookingCubit, JobBookingState>(
        builder: (context, bookingState) {
          final hasSelectedBrand = bookingState is JobBookingData && bookingState.device.brand.isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8.h, left: 24.w, right: 24.w),
            child: BottomButtonsGroup(
              onPressed: hasSelectedBrand
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => JobBookingDeviceModelScreen(brandId: _selectedBrandId!),
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
