# TD-4 Series Printer Crash Fix

## Problem
The app was crashing on Android when trying to print with Brother TD-4 series label printers (TD-4550DNWB, TD-4210D, TD-4410D, etc.).

## Root Cause
The Brother SDK (`brother_printer` package v0.2.6) **does not support TD-4 series printers**. The code was:

1. Detecting TD-4 printers correctly
2. Throwing an exception: "TD series printers require raw TCP mode"
3. **BUT** the exception wasn't being caught properly in the UI layer
4. This caused the app to crash instead of falling back to raw TCP mode

## Solution
Fixed the exception handling flow by ensuring all printer calls use the fallback mechanism:

### Changes Made

#### 1. **printer_service_factory.dart**
- Added new method: `printLabelImageWithFallback()`
- This method handles image printing with proper exception catching
- For TD series printers that don't support SDK, it returns a structured error instead of crashing
- Added `dart:typed_data` import for `Uint8List`

#### 2. **label_printer_screen.dart**
- Changed test print button to use `PrinterServiceFactory.printLabelWithFallback()`
- This ensures TD series printers automatically fall back to raw TCP
- Better error messages shown to user

#### 3. **job_device_label_screen.dart**
- Changed image printing to use `PrinterServiceFactory.printLabelImageWithFallback()`
- Added graceful fallback from image → text mode for TD printers
- Prevents crash when printing device labels with barcodes/QR codes

### How It Works Now

**For QL/PT Series Printers (SDK Supported):**
```
UI → printLabelWithFallback() 
   → Try BrotherSDKPrinterService 
   → ✅ Success (uses SDK)
```

**For TD Series Printers (SDK NOT Supported):**
```
UI → printLabelWithFallback() 
   → Try BrotherSDKPrinterService 
   → ❌ Throws exception (caught!)
   → Fallback to BrotherPrinterService (raw TCP)
   → ✅ Success (uses ESC/POS over TCP)
```

## Testing Recommendations

### On TD-4550DNWB (or any TD-4 series):
1. Open RepairCMS app
2. Go to **More Settings → Printer Settings → Label Printer**
3. Configure:
   - Brand: **Brother**
   - Model: **TD-4550DNWB**
   - IP: Your printer IP (e.g., 192.168.0.7)
   - Label Size: **62mm** (or match your actual labels)
   - **Use SDK**: Can be ON or OFF (both will work now)
4. Click **Test Print (Label)**
5. ✅ Should print successfully without crash

### Expected Console Output:
```
🛠️ Brother SDK — TD printer detected, SDK not supported - will use raw TCP fallback
⚠️ Brother SDK threw: Exception: TD series printers require raw TCP mode — trying raw TCP fallback
[BrotherRawTCP: 192.168.0.7] Starting Brother raw TCP print
[BrotherRawTCP: 192.168.0.7] ✅ Printed successfully (raw TCP)
```

## Files Modified
1. `/lib/features/moreSettings/printerSettings/service/printer_service_factory.dart`
2. `/lib/features/moreSettings/printerSettings/screens/label_printer_screen.dart`
3. `/lib/features/jobBooking/screens/job_device_label_screen.dart`

## Impact
- ✅ **No more crashes** on TD-4 series printers
- ✅ Automatic fallback to raw TCP when SDK doesn't support the printer
- ✅ Better error messages for users
- ✅ Works for both test prints and job label prints
- ⚠️ Note: TD series printers **cannot print images** via raw TCP, only text labels

## Additional Notes

### TD Series Limitations:
- Cannot print QR codes or barcodes via raw TCP (need SDK support)
- Best suited for text-based labels
- For full feature support, Brother would need to add TD series to their SDK

### Recommended Settings for TD-4 Printers:
- Use SDK checkbox: **OFF** (raw TCP mode)
- Label size: Match your physical labels (typically 62mm or 102mm roll)
- Protocol: **TCP**
- Port: **9100**

### If Still Having Issues:
1. Check printer is on the same network
2. Verify printer IP with `ping <ip-address>`
3. Check printer status (no errors on display)
4. Try printing a test page from printer's built-in menu
5. Check Debug Logs in app (More Settings → Debug Logs)

## Date
January 2, 2026
