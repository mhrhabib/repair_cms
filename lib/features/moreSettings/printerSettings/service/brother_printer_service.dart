import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

/// Lightweight network printer service (raw TCP) that works on the iOS simulator
/// This is intended as a simulator-friendly replacement for the device-only
/// `another_brother` SDK. It sends plain text over TCP (port 9100 by default).
/// For full ESC/POS features or label printing support you should integrate a
/// platform-specific plugin or add an ESC/POS utility package.
class BrotherPrinterService {
  static final BrotherPrinterService _instance = BrotherPrinterService._internal();
  factory BrotherPrinterService() => _instance;
  BrotherPrinterService._internal();

  /// Send plain text to a network printer on [ipAddress]:[port].
  /// Many network thermal printers accept plain text on port 9100.
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

  /// Basic text label printer method - forwards to thermal printing for now.
  Future<PrinterResult> printLabel({required String ipAddress, required String text, int port = 9100}) async {
    return printThermalReceipt(ipAddress: ipAddress, text: text, port: port);
  }

  /// Print device label with ESC/POS commands
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
      bytes.addAll([esc, 0x74, 0x00]); // ESC t 0 - USA character set

      // Print header - Large and bold
      bytes.addAll([esc, 0x21, 0x30]); // ESC ! 48 - Double height & width, bold
      bytes.addAll(utf8.encode('JOB: ${labelData['jobNumber'] ?? 'N/A'}\n'));
      bytes.addAll([esc, 0x21, 0x00]); // ESC ! 0 - Reset to normal

      // Separator line
      bytes.addAll(utf8.encode('${'-' * 32}\n'));

      // Customer info
      bytes.addAll([esc, 0x21, 0x08]); // ESC ! 8 - Bold
      bytes.addAll(utf8.encode('Customer: '));
      bytes.addAll([esc, 0x21, 0x00]); // Normal
      bytes.addAll(utf8.encode('${labelData['customerName'] ?? 'N/A'}\n'));

      // Device info
      bytes.addAll([esc, 0x21, 0x08]); // Bold
      bytes.addAll(utf8.encode('Device: '));
      bytes.addAll([esc, 0x21, 0x00]); // Normal
      bytes.addAll(utf8.encode('${labelData['deviceName'] ?? 'N/A'}\n'));

      // IMEI
      bytes.addAll([esc, 0x21, 0x08]); // Bold
      bytes.addAll(utf8.encode('IMEI: '));
      bytes.addAll([esc, 0x21, 0x00]); // Normal
      bytes.addAll(utf8.encode('${labelData['imei'] ?? 'N/A'}\n'));

      // Defect
      bytes.addAll([esc, 0x21, 0x08]); // Bold
      bytes.addAll(utf8.encode('Defect: '));
      bytes.addAll([esc, 0x21, 0x00]); // Normal
      bytes.addAll(utf8.encode('${labelData['defect'] ?? 'N/A'}\n'));

      // Location
      bytes.addAll([esc, 0x21, 0x08]); // Bold
      bytes.addAll(utf8.encode('Location: '));
      bytes.addAll([esc, 0x21, 0x00]); // Normal
      bytes.addAll(utf8.encode('${labelData['location'] ?? 'N/A'}\n'));

      // Separator
      bytes.addAll(utf8.encode('${'-' * 32}\n'));

      // Center align for codes
      bytes.addAll([esc, 0x61, 0x01]); // ESC a 1 - Center alignment

      // Print Job ID
      bytes.addAll(utf8.encode('\nJob ID:\n'));
      bytes.addAll(utf8.encode('${labelData['jobId'] ?? 'N/A'}\n'));
      bytes.addAll(utf8.encode('\n${labelData['jobNumber'] ?? 'N/A'}\n'));

      // Reset alignment
      bytes.addAll([esc, 0x61, 0x00]); // ESC a 0 - Left alignment

      // Feed and cut
      bytes.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
      bytes.addAll([gs, 0x56, 0x00]); // GS V 0 - Cut paper

      // Step 3: Send commands
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();

      // Step 4: Wait for completion
      await Future.delayed(const Duration(milliseconds: 500));

      // Close connection
      await socket.close();

      return PrinterResult(success: true, message: 'Label printed successfully', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Print error: $e', code: -1);
    }
  }

  /// Image printing is not supported in this lightweight raw-TCP implementation.
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
  }) async {
    return PrinterResult(success: false, message: 'Image printing not supported', code: -2);
  }

  /// Check if the network printer is reachable by opening a TCP connection.
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

/// Simple result model returned by print methods
class PrinterResult {
  final bool success;
  final String message;
  final int code;

  PrinterResult({required this.success, required this.message, required this.code});
}

/// Printer reachability/status result
class PrinterStatus {
  final bool isConnected;
  final String message;
  final int code;

  PrinterStatus({required this.isConnected, required this.message, required this.code});
}
