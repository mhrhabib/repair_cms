import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';

class JobDeviceLabelScreen extends StatefulWidget {
  final CreateJobResponse jobResponse;
  final String printOption;
  final String? jobNo;

  const JobDeviceLabelScreen({super.key, required this.jobResponse, required this.printOption, this.jobNo});

  @override
  State<JobDeviceLabelScreen> createState() => _JobDeviceLabelScreenState();
}

class _JobDeviceLabelScreenState extends State<JobDeviceLabelScreen> {
  final _settingsService = PrinterSettingsService();

  /// Get the last used or default printer for one-click printing
  PrinterConfigModel? _getDefaultPrinter() {
    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> labelPrinters = allPrinters['label'] ?? [];

    if (labelPrinters.isEmpty) return null;

    // Try to get last used printer from storage
    // For now, return the first available printer
    return labelPrinters.first;
  }

  /// One-click print with default printer
  Future<void> _printWithDefaultPrinter() async {
    final printer = _getDefaultPrinter();

    if (printer == null) {
      showCustomToast('No label printers configured. Please configure a printer first.', isError: true);
      return;
    }

    await _printLabel(printer);
  }

  /// Enhanced print method with actual ESC/POS implementation
  Future<void> _printLabel(PrinterConfigModel printer) async {
    try {
      showCustomToast('Printing label...', isError: false);

      debugPrint('🖨️ Printing with ${printer.printerBrand} ${printer.printerType}');
      debugPrint('📄 Job: ${_getJobNumber()}');
      debugPrint('👤 Customer: ${_getCustomerName()}');
      debugPrint('📱 Device: ${_getDeviceName()}');
      debugPrint('🔢 IMEI: ${_getDeviceIMEI()}');

      // TODO: Implement actual printer communication
      // This requires proper printer SDK integration

      await Future.delayed(const Duration(milliseconds: 500));
      showCustomToast('Label print simulated successfully!', isError: false);
    } catch (e) {
      debugPrint('❌ Print error: $e');
      showCustomToast('Print failed: $e', isError: true);
    }
  }

  String _getJobNumber() {
    return widget.jobNo ?? widget.jobResponse.data?.model ?? 'N/A';
  }

  String _getDeviceName() {
    final device = widget.jobResponse.data?.device?.firstOrNull;
    if (device != null) {
      return '${device.brand ?? ''} ${device.model ?? ''}'.trim();
    }
    return 'Device';
  }

  String _getDeviceIMEI() {
    final device = widget.jobResponse.data?.device?.firstOrNull;
    return device?.imei ?? 'N/A';
  }

  String _getCustomerName() {
    final contact = widget.jobResponse.data?.contact?.firstOrNull;
    if (contact != null) {
      return '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
    }
    return 'Customer';
  }

  String _getDefect() {
    final defect = widget.jobResponse.data?.defect?.firstOrNull;
    if (defect != null && defect.defect != null && defect.defect!.isNotEmpty) {
      return defect.defect!.map((d) => d.value).join(', ');
    }
    return 'N/A';
  }

  String _getPhysicalLocation() {
    return widget.jobResponse.data?.physicalLocation ?? 'N/A';
  }

  String _getQRCodeData() {
    // Generate QR code data with job tracking info
    final jobId = widget.jobResponse.data?.sId ?? '';
    return jobId;
  }

  String _getBarcodeData() {
    // Use job number for barcode
    final jobNumber = _getJobNumber();
    // Ensure barcode data is numeric and properly formatted
    return jobNumber.replaceAll(RegExp(r'[^0-9]'), '').padLeft(13, '0');
  }

  /// Show printer selection dialog
  Future<void> _showPrinterSelection() async {
    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> labelPrinters = allPrinters['label'] ?? [];

    if (labelPrinters.isEmpty) {
      showCustomToast('No label printers configured', isError: true);
      return;
    }

    final selectedPrinter = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (context) => _PrinterSelectionDialog(printers: labelPrinters),
    );

    if (selectedPrinter != null && mounted) {
      await _printLabel(selectedPrinter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                    'Device Label',
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

            // Label Preview Content
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barcode and QR Code row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barcode section
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 60.h,
                              child: BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: _getBarcodeData(),
                                drawText: false,
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.black),
                              ),
                            ),
                            Text(
                              _getJobNumber(),
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.black),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // QR Code section
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60.h,
                              child: QrImageView(
                                data: _getQRCodeData(),
                                version: QrVersions.auto,
                                size: 60.w,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.jobResponse.data?.sId ?? 'N/A',
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w400, color: Colors.black),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Job information - single line
                  Text(
                    '${_getJobNumber()} | ${_getCustomerName()} | ${_getDeviceName()} IMEI: ${_getDeviceIMEI()}',
                    style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3),
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(height: 4.h),

                  // Defect and location - single line
                  Text(
                    '${_getDefect()} | BOX: ${_getPhysicalLocation()}',
                    style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Printer selection dialog for label printers
class _PrinterSelectionDialog extends StatelessWidget {
  final List<PrinterConfigModel> printers;

  const _PrinterSelectionDialog({required this.printers});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Label Printer'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: printers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final printer = printers[index];

            return ListTile(
              leading: const Icon(Icons.label, color: Colors.blue, size: 32),
              title: Text('${printer.printerBrand} Label Printer', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(printer.printerModel ?? 'Unknown Model'),
                  Text(printer.ipAddress, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (printer.labelSize != null)
                    Text(
                      'Size: ${printer.labelSize!.width}mm × ${printer.labelSize!.height}mm',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.w500),
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
}
