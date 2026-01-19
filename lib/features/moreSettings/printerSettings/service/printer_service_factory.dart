
import 'brother_sdk_printer_service.dart';
import 'brother_printer_service.dart';
import 'epson_printer_service.dart';
import 'star_printer_service.dart';
import 'xprinter_printer_service.dart';
import 'dymo_printer_service.dart';
import 'usb_printer_service.dart';
import 'a4_network_printer_service.dart';
import 'thermal_receipt_printer_service.dart';
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
  static BasePrinterService getPrinterServiceForConfig(
    PrinterConfigModel config,
  ) {
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
    final supportedBrands = [
      'brother',
      'epson',
      'star',
      'xprinter',
      'dymo',
      'generic',
      'hp',
      'canon',
    ];
    return supportedBrands.contains(brand.toLowerCase());
  }

  /// Get list of supported brands
  static List<String> getSupportedBrands() {
    return [
      'Brother',
      'Epson',
      'Star',
      'Xprinter',
      'Dymo',
      'Generic',
      'HP',
      'Canon',
    ];
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
        final res = await sdk.printLabel(
          ipAddress: config.ipAddress,
          text: text,
          port: config.port ?? 9100,
        );
        if (res.success) return res;
        debugPrint(
          '⚠️ Brother SDK print failed: ${res.message} — trying raw TCP fallback',
        );
      } catch (e) {
        debugPrint('⚠️ Brother SDK threw: $e — trying raw TCP fallback');
      }

      // Try raw TCP implementation
      final raw = BrotherPrinterService();
      return await raw.printLabel(
        ipAddress: config.ipAddress,
        text: text,
        port: config.port ?? 9100,
      );
    }

    // Non-Brother: use configured service directly
    final svc = getPrinterServiceForConfig(config);
    return await svc.printLabel(
      ipAddress: config.ipAddress,
      text: text,
      port: config.port ?? 9100,
    );
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
        debugPrint(
          '⚠️ Brother SDK deviceLabel failed: ${res.message} — trying raw TCP fallback',
        );
      } catch (e) {
        debugPrint(
          '⚠️ Brother SDK deviceLabel threw: $e — trying raw TCP fallback',
        );
      }

      // Fallback to raw text based device label
      final raw = BrotherPrinterService();
      return await raw.printDeviceLabel(
        ipAddress: config.ipAddress,
        labelData: labelData,
        port: config.port ?? 9100,
      );
    }

    final svc = getPrinterServiceForConfig(config);
    return await svc.printDeviceLabel(
      ipAddress: config.ipAddress,
      labelData: labelData,
      port: config.port ?? 9100,
    );
  }

  /// Attempt to print label image with SDK first then text fallback.
  /// TD series printers will use raw TCP raster mode for proper QR code/label printing.
  static Future<PrinterResult> printLabelImageWithFallback({
    required PrinterConfigModel config,
    required Uint8List imageBytes,
  }) async {
    final brand = config.printerBrand.toLowerCase();
    if (brand == 'brother') {
      // Check if it's a TD series printer
      final modelString = config.printerModel?.toUpperCase() ?? '';
      final isTDPrinter = modelString.startsWith('TD-');

      if (isTDPrinter) {
        // TD printers: Use raw TCP service with raster image printing
        debugPrint(
          '🖨️ TD printer detected: using raw TCP raster mode for image printing',
        );
        final raw = BrotherPrinterService();
        return await raw.printLabelImage(
          ipAddress: config.ipAddress,
          imageBytes: imageBytes,
          port: config.port ?? 9100,
        );
      }

      // QL/PT series: Try SDK first
      final sdk = BrotherSDKPrinterService();
      try {
        final res = await sdk.printLabelImage(
          ipAddress: config.ipAddress,
          imageBytes: imageBytes,
          port: config.port ?? 9100,
        );
        if (res.success) return res;
        debugPrint(
          '⚠️ Brother SDK image print failed: ${res.message} — trying raw TCP fallback',
        );
      } catch (e) {
        debugPrint('⚠️ Brother SDK image threw: $e — trying raw TCP fallback');
      }

      // SDK failed, try raw TCP as fallback
      final raw = BrotherPrinterService();
      return await raw.printLabelImage(
        ipAddress: config.ipAddress,
        imageBytes: imageBytes,
        port: config.port ?? 9100,
      );
    }

    final svc = getPrinterServiceForConfig(config);
    return await svc.printLabelImage(
      ipAddress: config.ipAddress,
      imageBytes: imageBytes,
      port: config.port ?? 9100,
    );
  }

  /// Print thermal receipt as image (with logos, barcodes, QR codes)
  /// Supports Epson, Star, Xprinter and other ESC/POS thermal printers
  static Future<PrinterResult> printThermalReceiptImage({
    required PrinterConfigModel config,
    required Uint8List imageBytes,
  }) async {
    final brand = config.printerBrand.toLowerCase();

    debugPrint(
      '🖨️ [ThermalImage] Printing receipt image on $brand thermal printer',
    );

    // Use dedicated thermal receipt printer service (ESC/POS compatible)
    final thermalService = ThermalReceiptPrinterService();

    // Use paper width from config or default to 80mm
    final paperWidth = config.paperWidth ?? 80;

    return await thermalService.printThermalImage(
      ipAddress: config.ipAddress,
      imageBytes: imageBytes,
      port: config.port ?? 9100,
      paperWidth: paperWidth,
    );
  }

  /// Print raw ESC/POS bytes (pure commands, no image generation)
  /// This method sends raw ESC/POS commands directly to the printer
  /// Supports all ESC/POS compatible thermal printers
  static Future<PrinterResult> printRawEscPos({
    required PrinterConfigModel config,
    required List<int> escposBytes,
  }) async {
    debugPrint(
      '🖨️ [RawESCPOS] Printing ${escposBytes.length} bytes to ${config.printerBrand} thermal printer',
    );

    // Use dedicated thermal receipt printer service
    final thermalService = ThermalReceiptPrinterService();

    return await thermalService.printRawEscPos(
      ipAddress: config.ipAddress,
      escposBytes: escposBytes,
      port: config.port ?? 9100,
    );
  }
}
