import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/set_up_di.dart';

import 'base_printer_service.dart';

/// A4 Network Printer Service
/// Bypasses iOS AirPrint by sending PDF directly to printer via raw TCP
/// Supports HP, Canon, Epson, and most modern network printers with PDF Direct Print
class A4NetworkPrinterService implements BasePrinterService {
  static final A4NetworkPrinterService _instance = A4NetworkPrinterService._internal();
  factory A4NetworkPrinterService() => _instance;
  A4NetworkPrinterService._internal();

  Talker get _talker => SetUpDI.getIt<Talker>();

  /// Print A4 receipt by sending PDF directly to printer with multiple fallback strategies
  /// Most modern HP, Canon, Epson printers support PDF Direct Print on port 9100
  Future<PrinterResult> printA4Receipt({
    required String ipAddress,
    required Uint8List pdfBytes,
    int port = 9100,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _talker.info('[A4Printer: $ipAddress:$port] Starting A4 print job with ${pdfBytes.length} bytes');

    // Try each strategy with retry logic (2 full attempts of all 3 strategies)
    for (int attempt = 1; attempt <= 2; attempt++) {
      if (attempt > 1) {
        _talker.debug('[A4Printer: $ipAddress] Retry attempt $attempt after 2 second delay');
        await Future.delayed(const Duration(seconds: 2));
      }

      // Strategy 1: Pure PDF (works with most modern HP printers)
      _talker.debug('[A4Printer: $ipAddress] Trying Strategy 1: Pure PDF (Attempt $attempt/2)');
      debugPrint('📄 [A4NetworkPrinter] Trying Strategy 1: Pure PDF');
      final result1 = await _printWithStrategy1(ipAddress, pdfBytes, port, timeout);
      if (result1.success) {
        _talker.info('[A4Printer: $ipAddress] ✅ SUCCESS with Strategy 1');
        return result1;
      }

      _talker.warning('[A4Printer: $ipAddress] Strategy 1 failed, trying Strategy 2');
      debugPrint('⚠️ [A4NetworkPrinter] Strategy 1 failed, trying Strategy 2: PDF with PCL wrapper');
      // Strategy 2: PDF with PCL wrapper (for printers that need mode switching)
      final result2 = await _printWithStrategy2(ipAddress, pdfBytes, port, timeout);
      if (result2.success) {
        _talker.info('[A4Printer: $ipAddress] ✅ SUCCESS with Strategy 2');
        return result2;
      }

      _talker.warning('[A4Printer: $ipAddress] Strategy 2 failed, trying Strategy 3');
      debugPrint('⚠️ [A4NetworkPrinter] Strategy 2 failed, trying Strategy 3: PDF with minimal commands');
      // Strategy 3: PDF with minimal commands
      final result3 = await _printWithStrategy3(ipAddress, pdfBytes, port, timeout);
      if (result3.success) {
        _talker.info('[A4Printer: $ipAddress] ✅ SUCCESS with Strategy 3');
        return result3;
      }
    }

    _talker.error('[A4Printer: $ipAddress] ❌ ALL STRATEGIES FAILED after 2 attempts');
    debugPrint('❌ [A4NetworkPrinter] All strategies failed after retries');
    return PrinterResult(
      success: false,
      message:
          'Print failed after 2 attempts with 3 strategies. Check: 1) Printer supports PDF Direct Print or PCL, 2) Printer is online and ready, 3) Network firewall allows port $port, 4) Try different printer driver.',
      code: -1,
    );
  }

  /// Strategy 1: Send only PDF data (cleanest, works with modern HP)
  Future<PrinterResult> _printWithStrategy1(String ipAddress, Uint8List pdfBytes, int port, Duration timeout) async {
    try {
      _talker.debug('[A4Printer: $ipAddress] Strategy 1: Connecting...');
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      _talker.info('[A4Printer: $ipAddress] Strategy 1: Sending pure PDF (${pdfBytes.length} bytes)');
      debugPrint('📄 [A4NetworkPrinter] Strategy 1: Sending pure PDF (${pdfBytes.length} bytes)');
      socket.add(pdfBytes);

      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500)); // Give printer time to process
      socket.destroy();

      _talker.info('[A4Printer: $ipAddress] ✅ Strategy 1 completed successfully');
      debugPrint('✅ [A4NetworkPrinter] Strategy 1 completed');
      return PrinterResult(success: true, message: 'A4 receipt printed (Strategy 1)', code: 0);
    } catch (e) {
      _talker.error('[A4Printer: $ipAddress] ❌ Strategy 1 error: $e');
      debugPrint('❌ [A4NetworkPrinter] Strategy 1 error: $e');
      return PrinterResult(success: false, message: 'Strategy 1 failed: $e', code: -1);
    }
  }

  /// Strategy 2: PDF with UEL and PCL commands (for older HP models)
  Future<PrinterResult> _printWithStrategy2(String ipAddress, Uint8List pdfBytes, int port, Duration timeout) async {
    try {
      _talker.debug('[A4Printer: $ipAddress] Strategy 2: Connecting...');
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      _talker.info('[A4Printer: $ipAddress] Strategy 2: Sending PDF with PCL wrapper');
      debugPrint('📄 [A4NetworkPrinter] Strategy 2: PDF with PCL wrapper');

      // UEL command to reset printer
      socket.add([0x1B, 0x25, 0x2D, 0x31, 0x32, 0x33, 0x34, 0x35, 0x58]); // %-12345X
      socket.add([0x1B, 0x45]); // ESC E - Reset

      socket.add(pdfBytes);

      socket.add([0x1B, 0x25, 0x2D, 0x31, 0x32, 0x33, 0x34, 0x35, 0x58]); // %-12345X
      socket.add([0x0C]); // Form feed

      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500));
      socket.destroy();

      _talker.info('[A4Printer: $ipAddress] ✅ Strategy 2 completed successfully');
      debugPrint('✅ [A4NetworkPrinter] Strategy 2 completed');
      return PrinterResult(success: true, message: 'A4 receipt printed (Strategy 2)', code: 0);
    } catch (e) {
      _talker.error('[A4Printer: $ipAddress] ❌ Strategy 2 error: $e');
      debugPrint('❌ [A4NetworkPrinter] Strategy 2 error: $e');
      return PrinterResult(success: false, message: 'Strategy 2 failed: $e', code: -1);
    }
  }

  /// Strategy 3: PDF with simple reset and form feed
  Future<PrinterResult> _printWithStrategy3(String ipAddress, Uint8List pdfBytes, int port, Duration timeout) async {
    try {
      _talker.debug('[A4Printer: $ipAddress] Strategy 3: Connecting...');
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      _talker.info('[A4Printer: $ipAddress] Strategy 3: Sending PDF with minimal commands');
      debugPrint('📄 [A4NetworkPrinter] Strategy 3: PDF with minimal commands');

      socket.add([0x1B, 0x40]); // ESC @ - Initialize (simpler than UEL)
      socket.add(pdfBytes);
      socket.add([0x0C]); // Form feed
      socket.add([0x0C]); // Double form feed for stubborn printers

      await socket.flush();
      await Future.delayed(const Duration(seconds: 1)); // Longer delay
      socket.destroy();

      _talker.info('[A4Printer: $ipAddress] ✅ Strategy 3 completed successfully');
      debugPrint('✅ [A4NetworkPrinter] Strategy 3 completed');
      return PrinterResult(success: true, message: 'A4 receipt printed (Strategy 3)', code: 0);
    } catch (e) {
      _talker.error('[A4Printer: $ipAddress] ❌ Strategy 3 error: $e');
      debugPrint('❌ [A4NetworkPrinter] Strategy 3 error: $e');
      return PrinterResult(success: false, message: 'Strategy 3 failed: $e', code: -1);
    }
  }

  /// Generate PDF from captured receipt image
  Future<Uint8List> generatePdfFromImage({
    required Uint8List imageBytes,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final pw.ImageProvider img = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain));
        },
      ),
    );

    return pdf.save();
  }

  @override
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // A4 printers don't support thermal receipt printing
    return PrinterResult(success: false, message: 'A4 printer does not support thermal receipt format', code: -1);
  }

  @override
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      _talker.info('[A4Printer: $ipAddress] Converting text to PDF for label printing');
      debugPrint('📄 [A4NetworkPrinter] Converting text to PDF for label printing');

      // Create a simple PDF from text
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.topLeft,
              child: pw.Text(text, style: const pw.TextStyle(fontSize: 12)),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      return printA4Receipt(ipAddress: ipAddress, pdfBytes: pdfBytes, port: port, timeout: timeout);
    } catch (e) {
      _talker.error('[A4Printer: $ipAddress] ❌ Failed to convert text to PDF: $e');
      debugPrint('❌ [A4NetworkPrinter] Failed to convert text to PDF: $e');
      return PrinterResult(success: false, message: 'Failed to generate PDF: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printDeviceLabel({
    required String ipAddress,
    required Map<String, String> labelData,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      _talker.info('[A4Printer: $ipAddress] Creating formatted device label PDF');
      debugPrint('📄 [A4NetworkPrinter] Creating formatted device label PDF');

      // Format label data into text
      final buffer = StringBuffer();
      buffer.writeln('═══════════════════════════════════');
      buffer.writeln('         DEVICE LABEL');
      buffer.writeln('═══════════════════════════════════');
      buffer.writeln('');
      buffer.writeln('JOB: ${labelData['jobNumber'] ?? 'N/A'}');
      buffer.writeln('CUSTOMER: ${labelData['customerName'] ?? 'N/A'}');
      buffer.writeln('DEVICE: ${labelData['deviceName'] ?? 'N/A'}');
      buffer.writeln('IMEI: ${labelData['imei'] ?? 'N/A'}');
      buffer.writeln('DEFECT: ${labelData['defect'] ?? 'N/A'}');
      buffer.writeln('LOCATION: ${labelData['location'] ?? 'N/A'}');
      buffer.writeln('');
      buffer.writeln('═══════════════════════════════════');

      return printLabel(ipAddress: ipAddress, text: buffer.toString(), port: port, timeout: timeout);
    } catch (e) {
      _talker.error('[A4Printer: $ipAddress] ❌ Failed to create device label: $e');
      debugPrint('❌ [A4NetworkPrinter] Failed to create device label: $e');
      return PrinterResult(success: false, message: 'Failed to create device label: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
  }) async {
    // A4 printers don't support direct label image printing
    return PrinterResult(success: false, message: 'A4 printer does not support label image format', code: -1);
  }

  @override
  Future<PrinterStatus> getPrinterStatus({required String ipAddress, int port = 9100}) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 3));
      socket.destroy();
      return PrinterStatus(isConnected: true, message: 'Printer is reachable', code: 0);
    } catch (e) {
      return PrinterStatus(isConnected: false, message: 'Cannot reach printer: $e', code: -1);
    }
  }
}
