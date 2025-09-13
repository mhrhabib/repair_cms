import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

import '../three/job_booking_accessories_screen.dart';

class JobBookingDeviceModelScreen extends StatefulWidget {
  const JobBookingDeviceModelScreen({super.key});

  @override
  State<JobBookingDeviceModelScreen> createState() => _JobBookingDeviceModelScreenState();
}

class _JobBookingDeviceModelScreenState extends State<JobBookingDeviceModelScreen> {
  String _selectedModel = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isDropdownOpen = false;

  final List<DeviceModel> _models = [
    DeviceModel(name: 'iPhone 16 Pro', isNew: true),
    DeviceModel(name: 'iPhone 16', isNew: false),
    DeviceModel(name: 'iPhone 15 Pro', isNew: false),
    DeviceModel(name: 'iPhone 15', isNew: false),
    DeviceModel(name: 'iPhone 14 Pro', isNew: false),
    DeviceModel(name: 'iPhone 14', isNew: false),
    DeviceModel(name: 'iPhone 13 Pro', isNew: false),
    DeviceModel(name: 'iPhone 13', isNew: false),
    DeviceModel(name: 'iPhone 12 Pro', isNew: false),
    DeviceModel(name: 'iPhone 12', isNew: false),
    DeviceModel(name: 'Galaxy S24 Ultra', isNew: true),
    DeviceModel(name: 'Galaxy S24', isNew: false),
    DeviceModel(name: 'Galaxy S23 Ultra', isNew: false),
    DeviceModel(name: 'Galaxy S23', isNew: false),
  ];

  List<DeviceModel> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _filteredModels = _models;
  }

  void _filterModels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredModels = _models;
      } else {
        _filteredModels = _models.where((model) {
          return model.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      if (!_isDropdownOpen) {
        _searchController.clear();
        _filterModels('');
      }
    });
  }

  void _selectModel(String modelName) {
    setState(() {
      _selectedModel = modelName;
      _isDropdownOpen = false;
      _searchController.clear();
      _filterModels('');
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
              width: MediaQuery.of(context).size.width * .071 * 2,
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
                          child: Text('2', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Question text
                    Text('Enter the device Model', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                    SizedBox(height: 4.h),

                    Text(
                      '(E.g. iPhone 16, Galaxy S24)',
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
                                _selectedModel.isEmpty ? 'Answer here' : _selectedModel,
                                style: AppTypography.fontSize16.copyWith(
                                  color: _selectedModel.isEmpty ? Colors.grey.shade400 : Colors.black,
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
                                onChanged: _filterModels,
                                decoration: InputDecoration(
                                  hintText: 'Search model...',
                                  hintStyle: AppTypography.fontSize14.copyWith(color: Colors.grey.shade500),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // Model list
                            Container(
                              constraints: BoxConstraints(maxHeight: 200.h),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredModels.length,
                                itemBuilder: (context, index) {
                                  final model = _filteredModels[index];
                                  return GestureDetector(
                                    onTap: () => _selectModel(model.name),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: model.name == _selectedModel
                                            ? AppColors.primary.withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            model.name,
                                            style: AppTypography.fontSize14.copyWith(
                                              color: Colors.black,
                                              fontWeight: model.name == _selectedModel
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (model.isNew) ...[
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
                      onPressed: _selectedModel.isNotEmpty
                          ? () {
                              Navigator.of(
                                context,
                              ).push(MaterialPageRoute(builder: (context) => JobBookingAccessoriesScreen()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected model: $_selectedModel'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                              // Navigate to next screen
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

class DeviceModel {
  final String name;
  final bool isNew;

  DeviceModel({required this.name, required this.isNew});
}
