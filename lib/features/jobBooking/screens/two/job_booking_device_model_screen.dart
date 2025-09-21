import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
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

  void _selectModel(String modelName) {
    setState(() {
      _selectedModel = modelName;
      _searchController.text = modelName;
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
                    width: MediaQuery.of(context).size.width * .071 * 2,
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
                  ],
                ),
              ),
            ),

            // Dropdown section using reusable widget
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    CustomDropdownSearch<DeviceModel>(
                      controller: _searchController,
                      items: _models,
                      hintText: 'Answer here',
                      noItemsText: 'No models found',
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                      onSuggestionSelected: (model) {
                        _selectModel(model.name);
                      },
                      itemBuilder: (context, model) => ListTile(
                        title: Row(
                          children: [
                            Text(model.name, style: AppTypography.fontSize14.copyWith(color: Colors.black)),
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
                      suggestionsCallback: (pattern) {
                        return _models
                            .where((model) => model.name.toLowerCase().contains(pattern.toLowerCase()))
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
      // Sticky bottom navigation bar with keyboard handling
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 8.h : 8.h,
          left: 24.w,
          right: 24.w,
        ),
        child: BottomButtonsGroup(
          onPressed: _selectedModel.isNotEmpty
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => JobBookingAccessoriesScreen()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected model: $_selectedModel'), backgroundColor: AppColors.primary),
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
    super.dispose();
  }
}

class DeviceModel {
  final String name;
  final bool isNew;

  DeviceModel({required this.name, required this.isNew});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DeviceModel && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
