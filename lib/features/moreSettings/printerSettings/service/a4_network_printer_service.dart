import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'base_printer_service.dart';

/// A4 Network Printer Service
/// Bypasses iOS AirPrint by sending PDF directly to printer via raw TCP
/// Supports HP, Canon, Epson, and most modern network printers with PDF Direct Print
class A4NetworkPrinterService implements BasePrinterService {
  static final A4NetworkPrinterService _instance = A4NetworkPrinterService._internal();
  factory A4NetworkPrinterService() => _instance;
  A4NetworkPrinterService._internal();

  /// Print A4 receipt by sending PDF directly to printer
  /// Most modern HP, Canon, Epson printers support PDF Direct Print on port 9100
  Future<PrinterResult> printA4Receipt({
    required String ipAddress,
    required Uint8List pdfBytes,
    int port = 9100,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      debugPrint('📄 [A4NetworkPrinter] Connecting to printer at $ipAddress:$port');

      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Send PDF header for HP PCL printers
      // UEL (Universal Exit Language) ensures we're in PCL mode
      socket.add([0x1B, 0x45]); // ESC E - Reset printer

      // Send PDF data
      socket.add(pdfBytes);

      // Send form feed to eject page
      socket.add([0x0C]); // Form feed

      await socket.flush();
      socket.destroy();

      debugPrint('✅ [A4NetworkPrinter] PDF sent successfully (${pdfBytes.length} bytes)');
      return PrinterResult(success: true, message: 'A4 receipt printed successfully', code: 0);
    } on SocketException catch (e) {
      debugPrint('❌ [A4NetworkPrinter] Socket error: $e');
      return PrinterResult(
        success: false,
        message: 'Cannot connect to printer at $ipAddress:$port. Check IP address and network.',
        code: -1,
      );
    } catch (e) {
      debugPrint('❌ [A4NetworkPrinter] Print error: $e');
      return PrinterResult(success: false, message: 'Print error: $e', code: -1);
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
    // A4 printers don't support label printing
    return PrinterResult(success: false, message: 'A4 printer does not support label format', code: -1);
  }

  @override
  Future<PrinterResult> printDeviceLabel({
    required String ipAddress,
    required Map<String, String> labelData,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // A4 printers don't support device label printing
    return PrinterResult(success: false, message: 'A4 printer does not support device label format', code: -1);
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
