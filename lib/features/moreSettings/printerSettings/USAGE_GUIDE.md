# Printer Settings Usage Guide

## Overview
All printer settings are now **permanently saved** in local storage (GetStorage) and can be accessed from anywhere in the app, especially for receipt and label printing.

## Saved Settings

### Thermal Printer Settings
- ✅ Brand, Model
- ✅ IP Address & Port
- ✅ Protocol (TCP/USB)
- ✅ **Paper Width** (80mm or 58mm) - NEW!
- ✅ Default printer flag

### Label Printer Settings
- ✅ Brand, Model
- ✅ IP Address & Port
- ✅ Protocol (TCP/USB)
- ✅ **Label Size** (dimensions in mm) - NEW!
- ✅ Default printer flag

### A4 Printer Settings
- ✅ Brand, Model
- ✅ IP Address & Port
- ✅ Protocol (TCP/USB)
- ✅ Default printer flag

---

## How to Use Saved Settings

### 1. Get Default Printer Configuration

```dart
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';

final _settingsService = PrinterSettingsService();

// Get thermal printer
final thermalPrinter = _settingsService.getDefaultPrinter('thermal');
if (thermalPrinter != null) {
  print('IP: ${thermalPrinter.ipAddress}');
  print('Port: ${thermalPrinter.port}');
  print('Paper Width: ${thermalPrinter.paperWidth}mm'); // 80 or 58
}

// Get label printer
final labelPrinter = _settingsService.getDefaultPrinter('label');
if (labelPrinter != null) {
  print('IP: ${labelPrinter.ipAddress}');
  print('Label: ${labelPrinter.labelSize?.name}'); // e.g., "62x100"
  print('Width: ${labelPrinter.labelSize?.width}mm');
  print('Height: ${labelPrinter.labelSize?.height}mm');
}
```

### 2. Quick Helper Methods

```dart
// Check if printer is configured
bool hasThermalPrinter = _settingsService.isPrinterConfigured('thermal');
bool hasLabelPrinter = _settingsService.isPrinterConfigured('label');

// Get paper width for thermal receipts
int paperWidth = _settingsService.getThermalPaperWidth(); // Returns 80 or 58 (default 80)

// Get label dimensions for label printing
LabelSize? labelSize = _settingsService.getLabelSize();
if (labelSize != null) {
  print('Label: ${labelSize.width}mm × ${labelSize.height}mm');
}

// Get printer summary for display
String summary = _settingsService.getPrinterSummary('thermal');
// Returns: "Epson TM-T20II @ 192.168.1.100 (80mm)"
```

### 3. Using in Receipt Printing

```dart
Future<void> printReceipt(String jobId) async {
  final printer = _settingsService.getDefaultPrinter('thermal');
  
  if (printer == null) {
    showCustomToast('No thermal printer configured', isError: true);
    return;
  }
  
  // Use paper width to adjust receipt layout
  final paperWidth = printer.paperWidth ?? 80;
  final charsPerLine = paperWidth == 80 ? 48 : 32; // Adjust based on width
  
  // Print with correct settings
  await printToThermalPrinter(
    ipAddress: printer.ipAddress,
    port: printer.port ?? 9100,
    paperWidth: paperWidth,
    content: formatReceipt(jobId, charsPerLine),
  );
}
```

### 4. Using in Label Printing

```dart
Future<void> printLabel(String customerId, String jobId) async {
  final printer = _settingsService.getDefaultPrinter('label');
  
  if (printer == null) {
    showCustomToast('No label printer configured', isError: true);
    return;
  }
  
  final labelSize = printer.labelSize;
  if (labelSize == null) {
    showCustomToast('Label size not configured', isError: true);
    return;
  }
  
  // Use label dimensions to format content
  await printToLabelPrinter(
    ipAddress: printer.ipAddress,
    port: printer.port ?? 9100,
    labelWidth: labelSize.width,
    labelHeight: labelSize.height,
    content: formatLabel(customerId, jobId, labelSize),
  );
}
```

### 5. Brother Label Printer Example

```dart
import 'package:another_brother/label_info.dart';

Future<void> printBrotherLabel(String text) async {
  final printer = _settingsService.getDefaultPrinter('label');
  
  if (printer?.printerBrand != 'Brother') {
    return; // Not a Brother printer
  }
  
  // Map label size to Brother label type
  final labelSize = printer.labelSize;
  LabelName labelName;
  
  if (labelSize?.width == 62 && labelSize?.height == 100) {
    labelName = LabelName.W62;
  } else if (labelSize?.width == 102 && labelSize?.height == 152) {
    labelName = LabelName.W102;
  } else {
    labelName = LabelName.W62; // Default
  }
  
  final printerInfo = Printer()
    ..printerModel = Model.QL_820NWB
    ..ipAddress = printer.ipAddress
    ..labelName = labelName;
    
  // Print with correct label size
  await Printing.layoutPdf(
    onLayout: (format) => generateBrotherLabel(text, labelSize),
  );
}
```

---

## Available Label Sizes

### Brother Printers
- 62×100 mm (standard address label)
- 62×29 mm (small label)
- 102×152 mm (large shipping label)
- 102×51 mm (medium label)
- 29×90 mm (file folder label)

### Dymo Printers
- 54×101 mm (standard)
- 102×159 mm (large)
- 89×28 mm (address)
- 54×25 mm (small)

### Xprinter Printers
- 80×80 mm (standard)
- 80×60 mm (medium)
- 60×40 mm (small)
- 100×100 mm (large)

---

## Integration Points

### Current Files Using Printer Settings:
1. **receipt_screen.dart** - Reads printer configs for receipt printing
2. **brother_printer_service.dart** - Uses printer configs for Brother printers
3. **thermal_printer_screen.dart** - Saves thermal printer settings with paper width
4. **label_printer_screen.dart** - Saves label printer settings with label size

### Storage Keys:
- `thermal_printers` - List of thermal printer configs
- `label_printers` - List of label printer configs
- `a4_printers` - List of A4 printer configs
- `default_thermal_id` - Default thermal printer ID
- `default_label_id` - Default label printer ID
- `default_a4_id` - Default A4 printer ID

---

## Testing

1. **Configure Printer**:
   - Go to Settings → Printer Settings
   - Select printer type (Thermal/Label/A4)
   - Configure brand, model, IP, port
   - **Select paper width (thermal) or label size (label)**
   - Set as default
   - Save

2. **Verify Storage**:
   ```dart
   final storage = GetStorage();
   print(storage.read('thermal_printers'));
   print(storage.read('label_printers'));
   ```

3. **Use in Receipt/Label**:
   - Go to any job details
   - Click "Print Receipt" or "Print Label"
   - Settings will be loaded automatically
   - Receipt/label will be formatted based on saved paper/label size

---

## Important Notes

⚠️ **Paper Width Impact on Receipts**:
- 80mm paper → ~48 characters per line
- 58mm paper → ~32 characters per line
- Always check `paperWidth` before formatting receipts

⚠️ **Label Size Impact on Labels**:
- Different label sizes require different layout adjustments
- Brother printers need matching `LabelName` enum
- Always verify label dimensions before printing

✅ **Settings Persist Across App Restarts**:
- All settings saved to local storage
- Automatically loaded on app startup
- No need to re-configure after closing app
