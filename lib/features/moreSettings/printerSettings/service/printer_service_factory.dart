import 'brother_printer_service.dart';
import 'epson_printer_service.dart';
import 'star_printer_service.dart';
import 'xprinter_printer_service.dart';
import 'dymo_printer_service.dart';
import 'usb_printer_service.dart';
import 'a4_network_printer_service.dart';
import 'base_printer_service.dart';

/// Factory class to get the appropriate printer service based on brand
class PrinterServiceFactory {
  static BasePrinterService getPrinterService(String brand) {
    switch (brand.toLowerCase()) {
      case 'brother':
        return BrotherPrinterService();
      case 'epson':
        return EpsonPrinterService();
      case 'star':
        return StarPrinterService();
      case 'xprinter':
        return XprinterPrinterService();
      case 'dymo':
        return DymoPrinterService();
      default:
        // For unknown brands, try Brother as fallback (most compatible)
        return BrotherPrinterService();
    }
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
    final supportedBrands = ['brother', 'epson', 'star', 'xprinter', 'dymo'];
    return supportedBrands.contains(brand.toLowerCase());
  }

  /// Get list of supported brands
  static List<String> getSupportedBrands() {
    return ['Brother', 'Epson', 'Star', 'Xprinter', 'Dymo'];
  }
}
