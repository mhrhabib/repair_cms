import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'base_printer_service.dart';

/// Epson thermal printer service
class EpsonPrinterService implements BasePrinterService {
  static final EpsonPrinterService _instance = EpsonPrinterService._internal();
  factory EpsonPrinterService() => _instance;
  EpsonPrinterService._internal();

  @override
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Epson ESC/POS commands
      final List<int> commands = [];

      // Initialize printer
      commands.addAll([0x1B, 0x40]); // ESC @ - Initialize

      // Set character set (USA)
      commands.addAll([0x1B, 0x74, 0x00]); // ESC t 0

      // Add receipt text
      commands.addAll(utf8.encode(text));

      // Line feeds and cut
      commands.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
      commands.addAll([0x1D, 0x56, 0x42, 0x00]); // GS V B 0 - Full cut

      socket.add(Uint8List.fromList(commands));
      await socket.flush();
      socket.destroy();

      return PrinterResult(success: true, message: 'Epson receipt printed successfully', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Epson print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // Epson label printers use similar commands to thermal
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
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      final List<int> bytes = [];

      // Epson ESC/POS Commands
      const esc = 0x1B;
      const gs = 0x1D;

      // Initialize
      bytes.addAll([esc, 0x40]); // ESC @
      bytes.addAll([esc, 0x74, 0x00]); // ESC t 0 - USA charset

      // Header - Large and bold
      bytes.addAll([esc, 0x21, 0x30]); // ESC ! 48 - Double height & width, bold
      bytes.addAll(utf8.encode('JOB: ${labelData['jobNumber'] ?? 'N/A'}\n'));
      bytes.addAll([esc, 0x21, 0x00]); // Reset to normal

      // Separator
      bytes.addAll(utf8.encode('${'-' * 32}\n'));

      // Customer info
      bytes.addAll([esc, 0x21, 0x08]); // Bold
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
      bytes.addAll([esc, 0x61, 0x01]); // ESC a 1 - Center

      // Print Job ID
      bytes.addAll(utf8.encode('\nJob ID:\n'));
      bytes.addAll(utf8.encode('${labelData['jobId'] ?? 'N/A'}\n'));
      bytes.addAll(utf8.encode('\n${labelData['jobNumber'] ?? 'N/A'}\n'));

      // Reset alignment
      bytes.addAll([esc, 0x61, 0x00]); // ESC a 0 - Left

      // Feed and cut
      bytes.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
      bytes.addAll([gs, 0x56, 0x42, 0x00]); // GS V B 0 - Full cut

      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await socket.close();

      return PrinterResult(success: true, message: 'Epson label printed successfully', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Epson print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
  }) async {
    return PrinterResult(success: false, message: 'Epson image printing not supported', code: -2);
  }

  @override
  Future<PrinterStatus> getPrinterStatus({required String ipAddress, int port = 9100}) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 4));
      socket.destroy();
      return PrinterStatus(isConnected: true, message: 'Epson printer reachable', code: 0);
    } catch (e) {
      return PrinterStatus(isConnected: false, message: 'Epson printer not reachable: $e', code: -1);
    }
  }
}
