# Brother Printer Integration Guide

## Overview

This project now supports Brother TD-2D and TD-4D series label printers using the official **`another_brother`** SDK package from pub.dev.

## Supported Printer Models

### ✅ Officially Supported (Tested with another_brother SDK)

#### TD-2D Series (Desktop Label Printers)
- **TD-2030A** ✅
- **TD-2125N** ✅
- **TD-2125NWB** ✅
- **TD-2135N** ✅
- **TD-2135NWB** ✅

#### QL Series (Label Printers)
- QL-820NWB
- QL-1110NWB
- QL-700
- QL-800

#### PT Series (Label Makers)
- PT-P750W
- PT-P300BT

### ⚠️ May Work (Not Officially Listed)

#### TD-4D Series (Desktop Label Printers)
- TD-4210D
- TD-4410D
- TD-4420DN
- TD-4520DN
- TD-4550DNWB

**Note:** The TD-4D series models are included but may require testing as they're not explicitly listed in the `another_brother` package changelog. They use the TD_4550DNWB model enum from the SDK.

## Package Information

- **Package:** `another_brother: ^2.2.4`
- **Pub.dev:** https://pub.dev/packages/another_brother
- **GitHub:** https://github.com/CodeMinion/Another-Brother

## Important Limitations

### ⚠️ Real Devices Only
The `another_brother` SDK **ONLY works on REAL DEVICES**. It will NOT work on:
- iOS Simulator
- Android Emulator

For simulator testing, use the fallback `brother_printer_service.dart` which uses raw TCP printing.

### Platform Support
- ✅ **Android:** Bluetooth/BLE, WiFi, USB
- ✅ **iOS:** Bluetooth/BLE, WiFi
- ❌ **Windows/macOS/Linux:** Not supported

## Setup Instructions

### 1. Package Installation

The package is already added to `pubspec.yaml`:

```yaml
dependencies:
  another_brother: ^2.2.4
```

Run:
```bash
flutter pub get
```

### 2. Android Configuration

#### Minimum SDK Version
Set in `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 19  // Required by another_brother
    }
}
```

#### Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

### 3. iOS Configuration

#### Info.plist
Add to `ios/Runner/Info.plist`:

```xml
<!-- Brother Printer Section -->
<key>NSLocalNetworkUsageDescription</key>
<string>Looking for local tcp Bonjour service</string>

<key>NSBonjourServices</key>
<array>
    <string>_ipp._tcp</string>
    <string>_printer._tcp</string>
    <string>_pdl-datastream._tcp</string>
</array>

<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need BLE permission to connect to Brother printers</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>Need BLE permission to connect to Brother printers</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Need Location permission for printer discovery</string>
<!-- End Brother Printer Section -->
```

#### Xcode Configuration
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Build Settings
3. Set **"Allow non-modular includes in Framework Modules"** to **YES**

### 4. Apple Store Submission (iOS Only)

⚠️ **IMPORTANT:** If you plan to submit to the Apple App Store, you **MUST** obtain a PPID (Product Plan ID) from Brother.

**Request PPID here:** https://secure6.brother.co.jp/mfi/Top.aspx

Without it, Apple will reject your app with:
> "App has not been authorized by the accessory manufacturer to work with the MFi accessory"

## Usage

### Basic Example

```dart
import 'package:repair_cms/features/moreSettings/printerSettings/service/brother_sdk_printer_service.dart';

final printerService = BrotherSDKPrinterService();

// Print a label
final result = await printerService.printLabel(
  ipAddress: '192.168.1.100',
  modelString: 'TD-2135NWB',
  text: 'Order #12345\nCustomer: John Doe',
  labelWidth: 62,
  labelHeight: 100,
  isAutoCut: true,
);

if (result.success) {
  print('✅ Printed successfully');
} else {
  print('❌ Error: ${result.message}');
}
```

### Check Printer Status

```dart
final status = await printerService.getPrinterStatus(
  ipAddress: '192.168.1.100',
  modelString: 'TD-2135NWB',
);

if (status.isConnected) {
  print('✅ Printer ready');
} else {
  print('❌ ${status.message}');
}
```

### Print Image

```dart
final result = await printerService.printLabelImage(
  ipAddress: '192.168.1.100',
  modelString: 'TD-2135NWB',
  imageBytes: imageData, // Uint8List
  labelWidth: 62,
  labelHeight: 100,
  isAutoCut: true,
);
```

## File Structure

```
lib/features/moreSettings/printerSettings/
├── service/
│   ├── brother_sdk_printer_service.dart    # Main Brother SDK service (real devices)
│   ├── brother_printer_service.dart        # Fallback TCP service (simulator)
│   └── base_printer_service.dart           # Base interface
├── examples/
│   └── brother_printer_examples.dart       # Usage examples & test screen
└── screens/
    └── label_printer_screen.dart           # UI with TD-2D/TD-4D models
```

## Testing

### On Real Device
1. Connect your device to the same network as the printer
2. Use `BrotherSDKPrinterService` for actual printing
3. Run the test screen: `BrotherPrinterTestScreen`

### On Simulator
1. Use `BrotherPrinterService` (raw TCP) for basic testing
2. Limited functionality (no SDK features)

## Common Label Sizes

| Width (mm) | Height (mm) | Description |
|------------|-------------|-------------|
| 62         | 100         | Standard address label |
| 62         | 29          | Shipping label |
| 29         | 90          | Small label |
| 38         | 90          | Medium label |
| 102        | 0           | Continuous tape |

## Error Handling

The service provides detailed error codes:

```dart
switch (result.errorCode) {
  case ErrorCode.ERROR_PAPER_EMPTY:
    // Handle paper empty
    break;
  case ErrorCode.ERROR_COMMUNICATION_ERROR:
    // Handle network error
    break;
  case ErrorCode.ERROR_NOT_SAME_MODEL:
    // Handle model mismatch
    break;
  // ... more error codes
}
```

## Troubleshooting

### Printer Not Found
1. ✅ Verify printer IP address
2. ✅ Check network connectivity
3. ✅ Ensure printer is on same network
4. ✅ Try pinging the printer IP

### Model Not Supported Error
1. ✅ Check if model is in supported list
2. ✅ For TD-4D series, try TD-4550DNWB model string
3. ✅ Verify model string matches exactly (case-sensitive)

### iOS Simulator Issues
- ⚠️ SDK doesn't work on simulator
- Use `BrotherPrinterService` (TCP) for testing
- Test on real device for full functionality

### Communication Errors
1. ✅ Check firewall settings
2. ✅ Verify port 9100 is open
3. ✅ Ensure printer is in network mode
4. ✅ Check printer's WiFi/network settings

## Additional Resources

- **Another Brother Package:** https://pub.dev/packages/another_brother
- **Demo App:** https://github.com/CodeMinion/Demo-Another-Brother-Prime
- **Brother Developer Portal:** https://www.brother.com/en/gateway/dev
- **Brother PPID Request:** https://secure6.brother.co.jp/mfi/Top.aspx

## Questions?

For issues specific to:
- **This integration:** Check the examples in `brother_printer_examples.dart`
- **another_brother package:** https://github.com/CodeMinion/Another-Brother/issues
- **Brother SDK:** Brother developer support

---

**Last Updated:** 2025-12-31
**Package Version:** another_brother ^2.2.4
