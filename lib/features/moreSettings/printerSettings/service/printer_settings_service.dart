import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/printer_config_model.dart';

/// Service to manage printer settings storage and retrieval
class PrinterSettingsService {
  static final PrinterSettingsService _instance = PrinterSettingsService._internal();
  factory PrinterSettingsService() => _instance;
  PrinterSettingsService._internal();

  final storage = GetStorage();

  // Storage keys
  static const String _thermalPrinterKey = 'thermal_printer_config';
  static const String _labelPrinterKey = 'label_printer_config';
  static const String _a4PrinterKey = 'a4_printer_config';
  static const String _defaultPrinterTypeKey = 'default_printer_type';

  /// Save thermal printer configuration
  Future<void> saveThermalPrinter(PrinterConfigModel config) async {
    try {
      await storage.write(_thermalPrinterKey, config.toJson());
      debugPrint('🖨️ Thermal printer settings saved');
      debugPrint('   📍 IP: ${config.ipAddress}');
      debugPrint('   🖨️ Model: ${config.printerModel}');
    } catch (e) {
      debugPrint('❌ Failed to save thermal printer: $e');
      rethrow;
    }
  }

  /// Save label printer configuration
  Future<void> saveLabelPrinter(PrinterConfigModel config) async {
    try {
      await storage.write(_labelPrinterKey, config.toJson());
      debugPrint('🏷️ Label printer settings saved');
      debugPrint('   📍 IP: ${config.ipAddress}');
      debugPrint('   🖨️ Model: ${config.printerModel}');
    } catch (e) {
      debugPrint('❌ Failed to save label printer: $e');
      rethrow;
    }
  }

  /// Save A4 printer configuration
  Future<void> saveA4Printer(PrinterConfigModel config) async {
    try {
      await storage.write(_a4PrinterKey, config.toJson());
      debugPrint('📄 A4 printer settings saved');
      debugPrint('   📍 IP: ${config.ipAddress}');
      debugPrint('   🖨️ Model: ${config.printerModel}');
    } catch (e) {
      debugPrint('❌ Failed to save A4 printer: $e');
      rethrow;
    }
  }

  /// Get thermal printer configuration
  PrinterConfigModel? getThermalPrinter() {
    try {
      final data = storage.read(_thermalPrinterKey);
      if (data != null) {
        return PrinterConfigModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to load thermal printer: $e');
      return null;
    }
  }

  /// Get label printer configuration
  PrinterConfigModel? getLabelPrinter() {
    try {
      final data = storage.read(_labelPrinterKey);
      if (data != null) {
        return PrinterConfigModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to load label printer: $e');
      return null;
    }
  }

  /// Get A4 printer configuration
  PrinterConfigModel? getA4Printer() {
    try {
      final data = storage.read(_a4PrinterKey);
      if (data != null) {
        return PrinterConfigModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to load A4 printer: $e');
      return null;
    }
  }

  /// Set default printer type for receipts
  Future<void> setDefaultPrinterType(String printerType) async {
    try {
      await storage.write(_defaultPrinterTypeKey, printerType);
      debugPrint('✅ Default printer type set to: $printerType');
    } catch (e) {
      debugPrint('❌ Failed to set default printer type: $e');
      rethrow;
    }
  }

  /// Get default printer type
  String? getDefaultPrinterType() {
    return storage.read(_defaultPrinterTypeKey) as String?;
  }

  /// Get default printer configuration
  PrinterConfigModel? getDefaultPrinter() {
    final defaultType = getDefaultPrinterType();
    if (defaultType == null) return null;

    switch (defaultType) {
      case 'thermal':
        return getThermalPrinter();
      case 'label':
        return getLabelPrinter();
      case 'a4':
        return getA4Printer();
      default:
        return null;
    }
  }

  /// Check if any printer is configured
  bool hasConfiguredPrinter() {
    return getThermalPrinter()?.isConfigured == true ||
        getLabelPrinter()?.isConfigured == true ||
        getA4Printer()?.isConfigured == true;
  }

  /// Clear all printer settings
  Future<void> clearAllSettings() async {
    try {
      await storage.remove(_thermalPrinterKey);
      await storage.remove(_labelPrinterKey);
      await storage.remove(_a4PrinterKey);
      await storage.remove(_defaultPrinterTypeKey);
      debugPrint('🗑️ All printer settings cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear printer settings: $e');
      rethrow;
    }
  }
}
