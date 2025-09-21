import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
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

  final List<DeviceBrand> _brands = [
    DeviceBrand(name: 'Apple', isNew: false),
    DeviceBrand(name: 'Apple1', isNew: true),
    DeviceBrand(name: 'Samsung', isNew: false),
    DeviceBrand(name: 'Huawei', isNew: false),
    DeviceBrand(name: 'OnePlus', isNew: false),
    DeviceBrand(name: 'Google', isNew: false),
    DeviceBrand(name: 'Xiaomi', isNew: false),
    DeviceBrand(name: 'Nokia', isNew: false),
    DeviceBrand(name: 'Sony', isNew: false),
    DeviceBrand(name: 'LG', isNew: false),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
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

            // Dropdown section

            // Using DropDownSearchField package
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    CustomDropdownSearch<DeviceBrand>(
                      controller: _searchController,
                      items: _brands,
                      hintText: 'Answer here',
                      noItemsText: 'No brands found',
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                      onSuggestionSelected: (brand) {
                        _selectBrand(brand.name);
                      },
                      itemBuilder: (context, brand) => ListTile(
                        title: Row(
                          children: [
                            Text(brand.name, style: AppTypography.fontSize14.copyWith(color: Colors.black)),
                            if (brand.isNew) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'NEW',
                                  style: AppTypography.fontSize10.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return _brands
                            .where((brand) => brand.name.toLowerCase().contains(pattern.toLowerCase()))
                            .toList();
                      },
                    ),
                  ],
                ),
              ),
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
          onPressed: _selectedBrand.isNotEmpty
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => JobBookingDeviceModelScreen()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected brand: $_selectedBrand'), backgroundColor: AppColors.primary),
                  );
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

class DeviceBrand {
  final String name;
  final bool isNew;

  DeviceBrand({required this.name, required this.isNew});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DeviceBrand && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
