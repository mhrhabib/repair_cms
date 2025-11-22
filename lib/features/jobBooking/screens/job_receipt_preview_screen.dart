import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart' as job_booking;
import 'package:repair_cms/features/myJobs/models/single_job_model.dart' as my_jobs;
import 'package:repair_cms/features/myJobs/widgets/job_receipt_widget_new.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';

class JobReceiptPreviewScreen extends StatefulWidget {
  final job_booking.CreateJobResponse jobResponse;
  final String printOption; // 'A4 Receipt', 'Thermal Receipt', 'Device Label'

  const JobReceiptPreviewScreen({super.key, required this.jobResponse, required this.printOption});

  @override
  State<JobReceiptPreviewScreen> createState() => _JobReceiptPreviewScreenState();
}

class _JobReceiptPreviewScreenState extends State<JobReceiptPreviewScreen> {
  final _settingsService = PrinterSettingsService();

  /// Show printer selection dialog
  Future<void> _showPrinterSelection() async {
    debugPrint('🖨️ Opening printer selection dialog');

    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> configuredPrinters = [
      ...allPrinters['thermal'] ?? [],
      ...allPrinters['label'] ?? [],
      ...allPrinters['a4'] ?? [],
    ];

    debugPrint('📊 Found ${configuredPrinters.length} configured printers');

    if (configuredPrinters.isEmpty) {
      showCustomToast(
        'No printers configured. Please configure a printer in Settings > Printer Settings',
        isError: true,
      );
      return;
    }

    // Get default printer based on selected print option
    String? defaultPrinterType;
    if (widget.printOption == 'Thermal Receipt') {
      defaultPrinterType = 'thermal';
    } else if (widget.printOption == 'Device Label') {
      defaultPrinterType = 'label';
    } else {
      defaultPrinterType = 'a4';
    }

    final selectedPrinter = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (context) =>
          _PrinterSelectionDialog(printers: configuredPrinters, defaultPrinterType: defaultPrinterType),
    );

    if (selectedPrinter != null && mounted) {
      debugPrint('🎯 User selected: ${selectedPrinter.printerBrand} ${selectedPrinter.printerType} printer');
      _printReceipt(selectedPrinter);
    }
  }

  /// Print receipt with selected printer
  Future<void> _printReceipt(PrinterConfigModel printer) async {
    debugPrint('🚀 Starting print job with ${printer.printerBrand} ${printer.printerType}');

    showCustomToast('Print functionality will be implemented here', isError: false);

    // TODO: Implement actual printing based on printer type
    if (printer.printerType == 'thermal') {
      // Use thermal printer with paper width setting
      final paperWidth = printer.paperWidth ?? 80;
    } else if (printer.printerType == 'label') {
      // Use label printer with label size setting
      final labelSize = printer.labelSize;
    } else {
      // Use A4 printer
    }
  }

  /// Convert CreateJobResponse to SingleJobModel for JobReceiptWidgetNew
  my_jobs.SingleJobModel _convertToSingleJobModel() {
    final data = widget.jobResponse.data;

    // Convert assignedItems to dynamic list that widget expects
    final assignedItemsList = data?.assignedItems?.map((item) {
      return {
        'productName': item.productName ?? '',
        'name': item.productName ?? '',
        'price_incl_vat': item.salePriceIncVat ?? 0,
      };
    }).toList();

    return my_jobs.SingleJobModel(
      success: widget.jobResponse.success,
      data: my_jobs.Data(
        sId: data?.sId,
        jobType: data?.jobType,
        jobTypes: data?.jobType,
        model: data?.model,
        deviceId: data?.deviceId,
        jobContactId: data?.jobContactId,
        defectId: data?.defectId,
        physicalLocation: data?.physicalLocation,
        emailConfirmation: data?.emailConfirmation,
        files: data?.files?.map((f) => my_jobs.File(id: f.id, file: f.file, fileName: null, size: null)).toList(),
        signatureFilePath: data?.signatureFilePath,
        printOption: data?.printOption,
        printDeviceLabel: data?.printDeviceLabel,
        jobStatus: data?.jobStatus
            ?.map(
              (js) => my_jobs.JobStatus(
                title: js.title,
                userId: js.userId,
                colorCode: js.colorCode,
                userName: js.userName,
                createAtStatus: js.createAtStatus,
                notifications: js.notifications,
                notes: js.notes,
              ),
            )
            .toList(),
        userId: data?.userId,
        createdAt: data?.createdAt,
        updatedAt: data?.updatedAt,
        services: data?.services,
        assignedItems: assignedItemsList,
        device: data?.device
            ?.map(
              (d) => my_jobs.Device(
                sId: d.sId,
                brand: d.brand,
                model: d.model,
                condition: d.condition?.map((c) => my_jobs.Condition(value: c.value, id: c.id)).toList(),
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        contact: data?.contact
            ?.map(
              (c) => my_jobs.Contact(
                sId: c.sId,
                type: c.type,
                salutation: c.salutation,
                firstName: c.firstName,
                lastName: c.lastName,
                telephone: c.telephone,
                email: c.email,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              ),
            )
            .toList(),
        defect: data?.defect
            ?.map(
              (d) => my_jobs.Defect(
                sId: d.sId,
                defect: d.defect?.map((item) => my_jobs.DefectItem(value: item.value, id: item.id)).toList(),
                description: d.description,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        jobNo: data?.model ?? data?.sId ?? 'N/A',
        total: 0,
        subTotal: 0,
        vat: 0,
        discount: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert to SingleJobModel for JobReceiptWidgetNew
    final jobModel = _convertToSingleJobModel();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with close and print buttons
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8.r)),
                      child: Icon(Icons.close, color: Colors.grey.shade800, size: 24.sp),
                    ),
                  ),
                  const Spacer(),
                  // Title
                  Text(
                    'Receipt Preview',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                  ),
                  const Spacer(),
                  // Print button
                  GestureDetector(
                    onTap: _showPrinterSelection,
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8.r)),
                      child: Icon(Icons.print, color: Colors.white, size: 24.sp),
                    ),
                  ),
                ],
              ),
            ),

            // Receipt Preview Content
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: JobReceiptWidgetNew(jobData: jobModel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Printer selection dialog (same as ReceiptScreen)
class _PrinterSelectionDialog extends StatelessWidget {
  final List<PrinterConfigModel> printers;
  final String? defaultPrinterType;

  const _PrinterSelectionDialog({required this.printers, this.defaultPrinterType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Printer'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: printers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final printer = printers[index];
            final isDefault = printer.printerType == defaultPrinterType;

            return ListTile(
              leading: Icon(_getPrinterIcon(printer.printerType), color: Colors.blue, size: 32),
              title: Text(_getPrinterTitle(printer.printerType), style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(printer.printerModel ?? 'Unknown Model'),
                  Text(printer.ipAddress, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).pop(printer),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }

  IconData _getPrinterIcon(String printerType) {
    switch (printerType) {
      case 'thermal':
        return Icons.receipt_long;
      case 'label':
        return Icons.label;
      case 'a4':
        return Icons.description;
      default:
        return Icons.print;
    }
  }

  String _getPrinterTitle(String printerType) {
    switch (printerType) {
      case 'thermal':
        return 'Thermal Printer (80mm)';
      case 'label':
        return 'Label Printer';
      case 'a4':
        return 'A4 Receipt Printer';
      default:
        return 'Printer';
    }
  }
}
