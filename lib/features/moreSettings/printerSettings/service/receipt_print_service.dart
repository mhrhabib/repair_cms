import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import '../models/printer_config_model.dart';
import 'printer_settings_service.dart';

/// Service for printing receipts using configured printers
class ReceiptPrintService {
  static final ReceiptPrintService _instance = ReceiptPrintService._internal();
  factory ReceiptPrintService() => _instance;
  ReceiptPrintService._internal();

  final _settingsService = PrinterSettingsService();

  /// Print receipt using default printer
  Future<PrintResult> printReceipt(String receiptText) async {
    final defaultPrinter = _settingsService.getDefaultPrinter();

    if (defaultPrinter == null || !defaultPrinter.isConfigured) {
      return PrintResult(
        success: false,
        message: 'No default printer configured. Please configure a printer in settings.',
      );
    }

    return await _printWithConfig(defaultPrinter, receiptText);
  }

  /// Print receipt using specific printer type
  Future<PrintResult> printWithPrinterType(String printerType, String receiptText) async {
    PrinterConfigModel? config;

    switch (printerType) {
      case 'thermal':
        config = _settingsService.getThermalPrinter();
        break;
      case 'label':
        config = _settingsService.getLabelPrinter();
        break;
      case 'a4':
        config = _settingsService.getA4Printer();
        break;
      default:
        return PrintResult(success: false, message: 'Invalid printer type: $printerType');
    }

    if (config == null || !config.isConfigured) {
      return PrintResult(success: false, message: 'Printer not configured. Please configure the printer in settings.');
    }

    return await _printWithConfig(config, receiptText);
  }

  /// Internal method to print with a specific configuration
  Future<PrintResult> _printWithConfig(PrinterConfigModel config, String receiptText) async {
    try {
      debugPrint('🖨️ Starting print job');
      debugPrint('   Type: ${config.printerType}');
      debugPrint('   Model: ${config.printerModel}');
      debugPrint('   IP: ${config.ipAddress}');

      var printer = Printer();
      var printInfo = PrinterInfo();

      // Configure printer based on model
      printInfo.printerModel = _getPrinterModel(config.printerModel);
      printInfo.port = Port.NET;
      printInfo.ipAddress = config.ipAddress!;

      // Set label info
      var labelInfo = LabelInfo();
      labelInfo.labelNameIndex = QL700.ordinalFromID(QL700.W62.getId());

      // For label printers, enable auto-cut
      if (config.printerType == 'label') {
        labelInfo.isAutoCut = true;
        labelInfo.isEndCut = true;
      }

      await printer.setPrinterInfo(printInfo);

      // Create Paragraph for printing
      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.left, fontSize: 12.0))
        ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF000000), fontSize: 12.0))
        ..addText(receiptText);

      final paragraph = paragraphBuilder.build()..layout(const ui.ParagraphConstraints(width: 300));

      // Send print job
      var printResult = await printer.printText(paragraph);

      if (printResult.errorCode == ErrorCode.ERROR_NONE) {
        debugPrint('✅ Print job completed successfully');
        return PrintResult(success: true, message: 'Receipt printed successfully!');
      } else {
        debugPrint('❌ Print failed: ${printResult.errorCode}');
        return PrintResult(success: false, message: 'Print failed: ${_getErrorMessage(printResult.errorCode)}');
      }
    } catch (e) {
      debugPrint('❌ Print error: $e');
      return PrintResult(success: false, message: 'Print error: ${e.toString()}');
    }
  }

  /// Get printer model from string
  Model _getPrinterModel(String? modelName) {
    if (modelName == null) return Model.QL_820NWB;

    // Map printer names to models
    if (modelName.contains('QL-820NWB') || modelName.contains('QL_820NWB')) {
      return Model.QL_820NWB;
    } else if (modelName.contains('TD-4550DNWB') || modelName.contains('TD_4550DNWB')) {
      return Model.TD_4550DNWB;
    }

    // Default to QL-820NWB for thermal printers
    return Model.QL_820NWB;
  }

  /// Get user-friendly error message
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
      case ErrorCode.ERROR_CREATE_SOCKET_FAILED:
        return 'Failed to create socket connection';
      case ErrorCode.ERROR_CONNECT_SOCKET_FAILED:
        return 'Failed to connect to printer';
      default:
        return 'Unknown error occurred';
    }
  }

  /// Check if a default printer is configured
  bool hasDefaultPrinter() {
    final defaultPrinter = _settingsService.getDefaultPrinter();
    return defaultPrinter != null && defaultPrinter.isConfigured;
  }

  /// Get available configured printers
  List<PrinterConfigModel> getConfiguredPrinters() {
    final printers = <PrinterConfigModel>[];

    final thermal = _settingsService.getThermalPrinter();
    if (thermal != null && thermal.isConfigured) {
      printers.add(thermal);
    }

    final label = _settingsService.getLabelPrinter();
    if (label != null && label.isConfigured) {
      printers.add(label);
    }

    final a4 = _settingsService.getA4Printer();
    if (a4 != null && a4.isConfigured) {
      printers.add(a4);
    }

    return printers;
  }
}

/// Result class for print operations
class PrintResult {
  final bool success;
  final String message;

  PrintResult({required this.success, required this.message});
}
