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
  late String _userId; // You'll need to get this from your auth system

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);

    // Get user ID from your authentication system
    _userId = _getUserId(); // You need to implement this

    // Load brands when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandCubit>().getBrands(userId: _userId);
    });
  }

  String _getUserId() {
    // Replace this with your actual user ID retrieval logic
    // This could be from GetStorage, SharedPreferences, or your auth cubit
    return '64106cddcfcedd360d7096cc'; // Example user ID
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

    // Update JobBookingCubit with selected brand
    context.read<JobBookingCubit>().updateDeviceInfo(brand: brandName);
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

                    // Step indicator
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

                    // Question text
                    Text('Enter the device Brand', style: AppTypography.fontSize22, textAlign: TextAlign.center),

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

            // Dropdown section with BrandCubit integration
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<BrandCubit, BrandState>(
                  builder: (context, state) {
                    if (state is BrandLoading) {
                      return Container(
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

                      return CustomDropdownSearch<BrandModel>(
                        controller: _searchController,
                        items: brands,
                        hintText: 'Search and select brand...',
                        noItemsText: 'No brands found',
                        displayAllSuggestionWhenTap: true,
                        isMultiSelectDropdown: false,
                        onSuggestionSelected: (brand) {
                          _selectBrand(brand.name ?? 'Unknown Brand');
                        },
                        itemBuilder: (context, brand) => ListTile(
                          title: Text(
                            brand.name ?? 'Unknown Brand',
                            style: AppTypography.fontSize14.copyWith(color: Colors.black),
                          ),
                          subtitle: brand.id != null
                              ? Text('ID: ${brand.id}', style: AppTypography.fontSize12.copyWith(color: Colors.grey))
                              : null,
                        ),
                        suggestionsCallback: (pattern) {
                          // Use cubit search functionality
                          if (pattern.isNotEmpty) {
                            context.read<BrandCubit>().searchBrands(pattern);
                          } else {
                            context.read<BrandCubit>().clearSearch();
                          }

                          // Return filtered brands for the dropdown
                          final currentState = context.read<BrandCubit>().state;
                          if (currentState is BrandLoaded || currentState is BrandSearchResult) {
                            final availableBrands = currentState is BrandLoaded
                                ? currentState.brands
                                : (currentState as BrandSearchResult).brands;

                            return availableBrands
                                .where((brand) => (brand.name ?? '').toLowerCase().contains(pattern.toLowerCase()))
                                .toList();
                          }
                          return [];
                        },
                      );
                    }

                    // Initial state - show empty dropdown
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

            // Show brands count when loaded
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

            // Spacer to push buttons to bottom
            const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
          ],
        ),
      ),

      // Fixed bottom navigation bar with keyboard handling
      bottomNavigationBar: BlocBuilder<JobBookingCubit, JobBookingState>(
        builder: (context, bookingState) {
          final hasSelectedBrand = bookingState is JobBookingData && bookingState.device.brand.isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8.h, left: 24.w, right: 24.w),
            child: BottomButtonsGroup(
              onPressed: hasSelectedBrand
                  ? () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => JobBookingDeviceModelScreen()));

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('Selected brand: ${bookingState.device.brand}'),
                      //     backgroundColor: AppColors.primary,
                      //   ),
                      // );
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

// You can remove the DeviceBrand class since we're using BrandModel now
