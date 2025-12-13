import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'base_printer_service.dart';

/// Lightweight network printer service (raw TCP) that works on the iOS simulator
/// This is intended as a simulator-friendly replacement for the device-only
/// `another_brother` SDK. It sends plain text over TCP (port 9100 by default).
/// For full ESC/POS features or label printing support you should integrate a
/// platform-specific plugin or add an ESC/POS utility package.
class BrotherPrinterService implements BasePrinterService {
  static final BrotherPrinterService _instance = BrotherPrinterService._internal();
  factory BrotherPrinterService() => _instance;
  BrotherPrinterService._internal();

  @override
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);
      socket.add(utf8.encode(text));
      // A few line feeds to ensure the printer advances paper
      socket.add(utf8.encode('\n\n\n'));
      await socket.flush();
      socket.destroy();

      return PrinterResult(success: true, message: 'Printed (raw TCP)', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return printThermalReceipt(ipAddress: ipAddress, text: text, port: port, timeout: timeout);
  }

  @override
  Future<PrinterResult> printDeviceLabel({
    required String ipAddress,
    required Map<String, String> labelData,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      // Step 1: Connect to printer
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Step 2: Build ESC/POS commands
      final List<int> bytes = [];

      // ESC/POS Commands
      const esc = 0x1B;
      const gs = 0x1D;

      // Initialize printer
      bytes.addAll([esc, 0x40]); // ESC @ - Initialize

      // Bold ON
      bytes.addAll([esc, 0x45, 0x01]); // ESC E 1

      // Print title
      bytes.addAll(utf8.encode('DEVICE LABEL\n'));

      // Bold OFF
      bytes.addAll([esc, 0x45, 0x00]); // ESC E 0

      // Line separator
      bytes.addAll(utf8.encode('===============\n'));

      // Print data fields
      labelData.forEach((key, value) {
        bytes.addAll(utf8.encode('$key: $value\n'));
      });

      // Line separator
      bytes.addAll(utf8.encode('===============\n'));

      // Line feeds
      bytes.addAll([0x0A, 0x0A, 0x0A]);

      // Cut paper (if supported)
      bytes.addAll([gs, 0x56, 0x42, 0x00]); // GS V B 0 - Full cut

      // Step 3: Send to printer
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      socket.destroy();

      return PrinterResult(success: true, message: 'Device label printed successfully', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Device label print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
  }) async {
    return PrinterResult(success: false, message: 'Image printing not supported', code: -2);
  }

  @override
  Future<PrinterStatus> getPrinterStatus({required String ipAddress, int port = 9100}) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 4));
      socket.destroy();
      return PrinterStatus(isConnected: true, message: 'Printer reachable', code: 0);
    } catch (e) {
      return PrinterStatus(isConnected: false, message: 'Printer not reachable: $e', code: -1);
    }
  }
}
