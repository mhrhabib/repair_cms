import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/utils/label_image_generator.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_service_factory.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/features/moreSettings/labelContent/service/label_content_settings_service.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/features/home/home_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class JobDeviceLabelScreen extends StatefulWidget {
  final CreateJobResponse jobResponse;
  final String printOption;
  final bool fromBooking;
  final String? jobNo;

  const JobDeviceLabelScreen({
    super.key,
    required this.jobResponse,
    required this.printOption,
    this.fromBooking = false,
    this.jobNo,
  });

  @override
  State<JobDeviceLabelScreen> createState() => _JobDeviceLabelScreenState();
}

class _JobDeviceLabelScreenState extends State<JobDeviceLabelScreen> {
  final _settingsService = PrinterSettingsService();
  final _labelContentService = LabelContentSettingsService();

  // Label content settings
  late LabelContentSettings _labelSettings;

  /// Enhanced print method using centralized printer service
  Future<void> _printLabel(PrinterConfigModel printer) async {
    // If protocol is USB and printer supports image printing, try image path
    final canPrintImage = printer.printerType == 'label';
    try {
      SnackbarDemo(message: 'Preparing label...').showCustomSnackbar(context);

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

      SnackbarDemo(message: 'Sending to printer...').showCustomSnackbar(context);

      // Try capturing label widget as image for high-fidelity label (barcode + QR)
      if (canPrintImage) {
        // Capture the exact widget as displayed on screen, using the SELECTED printer for correct DPI/size
        final imageBytes = await _captureLabelAsImage(printer);

        if (imageBytes == null) {
          throw Exception('Failed to capture label image');
        }

        // Try image printing with fallback handling for TD series printers
        final imageResult = await PrinterServiceFactory.printLabelImageWithFallback(
          config: printer,
          imageBytes: imageBytes,
        );

        if (imageResult.success) {
          SnackbarDemo(message: imageResult.message).showCustomSnackbar(context);
          return;
        }

        // If image printing not supported (TD series), fall back to text
        debugPrint('⚠️ Image print not supported: ${imageResult.message}, trying text fallback');

        // Fallback: attempt structured/device label via SDK/raw fallback
        final labelText = _buildLabelText();
        final textResult = await PrinterServiceFactory.printLabelWithFallback(config: printer, text: labelText);
        if (textResult.success) {
          SnackbarDemo(message: textResult.message).showCustomSnackbar(context);
        } else {
          throw Exception(textResult.message);
        }
      } else {
        final result = await PrinterServiceFactory.printDeviceLabelWithFallback(config: printer, labelData: labelData);

        if (result.success) {
          SnackbarDemo(message: result.message).showCustomSnackbar(context);
        } else {
          throw Exception(result.message);
        }
      }

      // Result handled above per-printer type
    } catch (e) {
      debugPrint('❌ Print error: $e');
      SnackbarDemo(message: 'Print failed: $e').showCustomSnackbar(context);
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
    return device?.imei ?? device?.serialNo ?? 'N/A';
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

  /// Build a plain-text label that matches the preview shown on screen.
  String _buildLabelText() {
    final jobNumber = _getJobNumber();
    final customer = _getCustomerName();
    final device = _getDeviceName();
    final imei = _getDeviceIMEI();
    final defect = _getDefect();
    final location = _getPhysicalLocation();

    final buffer = StringBuffer();
    buffer.writeln('*** DEVICE LABEL ***');
    buffer.writeln('JOB: $jobNumber');
    buffer.writeln('CUSTOMER: $customer');
    buffer.writeln('DEVICE: $device');
    buffer.writeln('IMEI: $imei');
    buffer.writeln('DEFECT: $defect');
    buffer.writeln('LOCATION: $location');
    buffer.writeln('ID: ${widget.jobResponse.data?.sId ?? 'N/A'}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Please keep this label with the device');

    return buffer.toString();
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

    // If a printer was selected from the dialog, trigger printing
    if (selectedPrinter != null) await _printLabel(selectedPrinter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 72.h),
              // Label Preview Content
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Container(
                  // Let content size itself naturally
                  color: Colors.white,
                  // padding: const EdgeInsets.all(8),
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
                          if (_labelSettings.showBarcode || _labelSettings.showJobNo)
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (_labelSettings.showBarcode)
                                    SizedBox(
                                      height: 60.h,
                                      child: BarcodeWidget(
                                        barcode: Barcode.code128(),
                                        data: _getBarcodeData(),
                                        drawText: false,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  if (_labelSettings.showBarcode && _labelSettings.showJobNo) SizedBox(height: 8.h),
                                  if (_labelSettings.showJobNo)
                                    Text(
                                      _getJobNumber(),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                ],
                              ),
                            ),
                          if ((_labelSettings.showBarcode || _labelSettings.showJobNo) &&
                              (_labelSettings.showJobQR || _labelSettings.showTrackingPortalQR))
                            SizedBox(width: 16.w),
                          // QR Code section
                          if (_labelSettings.showJobQR || _labelSettings.showTrackingPortalQR)
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 80.h,
                                    child: QrImageView(
                                      data: _labelSettings.showJobQR
                                          ? _getQRCodeData()
                                          : 'https://tracking.portal/${widget.jobResponse.data?.sId ?? ''}',
                                      version: QrVersions.auto,
                                      size: 90.w,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                ],
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Job information - single flowing text block
                      if (_labelSettings.showJobNo ||
                          _labelSettings.showCustomerName ||
                          _labelSettings.showModelBrand ||
                          _labelSettings.showDate ||
                          _labelSettings.showJobType ||
                          _labelSettings.showSymptom ||
                          _labelSettings.showPhysicalLocation)
                        Text(
                          [
                            if (_labelSettings.showCustomerName) _getCustomerName(),
                            if (_labelSettings.showModelBrand)
                              _getDeviceName().isNotEmpty
                                  ? (_getDeviceIMEI().toUpperCase() != 'N/A'
                                        ? '${_getDeviceName()} IMEI: ${_getDeviceIMEI()}'
                                        : _getDeviceName())
                                  : '',
                            if (_labelSettings.showSymptom) _getDefect().toUpperCase() != 'N/A' ? _getDefect() : '',
                            if (_labelSettings.showPhysicalLocation) 'BOX: ${_getPhysicalLocation()}',
                          ].where((e) => e.isNotEmpty).join(' | '),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.left,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16.w, right: 16.w, bottom: 8.h),
              decoration: BoxDecoration(color: AppColors.kBg.withValues(alpha: 0.1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomNavButton(
                    onPressed: () {
                      if (widget.fromBooking) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen(initialIndex: 1)),
                          (route) => false,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: widget.fromBooking ? CupertinoIcons.check_mark : CupertinoIcons.back,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: AppColors.whiteColor, // Figma: border #FFFFFF
                        width: 1, // Figma: border-width 1px
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(28, 116, 115, 115), // Figma: #0000001C
                          blurRadius: 2, // Figma: blur 20px
                          offset: Offset(0, 0), // Figma: 0px 0px (no offset)
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        'Device Label',
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                  CustomNavButton(
                    onPressed: _handlePrintTap,
                    icon: SolarIconsOutline.printer,
                    size: 24.sp,
                    iconColor: AppColors.fontSecondaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLabelContentSettings();
  }

  /// Load label content settings from storage
  void _loadLabelContentSettings() {
    debugPrint('🏷️ [JobDeviceLabelScreen] Loading label content settings');
    _labelSettings = _labelContentService.getSettings();
    debugPrint(
      '✅ [JobDeviceLabelScreen] Label settings loaded: QR=${_labelSettings.showJobQR}, Barcode=${_labelSettings.showBarcode}',
    );
  }

  /// Handle print button tap: show selection if multiple printers exist, otherwise print directly
  Future<void> _handlePrintTap() async {
    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> labelPrinters = allPrinters['label'] ?? [];

    if (labelPrinters.isEmpty) {
      showCustomToast('No label printers configured', isError: true);
      return;
    }

    if (labelPrinters.length == 1) {
      // Rule 2: if one printer setup just print
      await _printLabel(labelPrinters.first);
    } else {
      // Rule 1: if two or more printer setup show user to select
      await _showPrinterSelection();
    }
  }

  /// Generate label image using the shared LabelImageGenerator
  Future<Uint8List?> _captureLabelAsImage(PrinterConfigModel printer) async {
    return LabelImageGenerator.captureLabelAsImage(
      printer: printer,
      labelSettings: _labelSettings,
      labelData: LabelData(
        jobNumber: _getJobNumber(),
        customerName: _getCustomerName(),
        deviceName: _getDeviceName(),
        deviceIMEI: _getDeviceIMEI(),
        defect: _getDefect(),
        physicalLocation: _getPhysicalLocation(),
        jobId: widget.jobResponse.data?.sId ?? '',
        barcodeData: _getBarcodeData(),
        qrCodeData: _getQRCodeData(),
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
