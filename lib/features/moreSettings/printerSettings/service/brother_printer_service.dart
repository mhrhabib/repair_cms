import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/set_up_di.dart';
import 'printer_settings_service.dart';

import 'base_printer_service.dart';

/// Lightweight network printer service (raw TCP/IPP) that works on the iOS simulator
/// Supports both raw TCP (port 9100) and IPP (port 631) protocols
/// This is intended as a simulator-friendly replacement for the device-only
/// `another_brother` SDK. For full ESC/POS features or label printing support you should integrate a
/// platform-specific plugin or add an ESC/POS utility package.
class BrotherPrinterService implements BasePrinterService {
  static final BrotherPrinterService _instance = BrotherPrinterService._internal();
  factory BrotherPrinterService() => _instance;
  BrotherPrinterService._internal();

  final _settingsService = PrinterSettingsService();
  Talker get _talker => SetUpDI.getIt<Talker>();

  @override
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // If port is 631, use IPP protocol
    if (port == 631) {
      return _printViaIPP(ipAddress, text, timeout);
    }

    // Otherwise use raw TCP/ESC-POS
    try {
      _talker.info('[BrotherRawTCP: $ipAddress] Starting Brother raw TCP print');

      // Get label size configuration
      final labelSize = _settingsService.getDefaultPrinter('label')?.labelSize;
      final labelWidth = labelSize?.width ?? 62; // Default to 62mm
      final labelHeight = labelSize?.height ?? 100; // Default to 100mm

      _talker.debug('[BrotherRawTCP] Label size: ${labelWidth}x${labelHeight}mm');

      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Build Brother-specific ESC/POS commands
      final List<int> bytes = [];

      // ESC/POS Commands
      const esc = 0x1B;
      const gs = 0x1D;

      // Initialize printer
      bytes.addAll([esc, 0x40]); // ESC @ - Initialize

      // Brother-specific: Set label mode (raster mode for labels)
      bytes.addAll([esc, 0x69, 0x61, 0x01]); // ESC i a 1 - Enable raster mode

      // Set media type (continuous roll with auto-cut)
      bytes.addAll([esc, 0x69, 0x7A, 0x00, 0x04]); // ESC i z - Media type

      // Set label width (in dots, 8 dots per mm for 203 DPI)
      final widthDots = (labelWidth * 8).toInt();
      bytes.addAll([esc, 0x69, 0x64, widthDots & 0xFF, (widthDots >> 8) & 0xFF]); // ESC i d

      // Set label height (in dots)
      final heightDots = (labelHeight * 8).toInt();
      bytes.addAll([esc, 0x69, 0x7A, heightDots & 0xFF, (heightDots >> 8) & 0xFF]); // ESC i z

      // Enable auto-cut
      bytes.addAll([esc, 0x69, 0x4B, 0x08]); // ESC i K - Auto-cut

      // Set print mode (high quality)
      bytes.addAll([esc, 0x69, 0x7A, 0x00, 0x00]); // Print quality

      // Auto status back settings
      bytes.addAll([gs, 0x61, 0xFF]); // GS a - Enable auto status

      // Print the text with proper encoding
      bytes.addAll(utf8.encode(text));

      // Add line feeds to ensure text is visible
      bytes.addAll([0x0A, 0x0A, 0x0A]);

      // Print command (form feed) to eject label
      bytes.addAll([0x0C]); // Form feed - eject and cut

      // Alternative: Use ESC i Z if form feed doesn't work
      bytes.addAll([esc, 0x69, 0x5A]); // ESC i Z - Print command

      _talker.debug('[BrotherRawTCP] Sending ${bytes.length} bytes to printer');
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for printer to process
      socket.destroy();

      _talker.info('[BrotherRawTCP: $ipAddress] ✅ Printed successfully (raw TCP)');
      return PrinterResult(success: true, message: 'Printed (raw TCP)', code: 0);
    } catch (e) {
      _talker.error('[BrotherRawTCP: $ipAddress] ❌ Print error: $e');
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
      _talker.info('[BrotherRawTCP: $ipAddress] Printing device label');
      // Step 1: Connect to printer
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Step 2: Build ESC/POS commands
      final List<int> bytes = [];

      // ESC/POS Commands
      const esc = 0x1B;
      // ignore: unused_local_variable
      const gs = 0x1D; // Reserved for future GS commands

      // Initialize printer
      bytes.addAll([esc, 0x40]); // ESC @ - Initialize

      // Set to standard mode
      bytes.addAll([esc, 0x69, 0x61, 0x00]); // ESC i a 0

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
      bytes.addAll([0x0A, 0x0A]);

      // Form feed to eject label
      bytes.addAll([0x0C]); // Form feed

      // Step 3: Send to printer
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      socket.destroy();

      _talker.info('[BrotherRawTCP: $ipAddress] ✅ Device label printed successfully');
      return PrinterResult(success: true, message: 'Device label printed successfully', code: 0);
    } catch (e) {
      _talker.error('[BrotherRawTCP: $ipAddress] ❌ Device label print error: $e');
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

  /// Print via IPP (Internet Printing Protocol) - Port 631
  /// More modern and reliable than raw TCP for many printers
  Future<PrinterResult> _printViaIPP(String ipAddress, String text, Duration timeout) async {
    try {
      _talker.info('[BrotherIPP: $ipAddress:631] Starting Brother IPP print');

      final socket = await Socket.connect(ipAddress, 631, timeout: timeout);

      // Build IPP Print-Job request
      final List<int> ippRequest = [];

      // IPP version 1.1, Print-Job operation
      ippRequest.addAll([0x01, 0x01]); // Version 1.1
      ippRequest.addAll([0x00, 0x02]); // Operation: Print-Job
      ippRequest.addAll([0x00, 0x00, 0x00, 0x01]); // Request ID

      // Operation attributes tag
      ippRequest.add(0x01);

      // attributes-charset
      ippRequest.add(0x47); // charset tag
      ippRequest.addAll([0x00, 0x12]); // name length
      ippRequest.addAll(utf8.encode('attributes-charset'));
      ippRequest.addAll([0x00, 0x05]); // value length
      ippRequest.addAll(utf8.encode('utf-8'));

      // attributes-natural-language
      ippRequest.add(0x48); // naturalLanguage tag
      ippRequest.addAll([0x00, 0x1b]); // name length
      ippRequest.addAll(utf8.encode('attributes-natural-language'));
      ippRequest.addAll([0x00, 0x05]); // value length
      ippRequest.addAll(utf8.encode('en-us'));

      // printer-uri
      ippRequest.add(0x45); // uri tag
      ippRequest.addAll([0x00, 0x0b]); // name length
      ippRequest.addAll(utf8.encode('printer-uri'));
      final printerUri = 'ipp://$ipAddress/ipp/print';
      final uriBytes = utf8.encode(printerUri);
      ippRequest.addAll([uriBytes.length >> 8, uriBytes.length & 0xFF]);
      ippRequest.addAll(uriBytes);

      // requesting-user-name
      ippRequest.add(0x42); // nameWithoutLanguage tag
      ippRequest.addAll([0x00, 0x14]); // name length
      ippRequest.addAll(utf8.encode('requesting-user-name'));
      final userName = utf8.encode('RepairCMS');
      ippRequest.addAll([0x00, userName.length]);
      ippRequest.addAll(userName);

      // job-name
      ippRequest.add(0x42); // nameWithoutLanguage tag
      ippRequest.addAll([0x00, 0x08]); // name length
      ippRequest.addAll(utf8.encode('job-name'));
      final jobName = utf8.encode('Label Print');
      ippRequest.addAll([0x00, jobName.length]);
      ippRequest.addAll(jobName);

      // document-format
      ippRequest.add(0x49); // mimeMediaType tag
      ippRequest.addAll([0x00, 0x0f]); // name length
      ippRequest.addAll(utf8.encode('document-format'));
      final docFormat = utf8.encode('text/plain');
      ippRequest.addAll([0x00, docFormat.length]);
      ippRequest.addAll(docFormat);

      // End of attributes
      ippRequest.add(0x03);

      // Add the actual print data
      final textBytes = utf8.encode(text);
      ippRequest.addAll(textBytes);

      _talker.debug('[BrotherIPP] Sending ${ippRequest.length} bytes IPP request');

      socket.add(Uint8List.fromList(ippRequest));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for printer response
      socket.destroy();

      _talker.info('[BrotherIPP: $ipAddress:631] ✅ Printed successfully (IPP)');
      return PrinterResult(success: true, message: 'Printed (IPP)', code: 0);
    } catch (e) {
      _talker.error('[BrotherIPP: $ipAddress:631] ❌ IPP print error: $e');
      return PrinterResult(success: false, message: 'IPP print error: $e', code: -1);
    }
  }
}
