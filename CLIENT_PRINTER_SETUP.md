# Client Printer Setup Guide

## Your Printers

### 1. Brother TD-2350D
- **IP Address**: 192.168.0.149
- **Model**: TD-2350D (Desktop Label Printer)
- **Status**: ✅ Fully Supported

### 2. Brother TD-455DNWB (TD-4550DNWB)
- **IP Address**: 192.168.0.7
- **Model**: TD-455DNWB / TD-4550DNWB
- **Status**: ✅ Fully Supported

---

## Setup Instructions

### Brother TD-2350D (192.168.0.149)

#### Step 1: Add Printer in App
1. Open RepairCMS app
2. Go to: **More Settings** → **Printer Settings** → **Label Printer**
3. Click **"Add Printer"** or **"+"** button

#### Step 2: Configure Settings
```
Printer Type:     Label
Brand:            Brother
Model:            TD-2350D           ← Select from dropdown
IP Address:       192.168.0.149
Port:             9100
Protocol:         TCP
Use SDK:          ☐ UNCHECKED        ← IMPORTANT: Keep this OFF
Set as Default:   ☑ CHECKED          ← If this is your main printer
```

#### Step 3: Select Label Size
**Check your physical labels first!** Common TD-2350D sizes:
- ✅ **62mm × 100mm** (continuous roll) - Most common
- ✅ **62mm × 29mm** (die-cut address labels)
- ✅ **51mm × 26mm** (small labels)
- ✅ **62mm × 150mm** (shipping labels)

**Important**: The label size in the app **MUST match exactly** what's loaded in your printer!

#### Step 4: Save & Test
1. Click **"Save"**
2. Click **"Test Print (Label)"**
3. Printer should feed a label with "RepairCMS Label Test"

---

### Brother TD-455DNWB / TD-4550DNWB (192.168.0.7)

#### Step 1: Add Printer in App
1. Go to: **More Settings** → **Printer Settings** → **Label Printer**
2. Click **"Add Printer"** or **"+"** button

#### Step 2: Configure Settings
```
Printer Type:     Label
Brand:            Brother
Model:            TD-455DNWB         ← Select this (or TD-4550DNWB)
IP Address:       192.168.0.7
Port:             9100
Protocol:         TCP
Use SDK:          ☐ UNCHECKED        ← CRITICAL: Must be OFF for TD-4 series
Set as Default:   ☐ UNCHECKED        ← Or checked if main printer
```

#### Step 3: Select Label Size
**Check your physical labels!** Common TD-4 series sizes:
- ✅ **102mm × 150mm** (4" × 6" shipping labels) - Most common
- ✅ **102mm × 152mm** (4" × 6" variant)
- ✅ **102mm × 51mm** (4" × 2" labels)
- ✅ **62mm × 100mm** (2.4" continuous)

**Important**: TD-4 series printers are very sensitive to label size!

#### Step 4: Save & Test
1. Click **"Save"**
2. Click **"Test Print (Label)"**
3. Should print successfully

---

## Important Notes

### Why "Use SDK" Must Be OFF

**TD Series Printers (TD-2350D, TD-4550DNWB):**
- Brother's SDK **does NOT support** TD series printers
- App automatically uses **Raw TCP mode** (direct ESC/POS commands)
- This is more reliable and works on both iOS & Android
- Keep **"Use SDK" checkbox UNCHECKED** ☐

**QL Series Printers (QL-820NWB, QL-1110NWB):**
- SDK works well with QL series
- You can use either SDK or Raw TCP mode
- SDK provides better quality for QL printers

### Label Size is Critical!

If printer **starts but doesn't print**:
1. ❌ **Wrong label size** - Most common issue
2. ❌ **Labels not loaded** - Check physical labels
3. ❌ **Sensor not calibrated** - See calibration below

**Match exactly**: App size = Physical labels in printer

---

## Calibration Guide

### TD-2350D Calibration
If printer activates but nothing comes out:

1. **Turn off** printer
2. **Hold Feed button** while turning printer ON
3. Keep holding until green light blinks
4. Release - printer feeds several labels (calibrating)
5. **Try printing again**

### TD-455DNWB / TD-4550DNWB Calibration
If no labels print:

1. Open printer cover
2. **Press and hold Feed button** for 5 seconds
3. Printer LCD shows "Sensor Calibration"
4. Close cover
5. Press **Feed** again
6. Printer auto-calibrates
7. **Try printing again**

---

## Troubleshooting

### TD-2350D (192.168.0.149)

#### ✅ Connection Good, But No Output?
**Most likely: Label size mismatch**

**Solution**:
1. Check physical labels in printer
2. Go to printer settings in app
3. Change label size to match (try 62x100, 62x29, 51x26)
4. Save
5. Test print again

#### ✅ Printer Not Found?
1. Verify IP: 192.168.0.149
2. Ping test: `ping 192.168.0.149`
3. Check printer is on same WiFi network
4. Check printer display - should show IP address
5. Print network config page from printer menu

#### ✅ Prints But Wrong Size/Cut Off?
1. Label size mismatch - adjust in settings
2. Run media sensor calibration
3. Try different label size options

---

### TD-455DNWB (192.168.0.7)

#### ✅ Connection Good, But No Output?
**TD-4 series is VERY sensitive to label size!**

**Solution**:
1. Check physical label width (likely 102mm / 4")
2. Measure label height (usually 150mm or 152mm)
3. In app settings, select: **102mm × 150mm** or **102mm × 152mm**
4. **CRITICAL**: Verify "Use SDK" is ☐ **UNCHECKED**
5. Save and test

#### ✅ "SDK Not Supported" Error?
**This is normal for TD-4 series!**
- Uncheck "Use SDK" in settings
- App will use Raw TCP mode automatically
- Should work perfectly after this

#### ✅ App Crashes When Printing?
**Already fixed!**
- Make sure app is updated to latest version
- Ensure "Use SDK" is OFF
- If still crashes, check Debug Logs in app

---

## Quick Test Checklist

### For Both Printers:
- [ ] Printer powered on
- [ ] Connected to same network as phone/tablet
- [ ] Correct IP address entered
- [ ] Port is 9100
- [ ] Protocol is TCP
- [ ] **"Use SDK" is UNCHECKED** ☐
- [ ] Label size matches physical labels
- [ ] Labels loaded correctly in printer
- [ ] Test print works

---

## Recommended Label Sizes

### TD-2350D Common Use Cases:
| Use Case | Label Size | Notes |
|----------|-----------|-------|
| Device repair tags | 62mm × 100mm | Most common |
| Address labels | 62mm × 29mm | Die-cut |
| Small item tags | 51mm × 26mm | Small die-cut |
| Shipping info | 62mm × 150mm | Larger labels |

### TD-455DNWB Common Use Cases:
| Use Case | Label Size | Notes |
|----------|-----------|-------|
| Shipping labels | 102mm × 150mm | 4" × 6" standard |
| Large device tags | 102mm × 152mm | 4" × 6" variant |
| Shelf labels | 102mm × 51mm | 4" × 2" |
| ID badges | 102mm × 76mm | Badge size |

---

## Expected Console Output (for debugging)

### Successful Print:
```
🛠️ Brother SDK — TD printer detected, SDK not supported - will use raw TCP fallback
⚠️ Brother SDK threw: Exception: TD series printers require raw TCP mode — trying raw TCP fallback
[BrotherRawTCP: 192.168.0.149] Starting Brother raw TCP print
[BrotherRawTCP] Label size: 62x100mm
[BrotherRawTCP] Sending 234 bytes to printer
[BrotherRawTCP: 192.168.0.149] ✅ Printed successfully (raw TCP)
```

### Label Size Issue:
```
❌ All 3 attempts failed
LABEL SIZE MISMATCH: Selected label size (62x29) does not match labels in printer
```

---

## Support

If issues persist:
1. Check **Debug Logs** in More Settings
2. Try **different label sizes** one by one
3. **Calibrate media sensor** on printer
4. Verify printer firmware is up to date
5. Test with Brother's official iPrint&Label app to confirm printer works

---

## Summary for Your Client

### TD-2350D (192.168.0.149)
✅ Model supported
✅ Select "TD-2350D" from dropdown
✅ Use Raw TCP mode (SDK OFF)
✅ Common size: 62mm × 100mm
✅ Calibrate if needed

### TD-455DNWB (192.168.0.7)
✅ Model supported (shows as TD-455DNWB or TD-4550DNWB)
✅ Select "TD-455DNWB" from dropdown
✅ **MUST** use Raw TCP mode (SDK OFF)
✅ Common size: 102mm × 150mm
✅ Calibrate if needed

Both printers will work **perfectly** once configured correctly! 🎉

Date: January 2, 2026
