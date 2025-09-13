import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingSelectPrinterScreen extends StatefulWidget {
  const JobBookingSelectPrinterScreen({super.key});

  @override
  State<JobBookingSelectPrinterScreen> createState() => _JobBookingSelectPrinterScreenState();
}

class _JobBookingSelectPrinterScreenState extends State<JobBookingSelectPrinterScreen> {
  String _selectedPrinterType = '';

  final List<PrinterType> _printerTypes = [
    PrinterType(id: 'a4_receipt', name: 'A4\nReceipt', icon: Icons.print, isSelected: false),
    PrinterType(id: 'thermal_receipt', name: 'Thermal\nReceipt', icon: Icons.receipt_long, isSelected: false),
  ];

  void _selectPrinterType(String printerTypeId) {
    setState(() {
      _selectedPrinterType = printerTypeId;
      // Update selection state
      for (var printerType in _printerTypes) {
        printerType.isSelected = printerType.id == printerTypeId;
      }
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
            // Progress bar
            Container(
              height: 12.h,
              width: MediaQuery.of(context).size.width * .071 * 14,
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
                          child: Text('14', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Title
                    Text('Select Printer Type', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                    SizedBox(height: 48.h),

                    // Printer options
                    Row(
                      children: [
                        // A4 Receipt option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectPrinterType('a4_receipt'),
                            child: Container(
                              height: 120.h,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _selectedPrinterType == 'a4_receipt'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: _selectedPrinterType == 'a4_receipt' ? 2 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.print, size: 32.sp, color: Colors.grey.shade700),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'A4\nReceipt',
                                        style: AppTypography.fontSize14.copyWith(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  if (_selectedPrinterType == 'a4_receipt')
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                        child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16.w),

                        // Thermal Receipt option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectPrinterType('thermal_receipt'),
                            child: Container(
                              height: 120.h,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _selectedPrinterType == 'thermal_receipt'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: _selectedPrinterType == 'thermal_receipt' ? 2 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.receipt_long, size: 32.sp, color: Colors.grey.shade700),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Thermal\nReceipt',
                                        style: AppTypography.fontSize14.copyWith(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  if (_selectedPrinterType == 'thermal_receipt')
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                        child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Navigation buttons
                    BottomButtonsGroup(
                      onPressed: _selectedPrinterType.isNotEmpty
                          ? () {
                              // Navigate to next screen or process selection
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Selected printer: ${_selectedPrinterType == 'a4_receipt' ? 'A4 Receipt' : 'Thermal Receipt'}',
                                  ),
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
}

class PrinterType {
  final String id;
  final String name;
  final IconData icon;
  bool isSelected;

  PrinterType({required this.id, required this.name, required this.icon, required this.isSelected});
}
