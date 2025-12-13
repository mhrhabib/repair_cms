import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/brother_printer_service.dart';
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
  final _printerService = BrotherPrinterService();

  /// Get the last used or default printer for one-click printing
  PrinterConfigModel? _getDefaultPrinter() {
    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> labelPrinters = allPrinters['label'] ?? [];

    if (labelPrinters.isEmpty) return null;

    // Try to get last used printer from storage
    // For now, return the first available printer
    return labelPrinters.first;
  }

  /// Enhanced print method using centralized printer service
  Future<void> _printLabel(PrinterConfigModel printer) async {
    try {
      showCustomToast('Preparing label...', isError: false);

      debugPrint('🖨️ Printing with ${printer.printerBrand} ${printer.printerType}');

      // Build label data
      final labelData = {
        'jobNumber': _getJobNumber(),
        'customerName': _getCustomerName(),
        'deviceName': _getDeviceName(),
        'imei': _getDeviceIMEI(),
        'defect': _getDefect(),
        'location': _getPhysicalLocation(),
        'jobId': widget.jobResponse.data?.sId ?? 'N/A',
      };

      debugPrint('📄 Job: ${labelData['jobNumber']}');
      debugPrint('👤 Customer: ${labelData['customerName']}');
      debugPrint('📱 Device: ${labelData['deviceName']}');
      debugPrint('🔢 IMEI: ${labelData['imei']}');

      showCustomToast('Sending to printer...', isError: false);

      // Use centralized printer service
      final result = await _printerService.printDeviceLabel(
        ipAddress: printer.ipAddress,
        labelData: labelData,
        port: printer.port ?? 9100,
      );

      if (result.success) {
        showCustomToast(result.message, isError: false);
        debugPrint('✅ ${result.message}');
      } else {
        throw Exception(result.message);
      }
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

    final selectedPrinter = await showCupertinoModalPopup<PrinterConfigModel>(
      context: context,
      builder: (context) => _PrinterSelectionDialog(printers: labelPrinters, onPrint: _printLabel),
    );

    // Don't need to handle printing here since it's done in dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(CupertinoIcons.xmark, size: 24.r, color: Colors.grey.shade800),
        ),
        middle: Text(
          'Device Label',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
        ),
        trailing: GestureDetector(
          onTap: _showPrinterSelection,
          child: Icon(Icons.print, size: 24.r, color: AppColors.primary),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
    );
  }
}

/// Printer selection dialog for label printers
class _PrinterSelectionDialog extends StatelessWidget {
  final List<PrinterConfigModel> printers;
  final Future<void> Function(PrinterConfigModel) onPrint;

  const _PrinterSelectionDialog({required this.printers, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(
        'Select Label Printer',
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
      ),
      message: Text(
        'Choose a printer to print the device label',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      ),
      actions: printers.map((printer) {
        return CupertinoActionSheetAction(
          onPressed: () async {
            // Close dialog first
            Navigator.of(context).pop();

            // Then execute print and wait for result
            await onPrint(printer);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.printer, size: 24.r, color: AppColors.fontMainColor),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${printer.printerBrand} ${printer.printerModel ?? ""}',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007AFF)),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    printer.ipAddress,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                  ),
                  if (printer.labelSize != null)
                    Text(
                      'Size: ${printer.labelSize!.width}mm × ${printer.labelSize!.height}mm',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        isDefaultAction: true,
        child: const Text('Cancel'),
      ),
    );
  }
}
