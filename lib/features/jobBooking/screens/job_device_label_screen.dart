import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_service_factory.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/features/moreSettings/labelContent/service/label_content_settings_service.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';

class JobDeviceLabelScreen extends StatefulWidget {
  final CreateJobResponse jobResponse;
  final String printOption;
  final String? jobNo;

  const JobDeviceLabelScreen({
    super.key,
    required this.jobResponse,
    required this.printOption,
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
    // If protocol is USB and printer supports image printing, try image path
    final canPrintImage = printer.printerType == 'label';
    try {
      SnackbarDemo(message: 'Preparing label...').showCustomSnackbar(context);

      debugPrint(
        '🖨️ Printing with ${printer.printerBrand} ${printer.printerType}',
      );

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

      SnackbarDemo(
        message: 'Sending to printer...',
      ).showCustomSnackbar(context);

      // Try capturing label widget as image for high-fidelity label (barcode + QR)
      if (canPrintImage) {
        // Capture the exact widget as displayed on screen
        final imageBytes = await _captureLabelAsImage();

        if (imageBytes == null) {
          throw Exception('Failed to capture label image');
        }

        // Try image printing with fallback handling for TD series printers
        final imageResult =
            await PrinterServiceFactory.printLabelImageWithFallback(
              config: printer,
              imageBytes: imageBytes,
            );

        if (imageResult.success) {
          SnackbarDemo(
            message: imageResult.message,
          ).showCustomSnackbar(context);
          return;
        }

        // If image printing not supported (TD series), fall back to text
        debugPrint(
          '⚠️ Image print not supported: ${imageResult.message}, trying text fallback',
        );

        // Fallback: attempt structured/device label via SDK/raw fallback
        final labelText = _buildLabelText();
        final textResult = await PrinterServiceFactory.printLabelWithFallback(
          config: printer,
          text: labelText,
        );
        if (textResult.success) {
          SnackbarDemo(message: textResult.message).showCustomSnackbar(context);
        } else {
          throw Exception(textResult.message);
        }
      } else {
        final result = await PrinterServiceFactory.printDeviceLabelWithFallback(
          config: printer,
          labelData: labelData,
        );

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
      builder: (context) => _PrinterSelectionDialog(
        printers: labelPrinters,
        onPrint: _printLabel,
      ),
    );

    // If a printer was selected from the dialog, trigger printing
    if (selectedPrinter != null) await _printLabel(selectedPrinter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.xmark,
            size: 24.r,
            color: Colors.grey.shade800,
          ),
        ),
        middle: Text(
          'Device Label',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        trailing: GestureDetector(
          onTap: _handlePrintTap,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              // Let content size itself naturally
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barcode and QR Code row
                  if (_labelSettings.showBarcode ||
                      _labelSettings.showJobQR ||
                      _labelSettings.showTrackingPortalQR)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barcode section
                        if (_labelSettings.showBarcode ||
                            _labelSettings.showJobNo)
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
                        if ((_labelSettings.showBarcode ||
                                _labelSettings.showJobNo) &&
                            (_labelSettings.showJobQR ||
                                _labelSettings.showTrackingPortalQR))
                          SizedBox(width: 16.w),
                        // QR Code section
                        if (_labelSettings.showJobQR ||
                            _labelSettings.showTrackingPortalQR)
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 80.h,
                                  child: QrImageView(
                                    data: _labelSettings.showTrackingPortalQR
                                        ? 'https://tracking.portal/${widget.jobResponse.data?.sId ?? ""}'
                                        : _getQRCodeData(),
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

                  if (_labelSettings.showBarcode ||
                      _labelSettings.showJobQR ||
                      _labelSettings.showTrackingPortalQR)
                    SizedBox(height: 16.h),

                  // Job information - conditionally show fields
                  if (_labelSettings.showCustomerName ||
                      _labelSettings.showModelBrand ||
                      _labelSettings.showDate ||
                      _labelSettings.showJobType ||
                      _labelSettings.showSymptom ||
                      _labelSettings.showPhysicalLocation)
                    _buildInfoText(),
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
    _loadLabelSettings();
  }

  /// Load label content settings
  void _loadLabelSettings() {
    debugPrint('🏷️ [JobDeviceLabelScreen] Loading label content settings');
    _labelSettings = _labelContentService.getSettings();
  }

  /// Build info text based on label settings
  Widget _buildInfoText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line 1: Customer Name
        if (_labelSettings.showCustomerName)
          Text(
            _getCustomerName(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.3,
            ),
            textAlign: TextAlign.left,
          ),
        if (_labelSettings.showCustomerName && _labelSettings.showModelBrand)
          SizedBox(height: 4.h),
        
        // Line 2: Device Model/Brand
        if (_labelSettings.showModelBrand)
          Text(
            _getDeviceName(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.3,
            ),
            textAlign: TextAlign.left,
          ),
        if (_labelSettings.showModelBrand && 
            (_labelSettings.showSymptom || _labelSettings.showPhysicalLocation))
          SizedBox(height: 4.h),
        
        // Line 3: Symptom/Defect and Location
        if (_labelSettings.showSymptom || _labelSettings.showPhysicalLocation)
          Text(
            [
              if (_labelSettings.showSymptom) _getDefect(),
              if (_labelSettings.showPhysicalLocation) 'BOX: ${_getPhysicalLocation()}',
            ].join(' | '),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.3,
            ),
            textAlign: TextAlign.left,
          ),
      ],
    );
  }

  /// Get month name from month number
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Handle print button tap: try default printer, otherwise show selection
  Future<void> _handlePrintTap() async {
    final defaultPrinter = _getDefaultPrinter();
    if (defaultPrinter != null) {
      await _printLabel(defaultPrinter);
      return;
    }

    await _showPrinterSelection();
  }

  /// Get dots per mm based on printer model (TD-2: 8.0, TD-4: 11.811)
  /// Get dots per mm based on printer model
  /// TD-2350D/DA: 300 DPI (11.77 dots/mm) - 52mm = 612 dots
  /// Other TD-2: 203 DPI (8 dots/mm)
  /// TD-4: 300 DPI (11.811 dots/mm)
  double _getDotsPerMm(PrinterConfigModel? printer) {
    final model = printer?.printerModel?.toUpperCase() ?? '';

    // TD-2350D and TD-2350DA are 300 DPI printers
    if (model.contains('TD-2350')) {
      return 11.77; // 300 DPI: 612 dots / 52mm = 11.77 dots/mm
    }

    // TD-4 series are 300 DPI
    if (model.startsWith('TD-4')) {
      return 11.811; // 300 DPI exact
    }

    return 8.0; // 203 DPI (other TD-2 and default)
  }

  /// Generate label image at exact printer resolution
  /// TD-2350D: 300 DPI (11.77 dots/mm) - 52×26mm = 612×307 dots
  /// TD-4 series: 300 DPI (11.811 dots/mm)
  /// Other TD-2: 203 DPI (8 dots/mm)
  Future<Uint8List?> _captureLabelAsImage() async {
    try {
      debugPrint('📸 Generating label image at printer resolution');

      // Get label size from printer config (in mm)
      final defaultPrinter = _getDefaultPrinter();
      final model = defaultPrinter?.printerModel?.toUpperCase() ?? '';

      // For TD-4 printers, use actual small label size (51x24mm or 54x24mm)
      // instead of the large configured size (100x150mm)
      double labelWidthMm;
      double labelHeightMm;

      if (model.startsWith('TD-4')) {
        // TD-4 with small labels: use 54x24mm (slightly larger for margins)
        labelWidthMm = 54;
        labelHeightMm = 24;
        debugPrint('🏷️ TD-4 detected: Using small label size 54x24mm');
      } else if (model.contains('TD-2350')) {
        // TD-2350D: use 52x26mm
        labelWidthMm = 52;
        labelHeightMm = 26;
        debugPrint('🏷️ TD-2350D detected: Using 52x26mm label size');
      } else {
        // Other printers: use configured size or default to 51x26mm
        labelWidthMm = (defaultPrinter?.labelSize?.width ?? 51).toDouble();
        labelHeightMm = (defaultPrinter?.labelSize?.height ?? 26).toDouble();
        debugPrint(
          '🏷️ Using configured/default label size: ${labelWidthMm}x${labelHeightMm}mm',
        );
      }

      // Get DPI-aware dots per mm
      final dotsPerMm = _getDotsPerMm(defaultPrinter);
      final dpi = dotsPerMm > 10 ? 300 : 203;

      // Convert to pixels at NATIVE resolution (no 2x multiplier!)
      // TD-2: 51x26mm @ 8 dots/mm = 408x208 dots
      // TD-4: 100x150mm @ 11.811 dots/mm = 1181x1772 dots
      final widthPx = (labelWidthMm * dotsPerMm).round();
      final heightPx = (labelHeightMm * dotsPerMm).round();

      debugPrint(
        '📐 Printer: ${defaultPrinter?.printerModel ?? "unknown"}, DPI: $dpi',
      );
      debugPrint(
        '📐 Label: ${labelWidthMm}x${labelHeightMm}mm → Image: ${widthPx}x${heightPx}px (NATIVE 1x)',
      );

      // Create a picture recorder and canvas at exact printer resolution
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()),
      );

      // White background
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()),
        bgPaint,
      );

      // Apply printer margin compensation (same as test border)
      // Shift canvas origin to account for unprintable margins
      const double offsetX =
          80.0; // Shift right (reduced from 50 to push content more to the right)
      const double offsetY = 50.0; // Shift down
      canvas.translate(offsetX, offsetY);

      // Adjust content area to fit within shifted bounds
      final drawableWidth = widthPx - offsetX;
      final drawableHeight = heightPx - offsetY;

      // Calculate layout dimensions (percentage-based, using drawable area)
      // Use percentage of drawable dimensions so layout scales with resolution
      final padding = 12.0; // Fixed margin for canvas content
      final contentWidth = drawableWidth - (padding * 2);
      final barcodeWidth =
          contentWidth * 0.65; // 65% of content width for barcode
      final barcodeHeight = drawableHeight * 0.24; // 24% of height for barcode
      final qrSize = contentWidth * 0.25; // 25% for QR code

      double currentY = padding; // Track Y position as we draw elements

      // Draw barcode if enabled
      if (_labelSettings.showBarcode) {
        final barcodeData = _getBarcodeData();
        _drawBarcode(
          canvas,
          barcodeData,
          padding,
          currentY,
          barcodeWidth,
          barcodeHeight,
        );
      }

      // Draw job number under barcode if enabled
      if (_labelSettings.showJobNo) {
        final yPos = _labelSettings.showBarcode
            ? currentY + barcodeHeight + 4
            : currentY;
        final textPainter = TextPainter(
          text: TextSpan(
            text: _getJobNumber(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: barcodeWidth);
        final xPos = _labelSettings.showBarcode
            ? padding + (barcodeWidth - textPainter.width) / 2
            : padding;
        textPainter.paint(canvas, Offset(xPos, yPos));
        currentY = yPos + textPainter.height + 4;
      } else if (_labelSettings.showBarcode) {
        currentY += barcodeHeight + 4;
      }

      // Draw QR code if enabled (aligned with barcode top)
      if (_labelSettings.showJobQR || _labelSettings.showTrackingPortalQR) {
        final qrData = _labelSettings.showTrackingPortalQR
            ? 'https://tracking.portal/${widget.jobResponse.data?.sId ?? ""}'
            : _getQRCodeData();

        final qrPainter = QrPainter(
          data: qrData,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        );

        final qrX = drawableWidth - padding - qrSize + 4.0; // Align right
        canvas.save();
        canvas.translate(qrX, padding); // Align with top
        canvas.scale(qrSize / 200); // QrPainter draws at ~200px
        qrPainter.paint(canvas, const Size(200, 200));
        canvas.restore();
      }

      // Add spacing before text info
      currentY += 6.0;

      // Font size for text info
      final fontSize = 26.sp;
      final lineSpacing = 4.0; // Reduced gap between lines

      // Build and draw first line: Customer Name
      if (_labelSettings.showCustomerName) {
        final infoPainter = TextPainter(
          text: TextSpan(
            text: _getCustomerName(),
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );
        infoPainter.layout(maxWidth: contentWidth);
        infoPainter.paint(canvas, Offset(padding, currentY));
        currentY += infoPainter.height + lineSpacing;
      }

      // Build and draw second line: Device Model/Brand
      if (_labelSettings.showModelBrand) {
        final devicePainter = TextPainter(
          text: TextSpan(
            text: _getDeviceName(),
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );
        devicePainter.layout(maxWidth: contentWidth);
        devicePainter.paint(canvas, Offset(padding, currentY));
        currentY += devicePainter.height + lineSpacing;
      }

      // Build and draw third line: Symptom/Defect and Location
      final List<String> thirdLine = [];
      if (_labelSettings.showSymptom) thirdLine.add(_getDefect());
      if (_labelSettings.showPhysicalLocation) {
        thirdLine.add('BOX: ${_getPhysicalLocation()}');
      }

      if (thirdLine.isNotEmpty) {
        final defectPainter = TextPainter(
          text: TextSpan(
            text: thirdLine.join(' | '),
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );
        defectPainter.layout(maxWidth: contentWidth);
        defectPainter.paint(canvas, Offset(padding, currentY));
        currentY += defectPainter.height + lineSpacing;
      }

      // End recording and create image
      final picture = recorder.endRecording();
      final image = await picture.toImage(widthPx, heightPx);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();

      if (byteData == null) {
        debugPrint('❌ Failed to convert image to bytes');
        return null;
      }

      final imageBytes = byteData.buffer.asUint8List();
      debugPrint(
        '✅ Generated ${widthPx}x$heightPx image (${imageBytes.length} bytes) at ${dotsPerMm == 12 ? 300 : 203} DPI',
      );
      return imageBytes;
    } catch (e, st) {
      debugPrint('❌ Error generating label image: $e');
      debugPrint('Stack trace: $st');
      return null;
    }
  }

  /// Draw Code128 barcode manually using the barcode package
  void _drawBarcode(
    Canvas canvas,
    String data,
    double x,
    double y,
    double width,
    double height,
  ) {
    // Use barcode_widget's Barcode class (same as BarcodeWidget uses)
    final barcodeGen = Barcode.code128();
    final elements = barcodeGen.make(
      data,
      width: width,
      height: height,
      drawText: false,
    );

    final blackPaint = Paint()..color = Colors.black;

    for (final element in elements) {
      // BarcodeElement has left, top, width, height properties
      // BarcodeBar extends BarcodeElement and has a 'black' property
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            x + element.left,
            y + element.top,
            element.width,
            element.height,
          ),
          blackPaint,
        );
      }
    }
  }
}

/// Printer selection dialog for label printers
class _PrinterSelectionDialog extends StatelessWidget {
  final List<PrinterConfigModel> printers;
  final Future<void> Function(PrinterConfigModel) onPrint;

  const _PrinterSelectionDialog({
    required this.printers,
    required this.onPrint,
  });

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
              Icon(
                CupertinoIcons.printer,
                size: 24.r,
                color: AppColors.fontMainColor,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${printer.printerBrand} ${printer.printerModel ?? ""}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF007AFF),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    printer.ipAddress,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (printer.labelSize != null)
                    Text(
                      'Size: ${printer.labelSize!.width}mm × ${printer.labelSize!.height}mm',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
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
