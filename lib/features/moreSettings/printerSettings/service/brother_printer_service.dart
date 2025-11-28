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
