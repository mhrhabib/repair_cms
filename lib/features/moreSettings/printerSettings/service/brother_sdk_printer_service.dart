import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:brother_printer/brother_printer.dart';
import 'package:brother_printer/model.dart';
import 'package:printing/printing.dart' as printing;
import 'package:pdf/widgets.dart' as pw;
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'base_printer_service.dart' as base;
import 'printer_settings_service.dart';
import 'package:path_provider/path_provider.dart';

/// Service class to handle Brother printer operations using brother_printer SDK
/// Supports TD-2D, TD-4D, QL, and PT series printers
class BrotherSDKPrinterService implements base.BasePrinterService {
  static final BrotherSDKPrinterService _instance = BrotherSDKPrinterService._internal();
  factory BrotherSDKPrinterService() => _instance;
  BrotherSDKPrinterService._internal();

  final _settingsService = PrinterSettingsService();

  /// Helper to get the model string from settings for a given IP
  String _getModelForIp(String ipAddress) {
    try {
      final printers = _settingsService.getPrinters('label');
      final printer = printers.firstWhere((p) => p.ipAddress == ipAddress);
      return printer.printerModel ?? 'QL-820NWB';
    } catch (e) {
      return 'QL-820NWB'; // Fallback
    }
  }

  /// Map model string to BrotherModel enum
  BrotherModel _getModelFromString(String modelString) {
    final s = modelString.replaceAll('_', '-').toUpperCase();
    switch (s) {
      case 'QL-820NWB':
        return BRLMPrinterModelQL_820NWB;
      case 'QL-1110NWB':
        return BRLMPrinterModelQL_1110NWB;
      case 'QL-810W':
        return BRLMPrinterModelQL_810W;
      case 'QL-710W':
        return BRLMPrinterModelQL_710W;
      case 'QL-720NW':
        return BRLMPrinterModelQL_720NW;
      case 'QL-1115NWB':
        return BRLMPrinterModelQL_1115NWB;
      case 'PT-P750W':
        return BRLMPrinterModelPT_P750W;
      case 'PT-P300BT':
        return BRLMPrinterModelPT_P300BT;
      case 'TD-2030A':
        return BRLMPrinterModelTD_2030A;
      case 'TD-2125N':
        return BRLMPrinterModelTD_2125N;
      case 'TD-2125NWB':
        return BRLMPrinterModelTD_2125NWB;
      case 'TD-2135N':
        return BRLMPrinterModelTD_2135N;
      case 'TD-2135NWB':
        return BRLMPrinterModelTD_2135NWB;
      case 'TD-4550DNWB':
        return BRLMPrinterModelTD_4550DNWB;
      default:
        if (s.startsWith('TD-')) return BRLMPrinterModelTD_4550DNWB;
        return BRLMPrinterModelQL_820NWB;
    }
  }

  /// Create a BrotherDevice for network printing
  BrotherDevice _createNetworkDevice(String ipAddress, String modelString) {
    final model = _getModelFromString(modelString);

    return BrotherDevice(
      source: BrotherDeviceSource.network,
      model: model,
      ipAddress: ipAddress,
      modelName: modelString,
    );
  }

  /// Map our app's `LabelSize` (from settings) to `BrotherLabelSize` used by the SDK
  BrotherLabelSize _mapLabelSizeToBrother(LabelSize? labelSize, String modelString) {
    if (labelSize == null) return BrotherLabelSize.QLRollW62;

    final w = labelSize.width;
    final h = labelSize.height;
    final name = labelSize.name.toLowerCase();

    // Common QL die-cut sizes
    // 51x26 is not an exact Brother enum, map to closest: QLDieCutW52H29
    if (w == 51 && h == 26) return BrotherLabelSize.QLDieCutW52H29;
    if (w == 62 && h == 29) return BrotherLabelSize.QLDieCutW62H29;
    if (w == 62 && h == 100) return BrotherLabelSize.QLDieCutW62H100;
    if (w == 29 && h == 90) return BrotherLabelSize.QLDieCutW29H90;
    if (w == 52 && h == 29) return BrotherLabelSize.QLDieCutW52H29;
    if (w == 39 && h == 48) return BrotherLabelSize.QLDieCutW39H48;

    // Roll sizes
    if (w == 50) return BrotherLabelSize.QLRollW50;
    if (w == 62 && name.contains('rb')) return BrotherLabelSize.QLRollW62RB;
    if (w == 62) return BrotherLabelSize.QLRollW62;
    if (w == 102) return BrotherLabelSize.QLRollW102;

    // PT tape widths
    if (w == 3 || w == 4) return BrotherLabelSize.PT3_5mm;
    if (w == 6) return BrotherLabelSize.PT6mm;
    if (w == 9) return BrotherLabelSize.PT9mm;
    if (w == 12) return BrotherLabelSize.PT12mm;
    if (w == 18) return BrotherLabelSize.PT18mm;
    if (w == 24) return BrotherLabelSize.PT24mm;
    if (w == 36) return BrotherLabelSize.PT36mm;

    // TD printers: prefer roll 62 if width >=60 else 50
    if (modelString.toUpperCase().startsWith('TD-')) {
      return w >= 60 ? BrotherLabelSize.QLRollW62 : BrotherLabelSize.QLRollW50;
    }

    return BrotherLabelSize.QLRollW62;
  }

  @override
  Future<base.PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return printLabel(ipAddress: ipAddress, text: text, port: port, timeout: timeout);
  }

  @override
  Future<base.PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final modelString = _getModelForIp(ipAddress);
      final device = _createNetworkDevice(ipAddress, modelString);

      // Debug info: log mapping and device details before opening SDK stream
      debugPrint('🛠️ Brother SDK — modelString=$modelString');
      debugPrint(
        '🛠️ Brother SDK — device: ip=${device.ipAddress}, source=${device.source}, model=${device.model}, modelName=${device.modelName}',
      );

      // Create a small PDF from the text and print via SDK
      final pdfPath = await _createPdfFromText(text);
      final cfgLabelSize = _settingsService.getDefaultPrinter('label')?.labelSize;
      final brotherLabel = _mapLabelSizeToBrother(cfgLabelSize, modelString);
      debugPrint('🛠️ Brother SDK — sending PDF at $pdfPath with labelSize=$brotherLabel');
      await BrotherPrinter.printPDF(path: pdfPath, device: device, labelSize: brotherLabel);

      // cleanup
      try {
        await File(pdfPath).delete();
      } catch (_) {}

      return base.PrinterResult(success: true, message: 'Print successful (SDK)', code: 0);
    } catch (e, st) {
      debugPrint('❌ Brother SDK printLabel error: $e');
      debugPrint(st.toString());
      return base.PrinterResult(success: false, message: 'Error: $e', code: -1);
    }
  }

  @override
  Future<base.PrinterResult> printDeviceLabel({
    required String ipAddress,
    required Map<String, String> labelData,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('JOB: ${labelData['jobNumber'] ?? 'N/A'}');
    buffer.writeln('CUSTOMER: ${labelData['customerName'] ?? 'N/A'}');
    buffer.writeln('DEVICE: ${labelData['deviceName'] ?? 'N/A'}');
    buffer.writeln('IMEI: ${labelData['imei'] ?? 'N/A'}');
    buffer.writeln('DEFECT: ${labelData['defect'] ?? 'N/A'}');
    buffer.writeln('LOCATION: ${labelData['location'] ?? 'N/A'}');

    return printLabel(ipAddress: ipAddress, text: buffer.toString(), port: port, timeout: timeout);
  }

  @override
  Future<base.PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
  }) async {
    try {
      final modelString = _getModelForIp(ipAddress);
      final device = _createNetworkDevice(ipAddress, modelString);
      debugPrint('🛠️ Brother SDK (image) — device: ip=${device.ipAddress}, model=${device.modelName}');

      final tempDir = await getTemporaryDirectory();
      final isPdf =
          imageBytes.length > 4 &&
          imageBytes[0] == 0x25 &&
          imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x44 &&
          imageBytes[3] == 0x46;

      File? tempFile;

      if (isPdf) {
        // Rasterize PDF to image
        await for (var page in printing.Printing.raster(imageBytes, pages: [0], dpi: 300)) {
          final uiImage = await page.toImage();
          final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

          tempFile = File('${tempDir.path}/print_pdf_${DateTime.now().millisecondsSinceEpoch}.png');
          await tempFile.writeAsBytes(byteData!.buffer.asUint8List());
          break; // Only print first page
        }
      } else {
        // Save image bytes directly
        tempFile = File('${tempDir.path}/print_image_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(imageBytes);
      }

      if (tempFile == null) {
        return base.PrinterResult(success: false, message: 'Failed to process image', code: -1);
      }

      // Create PDF from image and send to SDK
      final pdfPath = await _createPdfFromImage(await tempFile.readAsBytes());
      final cfgLabelSizeImg = _settingsService.getDefaultPrinter('label')?.labelSize;
      final brotherLabelImg = _mapLabelSizeToBrother(cfgLabelSizeImg, modelString);
      debugPrint('🛠️ Brother SDK (image) — sending PDF at $pdfPath with labelSize=$brotherLabelImg');
      await BrotherPrinter.printPDF(path: pdfPath, device: device, labelSize: brotherLabelImg);

      try {
        await tempFile.delete();
        await File(pdfPath).delete();
      } catch (_) {}

      return base.PrinterResult(success: true, message: 'Print successful (SDK)', code: 0);
    } catch (e, st) {
      debugPrint('❌ Brother SDK printLabelImage error: $e');
      debugPrint(st.toString());
      return base.PrinterResult(success: false, message: 'Error: $e', code: -1);
    }
  }

  @override
  Future<base.PrinterStatus> getPrinterStatus({required String ipAddress, int port = 9100}) async {
    try {
      final modelString = _getModelForIp(ipAddress);
      final device = _createNetworkDevice(ipAddress, modelString);

      // Use brother_printer discovery to check for device presence
      final devices = await BrotherPrinter.searchDevices(delay: 3);
      debugPrint('🛠️ Brother SDK — discovered devices: ${devices.map((d) => d.ipAddress).toList()}');
      final found = devices.any((d) => d.ipAddress == ipAddress);

      return base.PrinterStatus(
        isConnected: found,
        message: found ? 'Printer connected' : 'Printer not found',
        code: found ? 0 : -1,
      );
    } catch (e) {
      return base.PrinterStatus(isConnected: false, message: 'Status error: $e', code: -1);
    }
  }

  /// Create an image from text
  Future<ui.Image> _createTextImage(String text, {int fontSize = 12}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: const Color(0xFF000000), fontSize: fontSize.toDouble()),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: 400);

    // Add some padding
    final width = textPainter.width + 20;
    final height = textPainter.height + 20;

    // Draw white background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = const Color(0xFFFFFFFF));

    // Draw text
    textPainter.paint(canvas, const Offset(10, 10));

    final picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }

  Future<String> _createPdfFromText(String text) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (pw.Context ctx) => pw.Container(child: pw.Text(text))));
    final bytes = await doc.save();
    final file = File(
      '${(await getTemporaryDirectory()).path}/brother_text_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> _createPdfFromImage(Uint8List imageBytes) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(imageBytes);
    doc.addPage(pw.Page(build: (pw.Context ctx) => pw.Center(child: pw.Image(image))));
    final bytes = await doc.save();
    final file = File(
      '${(await getTemporaryDirectory()).path}/brother_image_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file.path;
  }

  bool usesBrotherSDK(String modelString) {
    return modelString.startsWith('TD-') || modelString.startsWith('QL-') || modelString.startsWith('PT-');
  }
}
