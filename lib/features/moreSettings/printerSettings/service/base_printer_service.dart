import 'dart:typed_data';
import '../models/printer_config_model.dart';

/// Base printer service interface that all printer brands implement
abstract class BasePrinterService {
  /// Print thermal receipt
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  });

  /// Print label
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
    LabelSize? labelSize,
  });

  /// Print device label with formatted data
  Future<PrinterResult> printDeviceLabel({
    required String ipAddress,
    required Map<String, String> labelData,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
    LabelSize? labelSize,
  });

  /// Print image (if supported)
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
    LabelSize? labelSize,
  });

  /// Check printer status
  Future<PrinterStatus> getPrinterStatus({
    required String ipAddress,
    int port = 9100,
  });

  /// Print a border test to verify alignment
  Future<PrinterResult> printBorderTest({
    required String ipAddress,
    int port = 9100,
    LabelSize? labelSize,
  });

  /// Calibrate or feed the printer
  Future<PrinterResult> calibrate({required String ipAddress, int port = 9100});
}

/// Simple result model returned by print methods
class PrinterResult {
  final bool success;
  final String message;
  final int code;

  PrinterResult({
    required this.success,
    required this.message,
    required this.code,
  });
}

/// Printer reachability/status result
class PrinterStatus {
  final bool isConnected;
  final String message;
  final int code;

  PrinterStatus({
    required this.isConnected,
    required this.message,
    required this.code,
  });
}
