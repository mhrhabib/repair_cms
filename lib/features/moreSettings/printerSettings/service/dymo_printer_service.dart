import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'base_printer_service.dart';

/// Dymo label printer service
/// Note: Dymo printers use proprietary protocols and may require specific drivers.
/// This implementation provides basic ESC/POS compatibility for network-enabled Dymo models.
class DymoPrinterService implements BasePrinterService {
  static final DymoPrinterService _instance = DymoPrinterService._internal();
  factory DymoPrinterService() => _instance;
  DymoPrinterService._internal();

  @override
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Dymo printers may support basic ESC/POS for thermal models
      final List<int> commands = [];

      // Initialize printer
      commands.addAll([0x1B, 0x40]); // ESC @ - Initialize

      // Set character set
      commands.addAll([0x1B, 0x74, 0x00]); // ESC t 0 - USA

      // Add receipt text
      commands.addAll(utf8.encode(text));

      // Line feeds and cut
      commands.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
      commands.addAll([0x1D, 0x56, 0x42, 0x00]); // GS V B 0 - Full cut

      socket.add(Uint8List.fromList(commands));
      await socket.flush();
      socket.destroy();

      return PrinterResult(success: true, message: 'Dymo receipt printed successfully', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Dymo print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Dymo label printers use different command sets
      // For basic compatibility, try ESC/POS first
      final List<int> commands = [];

      // Initialize
      commands.addAll([0x1B, 0x40]); // ESC @

      // Set label size (approximate for standard labels)
      // This may need adjustment based on specific Dymo model
      commands.addAll([0x1D, 0x77, 0x02]); // GS w 2 - Label width approx 2 inches

      // Print text
      commands.addAll(utf8.encode(text));

      // Feed and cut
      commands.addAll([0x0A, 0x0A]); // Line feeds
      commands.addAll([0x1D, 0x56, 0x42, 0x00]); // GS V B 0 - Cut

      socket.add(Uint8List.fromList(commands));
      await socket.flush();
      await socket.close();

      return PrinterResult(success: true, message: 'Dymo label printed successfully', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Dymo label print error: $e', code: -1);
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
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      final List<int> bytes = [];

      // Dymo ESC/POS Commands (limited compatibility)
      const esc = 0x1B;
      const gs = 0x1D;

      // Initialize
      bytes.addAll([esc, 0x40]); // ESC @
      bytes.addAll([esc, 0x74, 0x00]); // ESC t 0 - USA charset

      // Set label width (adjust based on label size from settings)
      bytes.addAll([gs, 0x77, 0x02]); // GS w 2 - 2 inch width (adjustable)

      // Header - Bold
      bytes.addAll([esc, 0x21, 0x08]); // ESC ! 8 - Bold
      bytes.addAll(utf8.encode('JOB: ${labelData['jobNumber'] ?? 'N/A'}\n'));
      bytes.addAll([esc, 0x21, 0x00]); // Reset to normal

      // Separator
      bytes.addAll(utf8.encode('${'-' * 20}\n')); // Shorter for labels

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

      // Defect (truncated for label size)
      final defect = labelData['defect'] ?? 'N/A';
      final shortDefect = defect.length > 15 ? '${defect.substring(0, 12)}...' : defect;
      bytes.addAll([esc, 0x21, 0x08]); // Bold
      bytes.addAll(utf8.encode('Defect: '));
      bytes.addAll([esc, 0x21, 0x00]); // Normal
      bytes.addAll(utf8.encode('$shortDefect\n'));

      // Location (truncated)
      final location = labelData['location'] ?? 'N/A';
      final shortLocation = location.length > 15 ? '${location.substring(0, 12)}...' : location;
      bytes.addAll([esc, 0x21, 0x08]); // Bold
      bytes.addAll(utf8.encode('Location: '));
      bytes.addAll([esc, 0x21, 0x00]); // Normal
      bytes.addAll(utf8.encode('$shortLocation\n'));

      // Center align for codes
      bytes.addAll([esc, 0x61, 0x01]); // ESC a 1 - Center

      // Print Job ID (compact)
      bytes.addAll(utf8.encode('\n${labelData['jobNumber'] ?? 'N/A'}\n'));

      // Reset alignment
      bytes.addAll([esc, 0x61, 0x00]); // ESC a 0 - Left

      // Feed and cut
      bytes.addAll([0x0A, 0x0A]); // Line feeds
      bytes.addAll([gs, 0x56, 0x42, 0x00]); // GS V B 0 - Full cut

      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await socket.close();

      return PrinterResult(success: true, message: 'Dymo label printed successfully', code: 0);
    } catch (e) {
      return PrinterResult(success: false, message: 'Dymo print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
  }) async {
    // Dymo printers support image printing but require specific image formats
    // This is a placeholder - would need Dymo SDK or specific image processing
    return PrinterResult(success: false, message: 'Dymo image printing requires Dymo SDK', code: -2);
  }

  @override
  Future<PrinterStatus> getPrinterStatus({required String ipAddress, int port = 9100}) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 4));
      socket.destroy();
      return PrinterStatus(isConnected: true, message: 'Dymo printer reachable', code: 0);
    } catch (e) {
      return PrinterStatus(isConnected: false, message: 'Dymo printer not reachable: $e', code: -1);
    }
  }
}
