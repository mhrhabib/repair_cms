# Brother Printer Diagnostics & Testing Guide

## Changes Made (January 2, 2026)

### 1. Model Mapping Fixes
- **Added TD-2350D support**: Maps to `TD_2130N` driver (compatible model)
- **Fixed TD-455DNWB**: Added variant handling for `TD-4550DNWB` (typo protection)
- **Improved model detection**: Better fallback logic for TD series

### 2. Label Size Configuration
- Enhanced TD series label size mapping
- Added intelligent width-based selection (62mm for ≥60mm, 50mm for ≥50mm)
- Default to 62mm roll for TD series (most common)

### 3. Enhanced Debugging
- Added label size configuration logging
- PDF file verification before printing
- File size validation
- More detailed error messages
- Better error categorization (connection, model, label size)

## Testing Instructions

### For Brother TD-2350D (192.168.0.149)
1. **Verify printer settings in app:**
   - Model should be set to: `TD-2350D` or `TD-2350DA`
   - Label size: 62mm roll (recommended)
   
2. **Expected console output:**
   ```
   🛠️ Brother SDK — modelString=TD-2350D
   🛠️ Brother SDK — device: ip=192.168.0.149, source=BrotherDeviceSource.network, model=BRLMPrinterModelTD_2130N
   🛠️ Brother SDK — label size config: W62mm_Roll
   🛠️ Brother SDK — mapped to Brother labelSize: QLRollW62
   🛠️ Brother SDK — PDF file size: XXX bytes
   ✅ Brother SDK — printPDF completed successfully
   ```

### For Brother TD-4550DNWB (192.168.0.7)
1. **Verify printer settings:**
   - Model: `TD-4550DNWB` or `TD-455DNWB` (both work now)
   - Label size: 62mm roll or 102mm roll (depending on actual media)
   
2. **Expected console output:**
   ```
   🛠️ Brother SDK — modelString=TD-4550DNWB
   🛠️ Brother SDK — device: ip=192.168.0.7
   🛠️ Brother SDK — mapped to Brother labelSize: QLRollW62 (or QLRollW102)
   ✅ Brother SDK — printPDF completed successfully
   ```

## Common Issues & Solutions

### Issue: "Connection failed" error
**Solutions:**
- Verify printer IP address is correct
- Ensure printer is on same network as device
- Check port 9100 is open on printer
- Try pinging printer: `ping 192.168.0.149`

### Issue: "Unsupported printer model"
**Solutions:**
- Check printer model is correctly entered in settings
- Model string is case-insensitive but must match format (e.g., `TD-2350D`)
- App now handles variants like `TD-455DNWB` vs `TD-4550DNWB`

### Issue: "Invalid label size configuration"
**Solutions:**
- Set label size to match actual media in printer:
  - TD-2350D: typically 62mm roll
  - TD-4550DNWB: 62mm or 102mm roll
- If unsure, use 62mm as default (most common)

### Issue: Printer initializes but doesn't print
**Possible causes:**
- Wrong label size selected (doesn't match physical media)
- Printer in wrong mode (check printer LCD/settings)
- Media sensor needs calibration
- Try manual feed calibration on printer

## Physical Printer Checks

### Before Testing:
1. ✅ Printer powered on
2. ✅ Media (labels/roll) loaded correctly
3. ✅ Cover closed
4. ✅ No error lights on printer LCD
5. ✅ Printer on network (can be discovered by app)
6. ✅ Test print from printer menu works

### TD-2350D Specific:
- Check if printer is in "Editor Lite" mode vs standard mode
- Media sensor type: Gap/Black mark/Continuous
- Media width setting should match actual media

### TD-4550DNWB Specific:
- Check cutter mode (enabled/disabled)
- Media width: 4 inch (102mm) or 2.4 inch (62mm)
- Direct thermal mode selected

## Debugging Steps

1. **Enable verbose logging:**
   - Watch console output during print attempts
   - Look for emoji-prefixed messages: 🛠️ (setup), ✅ (success), ❌ (error)

2. **Test sequence:**
   ```
   Step 1: Check printer discovery
   Step 2: Verify printer status (getPrinterStatus)
   Step 3: Print simple text label
   Step 4: Check console for errors
   ```

3. **If printing fails:**
   - Note the exact error message
   - Check which step failed (PDF creation, SDK call, etc.)
   - Verify label size in config matches printer's physical media

## Next Steps If Issues Persist

### For TD-2350D:
- May need alternative driver model (try `TD_2130N`, `TD_2135N`, or `TD_2135NWB`)
- Check Brother SDK documentation for exact model support
- Consider firmware update on printer

### For TD-4550DNWB:
- Verify model enum `BRLMPrinterModelTD_4550DNWB` exists in brother_printer package
- May need package update if model not supported
- Check if printer requires specific network configuration

### HP Printer (192.168.0.160):
- HP printers may need different service implementation
- Consider using raw socket printing instead of PDF approach
- May require PCL or PostScript commands

## Additional Configuration Options

You can adjust these in printer settings:

```dart
// For testing, try different label sizes:
- QLRollW62 (62mm roll - most common for TD series)
- QLRollW50 (50mm roll)
- QLRollW102 (102mm roll - for TD-4550DNWB)
- QLDieCutW62H29 (die-cut labels)
```

## Success Criteria
- ✅ Printer discovered by app
- ✅ PDF generated successfully (check file size > 0)
- ✅ `printPDF` completes without exception
- ✅ Physical label prints from printer
- ✅ Print quality is acceptable

---

**Note:** Run the app in debug mode and monitor console output for detailed diagnostic information.
