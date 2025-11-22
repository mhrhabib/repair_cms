import 'dart:ui' as ui;

import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import 'package:flutter/foundation.dart';

/// Service class to handle Brother printer operations
class BrotherPrinterService {
  static final BrotherPrinterService _instance = BrotherPrinterService._internal();
  factory BrotherPrinterService() => _instance;
  BrotherPrinterService._internal();

  /// Configure and print text to Brother label printer
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    Model? printerModel,
    bool isAutoCut = true,
    bool isEndCut = true,
  }) async {
    try {
      var printer = Printer();
      var printInfo = PrinterInfo();

      // Configure printer
      printInfo.printerModel = printerModel!;
      printInfo.port = Port.NET;
      printInfo.ipAddress = ipAddress;

      // Configure label
      var labelInfo = LabelInfo();
      labelInfo.labelNameIndex = QL700.ordinalFromID(QL700.W62.getId());
      labelInfo.isAutoCut = isAutoCut;
      labelInfo.isEndCut = isEndCut;
      printInfo.labelNameIndex = labelInfo.labelNameIndex;

      await printer.setPrinterInfo(printInfo);

      // Create Paragraph for printing
      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.left, fontSize: 12.0))
        ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF000000), fontSize: 12.0))
        ..addText(text);

      final paragraph = paragraphBuilder.build()..layout(const ui.ParagraphConstraints(width: 300));

      // Print text
      var result = await printer.printText(paragraph);
      return PrinterResult(
        success: result.errorCode == ErrorCode.ERROR_NONE,
        errorCode: result.errorCode,
        message: _getErrorMessage(result.errorCode),
      );
    } catch (e) {
      return PrinterResult(success: false, errorCode: ErrorCode.ERROR_BATTERY_EMPTY, message: 'Error: ${e.toString()}');
    }
  }

  /// Configure and print image to Brother label printer
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    Model? printerModel,
    bool isAutoCut = true,
    bool isEndCut = true,
  }) async {
    try {
      var printer = Printer();
      var printInfo = PrinterInfo();

      // Configure printer
      printInfo.printerModel = printerModel!;
      printInfo.port = Port.NET;
      printInfo.ipAddress = ipAddress;

      // Configure label
      var labelInfo = LabelInfo();
      labelInfo.labelNameIndex = QL700.ordinalFromID(QL700.W62.getId());
      labelInfo.isAutoCut = isAutoCut;
      labelInfo.isEndCut = isEndCut;

      await printer.setPrinterInfo(printInfo);

      // Print image - Convert Uint8List to ui.Image
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;

      var result = await printer.printImage(uiImage);
      return PrinterResult(
        success: result.errorCode == ErrorCode.ERROR_NONE,
        errorCode: result.errorCode,
        message: _getErrorMessage(result.errorCode),
      );
    } catch (e) {
      return PrinterResult(success: false, errorCode: ErrorCode.ERROR_BUFFER_FULL, message: 'Error: ${e.toString()}');
    }
  }

  /// Print thermal receipt (80mm)
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    Model? printerModel,
  }) async {
    try {
      var printer = Printer();
      var printInfo = PrinterInfo();

      // Configure printer for thermal printing
      printInfo.printerModel = printerModel!;
      printInfo.port = Port.NET;
      printInfo.ipAddress = ipAddress;

      // Configure for thermal paper
      var labelInfo = LabelInfo();
      labelInfo.labelNameIndex = QL700.ordinalFromID(QL700.W62.getId());

      await printer.setPrinterInfo(printInfo);

      // Print receipt - Create Paragraph for printing
      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.left, fontSize: 12.0))
        ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF000000), fontSize: 12.0))
        ..addText(text);

      final paragraph = paragraphBuilder.build()..layout(const ui.ParagraphConstraints(width: 300));

      var result = await printer.printText(paragraph);
      return PrinterResult(
        success: result.errorCode == ErrorCode.ERROR_NONE,
        errorCode: result.errorCode,
        message: _getErrorMessage(result.errorCode),
      );
    } catch (e) {
      return PrinterResult(success: false, errorCode: ErrorCode.ERROR_BATTERY_EMPTY, message: 'Error: ${e.toString()}');
    }
  }

  /// Get printer status
  Future<PrinterStatus> getPrinterStatus({required String ipAddress, required Model printerModel}) async {
    try {
      var printer = Printer();
      var printInfo = PrinterInfo();

      printInfo.printerModel = printerModel;
      printInfo.port = Port.NET;
      printInfo.ipAddress = ipAddress;

      await printer.setPrinterInfo(printInfo);

      var status = await printer.getPrinterStatus();

      return PrinterStatus(
        isConnected: status.errorCode == ErrorCode.ERROR_NONE,
        errorCode: status.errorCode,
        message: _getErrorMessage(status.errorCode),
      );
    } catch (e) {
      return PrinterStatus(isConnected: false, errorCode: ErrorCode.ERROR_CANCEL, message: 'Error: ${e.toString()}');
    }
  }

  /// Helper method to get user-friendly error messages
  String _getErrorMessage(ErrorCode errorCode) {
    switch (errorCode) {
      case ErrorCode.ERROR_NONE:
        return 'Success';
      case ErrorCode.ERROR_NOT_SAME_MODEL:
        return 'Printer model mismatch';
      case ErrorCode.ERROR_BROTHER_PRINTER_NOT_FOUND:
        return 'Printer not found on network';
      case ErrorCode.ERROR_PAPER_EMPTY:
        return 'Paper empty';
      case ErrorCode.ERROR_BATTERY_EMPTY:
        return 'Battery empty';
      case ErrorCode.ERROR_COMMUNICATION_ERROR:
        return 'Communication error';
      case ErrorCode.ERROR_OVERHEAT:
        return 'Printer overheated';
      case ErrorCode.ERROR_PAPER_JAM:
        return 'Paper jam detected';
      case ErrorCode.ERROR_HIGH_VOLTAGE_ADAPTER:
        return 'High voltage adapter error';
      case ErrorCode.ERROR_CHANGE_CASSETTE:
        return 'Change cassette';
      case ErrorCode.ERROR_FEED_OR_CASSETTE_EMPTY:
        return 'Feed or cassette empty';
      case ErrorCode.ERROR_SYSTEM_ERROR:
        return 'System error';
      case ErrorCode.ERROR_NO_CASSETTE:
        return 'No cassette';
      case ErrorCode.ERROR_WRONG_CASSETTE_DIRECT:
        return 'Wrong cassette';
      case ErrorCode.ERROR_CREATE_SOCKET_FAILED:
        return 'Failed to create socket connection';
      case ErrorCode.ERROR_CONNECT_SOCKET_FAILED:
        return 'Failed to connect to printer';
      default:
        return 'Unknown error occurred';
    }
  }
}

/// Result class for print operations
class PrinterResult {
  final bool success;
  final ErrorCode errorCode;
  final String message;

  PrinterResult({required this.success, required this.errorCode, required this.message});
}

/// Status class for printer connection
class PrinterStatus {
  final bool isConnected;
  final ErrorCode errorCode;
  final String message;

  PrinterStatus({required this.isConnected, required this.errorCode, required this.message});
}

/// Example usage class
class PrinterExamples {
  final BrotherPrinterService _printerService = BrotherPrinterService();

  /// Example: Print a simple label
  Future<void> printSimpleLabel(String ipAddress) async {
    final result = await _printerService.printLabel(
      ipAddress: ipAddress,
      text:
          '╔════════════════════╗\n'
          '║  ORDER #12345     ║\n'
          '║                   ║\n'
          '║  Customer: John   ║\n'
          '║  Date: 2025-11-10 ║\n'
          '╚════════════════════╝\n',
      printerModel: Model.TD_4550DNWB,
      isAutoCut: true,
    );

    if (result.success) {
      debugPrint('✅ Label printed successfully');
    } else {
      debugPrint('❌ Print failed: ${result.message}');
    }
  }

  /// Example: Print thermal receipt
  Future<void> printReceipt(String ipAddress, String receiptText) async {
    final result = await _printerService.printThermalReceipt(
      ipAddress: ipAddress,
      text: receiptText,
      printerModel: Model.QL_820NWB,
    );

    if (result.success) {
      debugPrint('✅ Receipt printed successfully');
    } else {
      debugPrint('❌ Print failed: ${result.message}');
    }
  }

  /// Example: Check printer status before printing
  Future<bool> checkPrinterBeforePrint(String ipAddress) async {
    final status = await _printerService.getPrinterStatus(ipAddress: ipAddress, printerModel: Model.TD_4550DNWB);

    if (status.isConnected) {
      debugPrint('✅ Printer is ready');
      return true;
    } else {
      debugPrint('❌ Printer not ready: ${status.message}');
      return false;
    }
  }

  /// Example: Print image label
  Future<void> printImageLabel(String ipAddress, Uint8List imageData) async {
    final result = await _printerService.printLabelImage(
      ipAddress: ipAddress,
      imageBytes: imageData,
      printerModel: Model.TD_4550DNWB,
      isAutoCut: true,
      isEndCut: true,
    );

    if (result.success) {
      debugPrint('✅ Image label printed successfully');
    } else {
      debugPrint('❌ Print failed: ${result.message}');
    }
  }
}
