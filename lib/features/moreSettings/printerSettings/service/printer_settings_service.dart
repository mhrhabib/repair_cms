import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import '../models/printer_config_model.dart';

class PrinterSettingsService {
  final GetStorage _storage = GetStorage();

  // Storage keys
  static const String _thermalPrintersKey = 'thermal_printers';
  static const String _labelPrintersKey = 'label_printers';
  static const String _a4PrintersKey = 'a4_printers';
  static const String _defaultThermalKey = 'default_thermal_id';
  static const String _defaultLabelKey = 'default_label_id';
  static const String _defaultA4Key = 'default_a4_id';

  // Save printer configuration
  Future<void> savePrinterConfig(PrinterConfigModel config) async {
    try {
      final key = _getStorageKey(config.printerType);
      List<dynamic> existingConfigs = _storage.read(key) ?? [];

      // Convert to list of PrinterConfigModel
      List<PrinterConfigModel> printers = existingConfigs
          .map((e) => PrinterConfigModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Find if config already exists (by IP address)
      final existingIndex = printers.indexWhere(
        (p) => p.ipAddress == config.ipAddress && p.printerBrand == config.printerBrand,
      );

      if (existingIndex != -1) {
        // Update existing
        printers[existingIndex] = config;
      } else {
        // Add new
        printers.add(config);
      }

      // If this is set as default, unset others
      if (config.isDefault) {
        printers = printers.map((p) {
          if (p.ipAddress == config.ipAddress && p.printerBrand == config.printerBrand) {
            return p;
          }
          return p.copyWith(isDefault: false);
        }).toList();

        // Save default printer ID
        final defaultKey = _getDefaultKey(config.printerType);
        await _storage.write(defaultKey, '${config.printerBrand}_${config.ipAddress}');
      }

      // Save updated list
      await _storage.write(key, printers.map((e) => e.toJson()).toList());

      debugPrint('✅ Saved ${config.printerType} printer: ${config.printerBrand}');
    } catch (e) {
      debugPrint('❌ Error saving printer config: $e');
      rethrow;
    }
  }

  // Get all printers of a specific type
  List<PrinterConfigModel> getPrinters(String printerType) {
    try {
      final key = _getStorageKey(printerType);
      List<dynamic> configs = _storage.read(key) ?? [];

      return configs.map((e) => PrinterConfigModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ Error loading printers: $e');
      return [];
    }
  }

  // Get default printer of a specific type
  PrinterConfigModel? getDefaultPrinter(String printerType) {
    try {
      final printers = getPrinters(printerType);
      if (printers.isEmpty) return null;

      return printers.firstWhere((p) => p.isDefault, orElse: () => printers.first);
    } catch (e) {
      debugPrint('❌ Error getting default printer: $e');
      return null;
    }
  }

  // Delete printer configuration
  Future<void> deletePrinterConfig(PrinterConfigModel config) async {
    try {
      final key = _getStorageKey(config.printerType);
      List<dynamic> existingConfigs = _storage.read(key) ?? [];

      List<PrinterConfigModel> printers = existingConfigs
          .map((e) => PrinterConfigModel.fromJson(e as Map<String, dynamic>))
          .toList();

      printers.removeWhere((p) => p.ipAddress == config.ipAddress && p.printerBrand == config.printerBrand);

      await _storage.write(key, printers.map((e) => e.toJson()).toList());

      debugPrint('✅ Deleted printer: ${config.printerBrand}');
    } catch (e) {
      debugPrint('❌ Error deleting printer: $e');
      rethrow;
    }
  }

  // Get all configured printers (for printer selection dialog)
  Map<String, List<PrinterConfigModel>> getAllPrinters() {
    return {'thermal': getPrinters('thermal'), 'label': getPrinters('label'), 'a4': getPrinters('a4')};
  }

  // Get thermal printer paper width for receipt printing
  int getThermalPaperWidth() {
    final printer = getDefaultPrinter('thermal');
    return printer?.paperWidth ?? 80; // Default to 80mm
  }

  // Get label printer dimensions for label printing
  LabelSize? getLabelSize() {
    final printer = getDefaultPrinter('label');
    return printer?.labelSize;
  }

  // Check if printer is configured
  bool isPrinterConfigured(String printerType) {
    return getDefaultPrinter(printerType) != null;
  }

  // Get printer config summary for display
  String getPrinterSummary(String printerType) {
    final printer = getDefaultPrinter(printerType);
    if (printer == null) return 'Not configured';

    String summary = printer.printerBrand;
    if (printer.printerModel != null) summary += ' ${printer.printerModel}';
    summary += ' @ ${printer.ipAddress}';

    if (printerType == 'thermal' && printer.paperWidth != null) {
      summary += ' (${printer.paperWidth}mm)';
    } else if (printerType == 'label' && printer.labelSize != null) {
      summary += ' (${printer.labelSize!.name})';
    }

    return summary;
  } // Helper methods

  String _getStorageKey(String printerType) {
    switch (printerType.toLowerCase()) {
      case 'thermal':
        return _thermalPrintersKey;
      case 'label':
        return _labelPrintersKey;
      case 'a4':
        return _a4PrintersKey;
      default:
        throw Exception('Unknown printer type: $printerType');
    }
  }

  String _getDefaultKey(String printerType) {
    switch (printerType.toLowerCase()) {
      case 'thermal':
        return _defaultThermalKey;
      case 'label':
        return _defaultLabelKey;
      case 'a4':
        return _defaultA4Key;
      default:
        throw Exception('Unknown printer type: $printerType');
    }
  }
}
