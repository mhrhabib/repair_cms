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

                      // Job information - single line (conditional based on settings)
                      if (_labelSettings.showJobNo ||
                          _labelSettings.showCustomerName ||
                          _labelSettings.showModelBrand ||
                          _labelSettings.showDate ||
                          _labelSettings.showJobType ||
                          _labelSettings.showSymptom ||
                          _labelSettings.showPhysicalLocation)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_labelSettings.showJobNo ||
                                _labelSettings.showCustomerName ||
                                _labelSettings.showModelBrand)
                              Text(
                                [
                                  if (_labelSettings.showJobNo) _getJobNumber(),
                                  if (_labelSettings.showCustomerName) _getCustomerName(),
                                  if (_labelSettings.showModelBrand) '${_getDeviceName()} IMEI: ${_getDeviceIMEI()}',
                                ].where((e) => e.isNotEmpty).join(' | '),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            if ((_labelSettings.showJobNo ||
                                    _labelSettings.showCustomerName ||
                                    _labelSettings.showModelBrand) &&
                                (_labelSettings.showSymptom || _labelSettings.showPhysicalLocation))
                              SizedBox(height: 4.h),
                            if (_labelSettings.showSymptom || _labelSettings.showPhysicalLocation)
                              Text(
                                [
                                  if (_labelSettings.showSymptom) _getDefect(),
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
                    icon: CupertinoIcons.back,
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
  /// TD-2350D/DA: 300 DPI (11.82 dots/mm) - 50mm = 591 dots
  /// Other TD-2: 203 DPI (8 dots/mm)
  /// TD-4: 300 DPI (11.811 dots/mm)
  double _getDotsPerMm(PrinterConfigModel? printer) {
    final model = printer?.printerModel?.toUpperCase() ?? '';

    debugPrint('🔍 Checking printer model: "$model"');

    // TD-4 series MUST be checked FIRST (before TD-2)
    if (model.startsWith('TD-4')) {
      debugPrint('✅ TD-4 series detected: 300 DPI (11.811 dots/mm)');
      return 11.811; // 300 DPI for TD-4
    }

    // TD-2350D and TD-2350DA are 300 DPI printers
    if (model.contains('TD-2350')) {
      debugPrint('✅ TD-2350 series detected: 300 DPI (11.82 dots/mm)');
      return 11.82;
    }

    // Other TD-2 series (non-2350) are 203 DPI
    if (model.startsWith('TD-2')) {
      debugPrint('✅ Other TD-2 series detected: 203 DPI (8.0 dots/mm)');
      return 8.0;
    }

    // Handle Xprinter (Standard 203 DPI for most XP models)
    if (printer?.printerBrand.toLowerCase() == 'xprinter') {
      debugPrint('✅ Xprinter detected: 203 DPI (8.0 dots/mm)');
      return 8.0;
    }

    debugPrint('⚠️ Unknown printer model, using default 203 DPI');
    return 8.0;
  }

  /// Generate label image at exact printer resolution
  /// TD-2350D: 300 DPI (11.82 dots/mm) - 50×26mm = 591×307 dots
  /// TD-4 series: 300 DPI (11.811 dots/mm)
  /// Other TD-2: 203 DPI (8 dots/mm)
  Future<Uint8List?> _captureLabelAsImage(PrinterConfigModel printer) async {
    try {
      debugPrint('📸 Generating label image at printer resolution');

      // Use the SELECTED printer's size & DPI (not the default printer)
      final labelWidthMm = printer.labelSize?.width ?? 50;
      final labelHeightMm = printer.labelSize?.height ?? 26;

      // Get DPI-aware dots per mm for the selected printer
      final dotsPerMm = _getDotsPerMm(printer);
      final dpi = dotsPerMm > 10 ? 300 : 203;

      // Convert to pixels at NATIVE resolution (no 2x multiplier!)
      // TD-2: 51x26mm @ 8 dots/mm = 408x208 dots
      // TD-4: 100x150mm @ 11.811 dots/mm = 1181x1772 dots
      final widthPx = (labelWidthMm * dotsPerMm).round();
      final heightPx = (labelHeightMm * dotsPerMm).round();

      // All printers use portrait canvas matching raster dimensions (widthDots x heightDots).
      // TD-2D, TD-4, and Xprinter all use the same orientation.
      final canvasWidth = widthPx;
      final canvasHeight = heightPx;

      debugPrint('📐 Printer: ${printer.printerModel ?? "unknown"} (${printer.printerBrand}), DPI: $dpi');
      debugPrint('📐 Label: ${labelWidthMm}x${labelHeightMm}mm → Image: ${canvasWidth}x${canvasHeight}px (Portrait)');

      // Create a picture recorder and canvas at exact printer resolution
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()));

      // White background
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()), bgPaint);

      // Offset compensates for Brother's unprintable hardware margins.
      // For Xprinter and other brands the TSPL SIZE/GAP commands already
      // handle the printable area, so zero offset is correct.
      //
      // TD-4: The Brother TD-4 SDK applies its own internal media offset.
      // We compensate by translating the canvas right/down so content
      // doesn't get clipped at the left/top physical edge by the SDK margin.
      // A value of ~4% of canvas width gives ~47 dots on a 1181-dot canvas
      // which matches the typical 4mm hardware margin on TD-4 media.

      final bool isBrother = printer.printerBrand.toLowerCase() == 'brother';
      final bool isTD4Model = (printer.printerModel?.toUpperCase() ?? '').startsWith('TD-4');

      // TD-2D: 50px canvas translate compensates for hardware margins on smaller print head.
      // TD-4: No canvas offset — positioning is handled by raster line centering on the wider print head.
      // Xprinter: TSPL SIZE/GAP commands handle the printable area, so zero offset.
      final double offsetX = isBrother ? (isTD4Model ? 0.0 : 50.0) : 0.0;
      final double offsetY = isBrother ? (isTD4Model ? 0.0 : 50.0) : 0.0;
      if (offsetX > 0 || offsetY > 0) canvas.translate(offsetX, offsetY);

      final drawableWidth = canvasWidth.toDouble() - 2 * offsetX;
      final drawableHeight = canvasHeight.toDouble() - 2 * offsetY;

      // TD-4: 4% padding (~2.5mm) clears the physical die-cut label margins.
      // TD-2D/Xprinter: 2% (already offset by 50px canvas translate).
      final double padding = isTD4Model ? drawableWidth * 0.04 : drawableWidth * 0.02;
      final double contentWidth = drawableWidth - (padding * 2);
      final double barcodeWidth = contentWidth * 0.62;
      final double barcodeHeight = drawableHeight * 0.24;
      final double qrSize = contentWidth * 0.22;

      // Draw barcode using barcode package
      final barcodeData = _getBarcodeData();

      // Draw barcode as rectangles (only if barcode setting is enabled)
      if (_labelSettings.showBarcode) {
        _drawBarcode(canvas, barcodeData, padding, padding, barcodeWidth, barcodeHeight);
      }

      // Font size: proportional to drawable height, same for all printers.
      final double baseFontSize = (drawableHeight * 0.09).clamp(20.0, 32.0);
      final double lineSpacing = baseFontSize + 3.0;

      // Draw job number under barcode (only if showJobNo is enabled)
      double currentY = padding;
      if (_labelSettings.showBarcode) {
        currentY = padding + barcodeHeight + 4;
        if (_labelSettings.showJobNo) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: _getJobNumber(),
              style: TextStyle(color: Colors.black, fontSize: baseFontSize, fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: barcodeWidth);
          textPainter.paint(canvas, Offset(padding + (barcodeWidth - textPainter.width) / 2, currentY));
          currentY += lineSpacing;
        }
      } else if (_labelSettings.showJobNo) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _getJobNumber(),
            style: TextStyle(color: Colors.black, fontSize: baseFontSize, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: contentWidth);
        textPainter.paint(canvas, Offset(padding, padding));
        currentY = padding + lineSpacing;
      }

      // Draw QR code at same top position as barcode (aligned) - only if QR enabled
      if (_labelSettings.showJobQR || _labelSettings.showTrackingPortalQR) {
        final qrPainter = QrPainter(
          data: _labelSettings.showJobQR
              ? _getQRCodeData()
              : 'https://tracking.portal/${widget.jobResponse.data?.sId ?? ''}',
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
        );

        final qrX = drawableWidth - padding - qrSize;
        canvas.save();
        canvas.translate(qrX, padding); // Same Y position as barcode
        canvas.scale(qrSize / 200); // QrPainter draws at ~200px
        qrPainter.paint(canvas, const Size(200, 200));
        canvas.restore();

        // Update currentY based on QR height
        final qrBottomY = padding + qrSize;
        if (qrBottomY > currentY) {
          currentY = qrBottomY;
        }
      }

      // Draw info text BELOW both barcode and QR (after tallest element)
      currentY += 8; // Add spacing

      // Build text lines based on settings
      final List<String> textLines = [];

      // First line: Customer | Device
      if (_labelSettings.showCustomerName || _labelSettings.showModelBrand) {
        final line = [
          if (_labelSettings.showCustomerName) _getCustomerName(),
          if (_labelSettings.showModelBrand) _getDeviceName(),
        ].where((e) => e.isNotEmpty).join(' | ');
        if (line.isNotEmpty) textLines.add(line);
      }

      // IMEI line
      if (_labelSettings.showModelBrand) {
        textLines.add('IMEI: ${_getDeviceIMEI()}');
      }

      // Defect/Location line
      if (_labelSettings.showSymptom || _labelSettings.showPhysicalLocation) {
        final line = [
          if (_labelSettings.showSymptom) _getDefect(),
          if (_labelSettings.showPhysicalLocation) 'BOX: ${_getPhysicalLocation()}',
        ].where((e) => e.isNotEmpty).join(' | ');
        if (line.isNotEmpty) textLines.add(line);
      }

      // Paint each line.
      // Use an accumulating lineY so that wrapped (multi-visual-row) lines
      // don't cause the following line to overlap. Fixed i*lineSpacing was
      // the cause of overlap on small Xprinter labels where long text wraps.
      double lineY = currentY;
      for (int i = 0; i < textLines.length; i++) {
        final linePainter = TextPainter(
          text: TextSpan(
            text: textLines[i],
            style: TextStyle(color: Colors.black, fontSize: baseFontSize, fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        );
        linePainter.layout(maxWidth: contentWidth);
        linePainter.paint(canvas, Offset(padding, lineY));
        // Advance by the ACTUAL painted height (which includes all wrapped
        // rows), plus a small inter-line gap.
        lineY += linePainter.height + 4;
      }

      // End recording and create image
      final picture = recorder.endRecording();
      final image = await picture.toImage(canvasWidth, canvasHeight);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();

      if (byteData == null) {
        debugPrint('❌ Failed to convert image to bytes');
        return null;
      }

      final imageBytes = byteData.buffer.asUint8List();
      debugPrint('✅ Generated ${canvasWidth}x$canvasHeight image (${imageBytes.length} bytes) at $dpi DPI');
      return imageBytes;
    } catch (e, st) {
      debugPrint('❌ Error generating label image: $e');
      debugPrint('Stack trace: $st');
      return null;
    }
  }

  /// Draw Code128 barcode manually using the barcode package
  void _drawBarcode(Canvas canvas, String data, double x, double y, double width, double height) {
    // Use barcode_widget's Barcode class (same as BarcodeWidget uses)
    final barcodeGen = Barcode.code128();
    final elements = barcodeGen.make(data, width: width, height: height, drawText: false);

    final blackPaint = Paint()..color = Colors.black;

    for (final element in elements) {
      // BarcodeElement has left, top, width, height properties
      // BarcodeBar extends BarcodeElement and has a 'black' property
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(Rect.fromLTWH(x + element.left, y + element.top, element.width, element.height), blackPaint);
      }
    }
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
