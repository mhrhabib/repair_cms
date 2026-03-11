// ignore_for_file: use_build_context_synchronously

import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/cubits/brands/brand_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/brand_model.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';
import 'package:repair_cms/core/utils/widgets/shimmer_loader.dart';

class StepBrandWidget extends StatefulWidget {
  final void Function(bool canProceed) onCanProceedChanged;
  final void Function(String brandId, String brandName) onBrandSelected;

  const StepBrandWidget({
    super.key,
    required this.onCanProceedChanged,
    required this.onBrandSelected,
  });

  @override
  State<StepBrandWidget> createState() => StepBrandWidgetState();
}

class StepBrandWidgetState extends State<StepBrandWidget> {
  String _selectedBrand = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late String _userId;
  bool _isAddingBrand = false;

  bool validate() {
    if (_selectedBrand.isNotEmpty) return true;
    showCustomToast('Please select a brand', isError: true);
    return false;
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _userId = _getUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandCubit>().getBrands(userId: _userId);

      // Restore state from Cubit
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        final savedBrand = bookingState.device.brand;
        if (savedBrand.isNotEmpty) {
          setState(() {
            _selectedBrand = savedBrand;
            _searchController.text = savedBrand;
          });
          widget.onCanProceedChanged(true);
        }
      }
    });
  }

  String _getUserId() {
    return storage.read('userId') ?? '';
  }

  void _onFocusChange() {}

  void _selectBrand(String brandName) {
    setState(() {
      _selectedBrand = brandName;
      _searchController.text = brandName;
    });
    context.read<JobBookingCubit>().updateDeviceInfo(brand: brandName);
    widget.onCanProceedChanged(brandName.isNotEmpty);
  }

  Future<void> _addNewBrand(String brandName) async {
    setState(() => _isAddingBrand = true);

    await context.read<BrandCubit>().addBrand(userId: _userId, name: brandName);

    if (!mounted) return;

    final state = context.read<BrandCubit>().state;
    if (state is BrandAdded) {
      _selectBrand(brandName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Brand "$brandName" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is BrandError) {
      showCustomToast('Failed to add brand: ${state.message}', isError: true);
    }

    setState(() => _isAddingBrand = false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleWidget(
                      stepNumber: 1,
                      title: 'What is the device brand',
                      subTitle: '(E.g. Samsung, Apple, Cannon)',
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
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
                    child: Center(child: ShimmerLoader()),
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
                        Text(
                          'Failed to load brands',
                          style: AppTypography.fontSize14.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () => context.read<BrandCubit>().getBrands(
                            userId: _userId,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is BrandLoaded || state is BrandSearchResult) {
                  final brands = state is BrandLoaded
                      ? state.brands
                      : (state as BrandSearchResult).brands;
                  final allBrands = state is BrandLoaded
                      ? state.brands
                      : (state as BrandSearchResult).allBrands;

                  return CustomDropdownSearch<BrandModel>(
                    controller: _searchController,
                    items: brands,
                    hintText: 'Answer here',
                    noItemsText: 'No brands found',
                    displayAllSuggestionWhenTap: true,
                    isMultiSelectDropdown: false,
                    onSuggestionSelected: (brand) async {
                      if (brand.id == null &&
                          brand.name?.startsWith('Add "') == true) {
                        final brandName = brand.name?.split('"')[1] ?? '';
                        if (brandName.isNotEmpty) {
                          await _addNewBrand(brandName);
                        }
                      } else {
                        _selectBrand(brand.name ?? 'Unknown Brand');
                        if (brand.id != null) {
                          widget.onBrandSelected(
                            brand.id!,
                            brand.name ?? 'Unknown Brand',
                          );
                        }
                      }
                    },
                    itemBuilder: (context, brand) {
                      final isNewOption =
                          brand.id == null &&
                          brand.name?.startsWith('Add "') == true;

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
                                  brand.name?.split('"')[1] ?? '',
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
                          color: _selectedBrand == brand.name
                              ? const Color(0xFFFFF59D)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ListTile(
                          title: Text(
                            brand.name ?? 'Unknown Brand',
                            style: GoogleFonts.roboto(
                              fontSize: 22.sp,
                              color: AppColors.fontMainColor,
                            ),
                          ),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) {
                      if (pattern.isEmpty) return allBrands;

                      final filteredBrands = allBrands
                          .where(
                            (brand) => (brand.name ?? '')
                                .toLowerCase()
                                .contains(pattern.toLowerCase()),
                          )
                          .toList();

                      final exactMatch = filteredBrands.any(
                        (brand) =>
                            brand.name?.toLowerCase() == pattern.toLowerCase(),
                      );

                      if (!exactMatch && pattern.isNotEmpty) {
                        filteredBrands.insert(
                          0,
                          BrandModel(
                            id: null,
                            name: 'Add "$pattern" as new brand',
                          ),
                        );
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
                  itemBuilder: (context, brand) =>
                      ListTile(title: Text(brand.name ?? 'Unknown')),
                  suggestionsCallback: (pattern) => [],
                );
              },
            ),
          ),
        ),

        // Show selected brand info
        // BlocBuilder<JobBookingCubit, JobBookingState>(
        //   builder: (context, bookingState) {
        //     final deviceBrand = bookingState is JobBookingData
        //         ? bookingState.device.brand
        //         : '';

        //     if (deviceBrand.isNotEmpty) {
        //       return SliverToBoxAdapter(
        //         child: Padding(
        //           padding: EdgeInsets.symmetric(
        //             horizontal: 24.w,
        //             vertical: 16.h,
        //           ),
        //           child: Container(
        //             padding: EdgeInsets.all(16.w),
        //             decoration: BoxDecoration(
        //               color: AppColors.primary.withValues(alpha: 0.1),
        //               borderRadius: BorderRadius.circular(12.r),
        //               border: Border.all(color: AppColors.primary),
        //             ),
        //             child: Row(
        //               children: [
        //                 Icon(
        //                   Icons.check_circle,
        //                   color: AppColors.primary,
        //                   size: 20.sp,
        //                 ),
        //                 SizedBox(width: 12.w),
        //                 Expanded(
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Text(
        //                         'Selected Brand',
        //                         style: AppTypography.fontSize12.copyWith(
        //                           color: Colors.grey.shade600,
        //                         ),
        //                       ),
        //                       Text(
        //                         deviceBrand,
        //                         style: AppTypography.fontSize16Bold.copyWith(
        //                           color: AppColors.primary,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: () {
        //                     setState(() {
        //                       _selectedBrand = '';
        //                       _searchController.clear();
        //                     });
        //                     context.read<JobBookingCubit>().updateDeviceInfo(
        //                       brand: '',
        //                     );
        //                     widget.onCanProceedChanged(false);
        //                   },
        //                   child: Icon(
        //                     Icons.close,
        //                     color: Colors.grey,
        //                     size: 20.sp,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       );
        //     }

        //     return const SliverToBoxAdapter(child: SizedBox.shrink());
        //   },
        // ),

        // Adding indicator
        if (_isAddingBrand)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Adding brand...',
                    style: AppTypography.fontSize14.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Brands count
        // BlocBuilder<BrandCubit, BrandState>(
        //   builder: (context, state) {
        //     if (state is BrandLoaded && state.brands.isNotEmpty) {
        //       return SliverToBoxAdapter(
        //         child: Padding(
        //           padding: EdgeInsets.symmetric(horizontal: 24.w),
        //           child: Text(
        //             '${state.brands.length} brands available',
        //             style: AppTypography.fontSize12.copyWith(
        //               color: Colors.grey.shade600,
        //             ),
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
