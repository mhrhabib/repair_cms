import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/features/moreSettings/labelContent/service/label_content_settings_service.dart';

/// Data needed to generate a label image.
class LabelData {
  final String jobNumber;
  final String customerName;
  final String deviceName;
  final String deviceIMEI;
  final String defect;
  final String physicalLocation;
  final String jobId;
  final String barcodeData;
  final String qrCodeData;

  const LabelData({
    required this.jobNumber,
    required this.customerName,
    required this.deviceName,
    required this.deviceIMEI,
    required this.defect,
    required this.physicalLocation,
    required this.jobId,
    required this.barcodeData,
    required this.qrCodeData,
  });
}

/// Shared label image generator used by both job booking and job details flows.
class LabelImageGenerator {
  LabelImageGenerator._();

  /// Get dots per mm based on printer model
  static double getDotsPerMm(PrinterConfigModel? printer) {
    final model = printer?.printerModel?.toUpperCase() ?? '';

    debugPrint('🔍 Checking printer model: "$model"');

    if (model.startsWith('TD-4')) {
      debugPrint('✅ TD-4 series detected: 300 DPI (11.811 dots/mm)');
      return 11.811;
    }

    if (model.contains('TD-2350')) {
      debugPrint('✅ TD-2350 series detected: 300 DPI (11.82 dots/mm)');
      return 11.82;
    }

    if (model.startsWith('TD-2')) {
      debugPrint('✅ Other TD-2 series detected: 203 DPI (8.0 dots/mm)');
      return 8.0;
    }

    if (printer?.printerBrand.toLowerCase() == 'xprinter') {
      debugPrint('✅ Xprinter detected: 203 DPI (8.0 dots/mm)');
      return 8.0;
    }

    debugPrint('⚠️ Unknown printer model, using default 203 DPI');
    return 8.0;
  }

  /// Draw Code128 barcode manually using the barcode package
  static void _drawBarcode(
    Canvas canvas,
    String data,
    double x,
    double y,
    double width,
    double height,
  ) {
    final barcodeGen = Barcode.code128();
    final elements =
        barcodeGen.make(data, width: width, height: height, drawText: false);

    final blackPaint = Paint()..color = Colors.black;

    for (final element in elements) {
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
              x + element.left, y + element.top, element.width, element.height),
          blackPaint,
        );
      }
    }
  }

  /// Generate label image at exact printer resolution.
  /// This is the single source of truth for label image generation.
  static Future<Uint8List?> captureLabelAsImage({
    required PrinterConfigModel printer,
    required LabelContentSettings labelSettings,
    required LabelData labelData,
  }) async {
    try {
      debugPrint('📸 Generating label image at printer resolution');

      final labelWidthMm = printer.labelSize?.width ?? 50;
      final labelHeightMm = printer.labelSize?.height ?? 26;

      final dotsPerMm = getDotsPerMm(printer);
      final dpi = dotsPerMm > 10 ? 300 : 203;

      final widthPx = (labelWidthMm * dotsPerMm).round();
      final heightPx = (labelHeightMm * dotsPerMm).round();

      // All printers use portrait canvas matching raster dimensions.
      final canvasWidth = widthPx;
      final canvasHeight = heightPx;

      debugPrint(
          '📐 Printer: ${printer.printerModel ?? "unknown"} (${printer.printerBrand}), DPI: $dpi');
      debugPrint(
          '📐 Label: ${labelWidthMm}x${labelHeightMm}mm → Image: ${canvasWidth}x${canvasHeight}px (Portrait)');

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
      );

      // White background
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
        bgPaint,
      );

      final bool isBrother = printer.printerBrand.toLowerCase() == 'brother';
      final bool isTD4Model =
          (printer.printerModel?.toUpperCase() ?? '').startsWith('TD-4');

      // TD-2D: 50px canvas translate compensates for hardware margins.
      // TD-4: No canvas offset — positioning handled by raster line centering.
      // Xprinter: TSPL SIZE/GAP commands handle the printable area.
      final double offsetX = isBrother ? (isTD4Model ? 0.0 : 50.0) : 0.0;
      final double offsetY = isBrother ? (isTD4Model ? 0.0 : 50.0) : 0.0;
      if (offsetX > 0 || offsetY > 0) canvas.translate(offsetX, offsetY);

      final drawableWidth = canvasWidth.toDouble() - 2 * offsetX;
      final drawableHeight = canvasHeight.toDouble() - 2 * offsetY;

      final double padding =
          isTD4Model ? drawableWidth * 0.04 : drawableWidth * 0.02;
      final double contentWidth = drawableWidth - (padding * 2);
      final double barcodeWidth = contentWidth * 0.62;
      final double barcodeHeight = drawableHeight * 0.24;
      final double qrSize = contentWidth * 0.22;

      // Draw barcode (only if barcode setting is enabled)
      if (labelSettings.showBarcode) {
        _drawBarcode(canvas, labelData.barcodeData, padding, padding,
            barcodeWidth, barcodeHeight);
      }

      // Font size: proportional to drawable height, same for all printers.
      final double baseFontSize = (drawableHeight * 0.09).clamp(20.0, 32.0);
      final double lineSpacing = baseFontSize + 3.0;

      // Draw job number under barcode (only if showJobNo is enabled)
      double currentY = padding;
      if (labelSettings.showBarcode) {
        currentY = padding + barcodeHeight + 4;
        if (labelSettings.showJobNo) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: labelData.jobNumber,
              style: TextStyle(
                color: Colors.black,
                fontSize: baseFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: barcodeWidth);
          textPainter.paint(
            canvas,
            Offset(
                padding + (barcodeWidth - textPainter.width) / 2, currentY),
          );
          currentY += lineSpacing;
        }
      } else if (labelSettings.showJobNo) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelData.jobNumber,
            style: TextStyle(
              color: Colors.black,
              fontSize: baseFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: contentWidth);
        textPainter.paint(canvas, Offset(padding, padding));
        currentY = padding + lineSpacing;
      }

      // Draw QR code at same top position as barcode (aligned)
      if (labelSettings.showJobQR || labelSettings.showTrackingPortalQR) {
        final qrData = labelSettings.showJobQR
            ? labelData.qrCodeData
            : 'https://tracking.portal/${labelData.jobId}';

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

        final qrX = drawableWidth - padding - qrSize;
        canvas.save();
        canvas.translate(qrX, padding);
        canvas.scale(qrSize / 200);
        qrPainter.paint(canvas, const Size(200, 200));
        canvas.restore();

        final qrBottomY = padding + qrSize;
        if (qrBottomY > currentY) {
          currentY = qrBottomY;
        }
      }

      // Draw info text BELOW both barcode and QR
      currentY += 8;

      // Build single flowing text block
      final List<String> textParts = [];

      if (labelSettings.showCustomerName) {
        final name = labelData.customerName;
        if (name.isNotEmpty) textParts.add(name);
      }
      if (labelSettings.showModelBrand) {
        final device = labelData.deviceName;
        if (device.isNotEmpty) {
          textParts.add('$device IMEI: ${labelData.deviceIMEI}');
        }
      }
      if (labelSettings.showSymptom) {
        final defect = labelData.defect;
        if (defect.isNotEmpty) textParts.add(defect);
      }
      if (labelSettings.showPhysicalLocation) {
        final location = labelData.physicalLocation;
        if (location.isNotEmpty) textParts.add('BOX: $location');
      }

      // Paint as a single text block
      if (textParts.isNotEmpty) {
        final combinedText = textParts.join(' | ');
        final linePainter = TextPainter(
          text: TextSpan(
            text: combinedText,
            style: TextStyle(
              color: Colors.black,
              fontSize: baseFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        linePainter.layout(maxWidth: contentWidth);
        linePainter.paint(canvas, Offset(padding, currentY));
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
      debugPrint(
          '✅ Generated ${canvasWidth}x$canvasHeight image (${imageBytes.length} bytes) at $dpi DPI');
      return imageBytes;
    } catch (e, st) {
      debugPrint('❌ Error generating label image: $e');
      debugPrint('Stack trace: $st');
      return null;
    }
  }
}
