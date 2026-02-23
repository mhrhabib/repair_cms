# Printer Troubleshooting Guide for Client

## Before Sending APK - What We've Improved

### 1. ✅ Connection Testing
- Added **"Test Connection"** button in printer settings
- Tests network connectivity before printing
- Shows specific error messages (timeout, refused, network issue)

### 2. ✅ Automatic Retry Logic
- **HP Printers**: Tries 3 different strategies, 2 full attempts = 6 total tries
- **Brother Printers**: 3 retry attempts with 2-second delays
- **Thermal Printers**: Enhanced error detection and reporting

### 3. ✅ Enhanced Error Messages
All error messages now include:
- What went wrong
- Specific troubleshooting steps
- Actionable suggestions

### 4. ✅ Remote Logging
- **Debug Logs** menu in More Settings
- Share logs via WhatsApp/Email/Telegram
- All print attempts are logged with timestamps

---

## Printer-Specific Fixes

### HP Printer (192.168.0.160) - "Initializes but doesn't print"

**What we fixed:**
- Added 3 fallback print strategies
- Added retry logic (6 total attempts)
- Enhanced connection handling

**Possible Issues:**
1. **Printer doesn't support PDF Direct Print**
   - Solution: Try different HP printer model/driver
   - Check printer settings: Enable "PDF Direct Print" or "Direct Print"

2. **Firewall blocking port 9100**
   - Solution: Disable firewall temporarily to test
   - Add exception for port 9100

3. **Printer in wrong mode**
   - Solution: Reset printer to factory defaults
   - Check printer control panel for "Network" or "Wireless" mode

**Test Steps:**
1. Open RepairCMS app
2. Go to More Settings → Printer Settings → A4 Printer
3. Click "Test Connection" button
4. If successful, try "Test Print"
5. Share Debug Logs if it fails

---

### Brother TD-2350D (192.168.0.149) - "No reaction"

**What we fixed:**
- Added TD-2350D model support (maps to TD-2130N driver)
- Added 3 retry attempts with delays
- Enhanced error messages

**Possible Issues:**
1. **Label size mismatch**
   - Solution: Check selected label size matches labels loaded in printer
   - Brother printers are very sensitive to label size settings
   
2. **Printer not in correct mode**
   - Check printer's USB switch - should be in "Auto" or "Network" position
   - Printer may be in USB-only mode

3. **IP address changed**
   - Print network configuration page from printer
   - Verify IP is still 192.168.0.149

4. **Brother SDK compatibility**
   - Try toggling "Use SDK" checkbox in label printer settings
   - SDK mode vs Raw TCP mode may work differently

**Test Steps:**
1. Open RepairCMS app
2. Go to More Settings → Printer Settings → Label Printer
3. Enter IP: 192.168.0.149
4. Select Brand: Brother, Model: TD-2350D
5. Select correct label size (check what's loaded in printer)
6. Click "Test Connection" - must succeed first
7. Click "Test Print (Label)"
8. Share Debug Logs showing the full error

---

### Brother TD-455DNWB (192.168.0.7) - "No reaction"

**What we fixed:**
- Added TD-455DNWB variant support
- Same retry and error enhancements as TD-2350D

**Possible Issues:**
- Same as TD-2350D above, plus:
- **Wrong IP subnet**: 192.168.0.7 is different subnet than other printers
  - Verify device and printer are on same network
  - Check router settings

**Test Steps:**
- Same as TD-2350D above, but use IP 192.168.0.7

---

## General Troubleshooting Steps

### Step 1: Test Network Connectivity
```
Settings → Printer Settings → Select Printer Type
Enter IP address → Click "Test Connection"
```

**Expected Results:**
- ✅ "Connection successful! Printer is reachable."
- ❌ "Connection failed: [specific reason]"

### Step 2: Use Debug Logs
```
More Settings → Debug Logs → Clear Old Logs
Try printing → Share Logs
```

**What to Look For in Logs:**
- `[PrinterIP: X.X.X.X] Starting...` - Print job initiated
- `Connection failed` / `timeout` - Network issue
- `Model mismatch` - Wrong printer model selected
- `Label size issue` - Size mismatch
- `✅ SUCCESS` - Print should work

### Step 3: Try Different Configurations

**For Brother Printers:**
1. Try with "Use SDK" enabled
2. Try with "Use SDK" disabled (Raw TCP mode)
3. Try different label sizes
4. Verify label size matches physical labels

**For HP Printer:**
1. Verify printer supports network printing
2. Check printer firmware is up to date
3. Try printing from another app (browser, PDF viewer)
4. Reset printer network settings

---

## Common Error Messages & Solutions

### "Connection failed: Timeout"
- **Cause**: Printer not reachable on network
- **Solution**: 
  1. Check printer power
  2. Verify IP address (print config page from printer)
  3. Check device WiFi connection
  4. Ping printer from another device

### "Connection refused"
- **Cause**: Port blocked or printer not listening
- **Solution**:
  1. Check port number (usually 9100)
  2. Disable firewall temporarily
  3. Check printer network settings

### "Model mismatch: [model] may not be supported"
- **Cause**: Brother SDK doesn't recognize model
- **Solution**:
  1. Try different compatible model (QL-820NWB, TD-2130N)
  2. Toggle "Use SDK" checkbox to use Raw TCP instead
  3. Update printer firmware

### "Label size issue"
- **Cause**: Selected size doesn't match loaded labels
- **Solution**:
  1. Check physical label size on roll
  2. Select matching size in app settings
  3. Try standard sizes (62mm × 100mm common)

### "Print failed after 3 attempts"
- **Cause**: Multiple possible issues
- **Solution**:
  1. Share Debug Logs for analysis
  2. Try Test Connection first
  3. Check all physical connections
  4. Restart printer

---

## Client Action Plan

### Before Testing:
1. ✅ Install new APK
2. ✅ Connect to same network as printers
3. ✅ Verify all printer IPs in app settings

### Testing Protocol:
For each printer:
1. **Test Connection** (must pass)
2. **Test Print** 
3. **Share Debug Logs** (regardless of success/failure)

### What to Send Back:
1. Debug Logs (use Share button in Debug Logs screen)
2. Photo of each printer's control panel
3. Network configuration page from each printer
4. Description of what happened vs what was expected

---

## Expected Improvements

With these changes, you should see:
1. ✅ Clear error messages (not just "failed")
2. ✅ Multiple retry attempts automatically
3. ✅ Connection test before printing
4. ✅ Detailed logs for remote diagnosis

Even if printing still fails, the logs will show exactly why and where it's failing, allowing us to provide a targeted fix.

---

## Contact Information

After testing, please share:
- Debug Logs (tap Share in Debug Logs screen)
- Screenshots of any error messages
- Which printer settings you used
- What happened when you pressed Test Print

This will allow us to diagnose the exact issue and provide a fix within hours instead of days.
