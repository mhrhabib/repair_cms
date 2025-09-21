import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
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

  final List<AccessoryItem> _accessories = [
    AccessoryItem(name: 'Charging Cable', isNew: false),
    AccessoryItem(name: 'Power Adapter', isNew: false),
    AccessoryItem(name: 'Protective Case', isNew: true),
    AccessoryItem(name: 'Screen Protector', isNew: false),
    AccessoryItem(name: 'Wireless Earbuds', isNew: false),
    AccessoryItem(name: 'Battery Pack', isNew: false),
    AccessoryItem(name: 'Car Mount', isNew: false),
    AccessoryItem(name: 'Stylus Pen', isNew: false),
    AccessoryItem(name: 'Memory Card', isNew: false),
    AccessoryItem(name: 'SIM Card Tool', isNew: false),
  ];

  void _selectAccessory(String accessoryName) {
    setState(() {
      _selectedAccessory = accessoryName;
      _searchController.text = accessoryName;
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

            // Dropdown section using reusable widget
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    CustomDropdownSearch<AccessoryItem>(
                      controller: _searchController,
                      items: _accessories,
                      hintText: 'Answer here',
                      noItemsText: 'No accessories found',
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                      onSuggestionSelected: (accessory) {
                        _selectAccessory(accessory.name);
                      },
                      itemBuilder: (context, accessory) => ListTile(
                        title: Row(
                          children: [
                            Text(accessory.name, style: AppTypography.fontSize14.copyWith(color: Colors.black)),
                            if (accessory.isNew) ...[
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
                        return _accessories
                            .where((accessory) => accessory.name.toLowerCase().contains(pattern.toLowerCase()))
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
          onPressed: _selectedAccessory.isNotEmpty
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => JobBookingImeiScreen()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected accessory: $_selectedAccessory'),
                      backgroundColor: AppColors.primary,
                    ),
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

class AccessoryItem {
  final String name;
  final bool isNew;

  AccessoryItem({required this.name, required this.isNew});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AccessoryItem && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
