import 'brother_sdk_printer_service.dart';
import 'brother_printer_service.dart';
import 'epson_printer_service.dart';
import 'star_printer_service.dart';
import 'xprinter_printer_service.dart';
import 'dymo_printer_service.dart';
import 'usb_printer_service.dart';
import 'a4_network_printer_service.dart';
import 'base_printer_service.dart';
import 'package:flutter/foundation.dart';
import '../models/printer_config_model.dart';

/// Factory class to get the appropriate printer service based on brand
class PrinterServiceFactory {
  static BasePrinterService getPrinterService(String brand) {
    switch (brand.toLowerCase()) {
      case 'brother':
        return BrotherSDKPrinterService();
      case 'epson':
        return EpsonPrinterService();
      case 'star':
        return StarPrinterService();
      case 'xprinter':
        return XprinterPrinterService();
      case 'dymo':
        return DymoPrinterService();
      case 'generic':
      case 'hp':
      case 'canon':
        // Generic A4 printers (HP, Canon, etc.) use A4NetworkPrinterService
        return A4NetworkPrinterService();
      default:
        // For unknown brands, try Brother as fallback (most compatible)
        return BrotherSDKPrinterService();
    }
  }

  /// Selects a printer service based on full `PrinterConfigModel`.
  /// For Brother printers this allows choosing between SDK and raw TCP implementations.
  static BasePrinterService getPrinterServiceForConfig(PrinterConfigModel config) {
    final brand = config.printerBrand.toLowerCase();
    if (brand == 'brother') {
      if ((config.useSdk ?? false)) {
        return BrotherSDKPrinterService();
      }
      return BrotherPrinterService();
    }

    return getPrinterService(config.printerBrand);
  }

  /// Get USB printer service (special case)
  static USBPrinterService getUSBPrinterService() {
    return USBPrinterService();
  }

  /// Get A4 network printer service (bypasses AirPrint)
  static A4NetworkPrinterService getA4NetworkPrinterService() {
    return A4NetworkPrinterService();
  }

  /// Check if a brand is supported
  static bool isBrandSupported(String brand) {
    final supportedBrands = ['brother', 'epson', 'star', 'xprinter', 'dymo', 'generic', 'hp', 'canon'];
    return supportedBrands.contains(brand.toLowerCase());
  }

  /// Get list of supported brands
  static List<String> getSupportedBrands() {
    return ['Brother', 'Epson', 'Star', 'Xprinter', 'Dymo', 'Generic', 'HP', 'Canon'];
  }

  /// Attempt to print a label using SDK first (if available) and fall back to raw TCP.
  static Future<PrinterResult> printLabelWithFallback({
    required PrinterConfigModel config,
    required String text,
  }) async {
    final brand = config.printerBrand.toLowerCase();
    // If Brother, try SDK first if available
    if (brand == 'brother') {
      final sdk = BrotherSDKPrinterService();
      try {
        final res = await sdk.printLabel(ipAddress: config.ipAddress, text: text, port: config.port ?? 9100);
        if (res.success) return res;
        debugPrint('⚠️ Brother SDK print failed: ${res.message} — trying raw TCP fallback');
      } catch (e) {
        debugPrint('⚠️ Brother SDK threw: $e — trying raw TCP fallback');
      }

      // Try raw TCP implementation
      final raw = BrotherPrinterService();
      return await raw.printLabel(ipAddress: config.ipAddress, text: text, port: config.port ?? 9100);
    }

    // Non-Brother: use configured service directly
    final svc = getPrinterServiceForConfig(config);
    return await svc.printLabel(ipAddress: config.ipAddress, text: text, port: config.port ?? 9100);
  }

  /// Attempt to print device label (structured data) with SDK first then raw fallback.
  static Future<PrinterResult> printDeviceLabelWithFallback({
    required PrinterConfigModel config,
    required Map<String, String> labelData,
  }) async {
    final brand = config.printerBrand.toLowerCase();
    if (brand == 'brother') {
      final sdk = BrotherSDKPrinterService();
      try {
        final res = await sdk.printDeviceLabel(
          ipAddress: config.ipAddress,
          labelData: labelData,
          port: config.port ?? 9100,
        );
        if (res.success) return res;
        debugPrint('⚠️ Brother SDK deviceLabel failed: ${res.message} — trying raw TCP fallback');
      } catch (e) {
        debugPrint('⚠️ Brother SDK deviceLabel threw: $e — trying raw TCP fallback');
      }

      // Fallback to raw text based device label
      final raw = BrotherPrinterService();
      return await raw.printDeviceLabel(ipAddress: config.ipAddress, labelData: labelData, port: config.port ?? 9100);
    }

    final svc = getPrinterServiceForConfig(config);
    return await svc.printDeviceLabel(ipAddress: config.ipAddress, labelData: labelData, port: config.port ?? 9100);
  }
}
