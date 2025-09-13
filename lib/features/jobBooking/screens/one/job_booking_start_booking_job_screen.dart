import 'package:repair_cms/core/app_exports.dart';
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
  bool _isDropdownOpen = false;

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

  List<DeviceBrand> _filteredBrands = [];

  @override
  void initState() {
    super.initState();
    _filteredBrands = _brands;
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = _brands;
      } else {
        _filteredBrands = _brands.where((brand) {
          return brand.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      if (!_isDropdownOpen) {
        _searchController.clear();
        _filterBrands('');
      }
    });
  }

  void _selectBrand(String brandName) {
    setState(() {
      _selectedBrand = brandName;
      _isDropdownOpen = false;
      _searchController.clear();
      _filterBrands('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
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
            Expanded(
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

                    // Dropdown field
                    GestureDetector(
                      onTap: _toggleDropdown,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedBrand.isEmpty ? 'Answer here' : _selectedBrand,
                                style: AppTypography.fontSize16.copyWith(
                                  color: _selectedBrand.isEmpty ? Colors.grey.shade400 : Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: Colors.grey.shade600,
                              size: 24.sp,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Dropdown list
                    if (_isDropdownOpen) ...[
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Search field
                            Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterBrands,
                                decoration: InputDecoration(
                                  hintText: 'Search brand...',
                                  hintStyle: AppTypography.fontSize14.copyWith(color: Colors.grey.shade500),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // Brand list
                            Container(
                              constraints: BoxConstraints(maxHeight: 200.h),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredBrands.length,
                                itemBuilder: (context, index) {
                                  final brand = _filteredBrands[index];
                                  return GestureDetector(
                                    onTap: () => _selectBrand(brand.name),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: brand.name == _selectedBrand
                                            ? AppColors.primary.withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            brand.name,
                                            style: AppTypography.fontSize14.copyWith(
                                              color: Colors.black,
                                              fontWeight: brand.name == _selectedBrand
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
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
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Navigation buttons
                    BottomButtonsGroup(
                      onPressed: _selectedBrand.isNotEmpty
                          ? () {
                              Navigator.of(
                                context,
                              ).push(MaterialPageRoute(builder: (context) => JobBookingDeviceModelScreen()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected brand: $_selectedBrand'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          : null,
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class DeviceBrand {
  final String name;
  final bool isNew;

  DeviceBrand({required this.name, required this.isNew});
}
