# Label Content Settings - Implementation Summary

## Problem
The Label Content Settings screen (`label_content_screen.dart`) had toggle switches to control what fields appear on device labels, but these settings were only stored in local state and never persisted. When users navigated to the Job Device Label screen (`job_device_label_screen.dart`) to print labels, all fields were always shown regardless of the user's settings.

## Solution
Implemented a persistent storage system for label content settings following the app's established patterns (similar to printer settings).

## Changes Made

### 1. Created Label Content Settings Service
**File**: `lib/features/moreSettings/labelContent/service/label_content_settings_service.dart`

**Features**:
- Singleton service using GetStorage for persistence
- `LabelContentSettings` model class with all toggle options
- Storage key: `label_content_settings`
- Methods:
  - `getSettings()` - Load saved settings or return defaults
  - `saveSettings(LabelContentSettings)` - Save settings to storage
  - `resetToDefaults()` - Reset to default configuration

**Settings Managed**:
- ✅ Show/Hide Tracking Portal QR Code
- ✅ Show/Hide Job QR Code  
- ✅ Show/Hide Barcode
- ✅ Show/Hide Job Number
- ✅ Show/Hide Customer Name
- ✅ Show/Hide Model/Brand
- ✅ Show/Hide Date
- ✅ Show/Hide Job Type
- ✅ Show/Hide Symptom/Defect
- ✅ Show/Hide Physical Location

---

### 2. Updated Label Content Settings Screen
**File**: `lib/features/moreSettings/labelContent/label_content_screen.dart`

**Changes**:
- Imported `LabelContentSettingsService`
- Added `_loadSettings()` method in `initState()` to load saved settings
- Added `_saveSettings()` method to persist changes to GetStorage
- Updated button row to include both "Save Settings" and "Test Print" buttons
- Auto-saves before test printing
- Shows success/error snackbars after saving

**UI Changes**:
```dart
// Before: Single "Test Print" button
// After: Two buttons side-by-side
[Save Settings] [Test Print]
```

---

### 3. Updated Job Device Label Screen
**File**: `lib/features/jobBooking/screens/job_device_label_screen.dart`

**Changes**:
- Imported `LabelContentSettingsService`
- Added `_labelSettings` field to store loaded settings
- Added `_loadLabelSettings()` method called in `initState()`
- Updated UI build method to conditionally show elements based on settings
- Updated `_captureLabelAsImage()` method to respect settings when generating print images
- Added `_buildInfoText()` helper method to build text fields based on settings
- Added `_getMonthName()` helper for date formatting

**Conditional Rendering**:
- Barcode: Only drawn if `showBarcode` is true
- Job Number: Only shown if `showJobNo` is true
- QR Code: Only drawn if `showJobQR` or `showTrackingPortalQR` is true
  - Uses tracking portal URL if `showTrackingPortalQR` is true
- Customer Name: Only in info text if `showCustomerName` is true
- Model/Brand: Only in info text if `showModelBrand` is true
- Date: Only shown if `showDate` is true (formatted as "DD MMM YYYY")
- Job Type: Only shown if `showJobType` is true
- Symptom/Defect: Only shown if `showSymptom` is true
- Physical Location: Only shown if `showPhysicalLocation` is true

**Print Image Generation**:
- Dynamic Y-position tracking as elements are drawn
- Only draws enabled elements (saves space on label)
- Maintains proper spacing and alignment
- Both screen preview and print output respect settings

---

## How It Works

### User Flow:
1. User navigates to **More Settings → Label Content**
2. User toggles fields on/off (preview updates in real-time)
3. User clicks **"Save Settings"** to persist changes
4. Settings are saved to GetStorage with key `label_content_settings`
5. When printing a label, the Job Device Label screen:
   - Loads settings from storage
   - Applies them to both UI preview and print image
   - Only shows/prints fields that are enabled

### Default Settings:
- Tracking Portal QR: **OFF**
- Job QR: **ON**
- Barcode: **ON**
- Job Number: **ON**
- Customer Name: **ON**
- Model/Brand: **ON**
- Date: **ON**
- Job Type: **ON**
- Symptom: **ON**
- Physical Location: **ON**

---

## Technical Details

### Storage Key
```dart
static const String _storageKey = 'label_content_settings';
```

### Model Structure
```dart
class LabelContentSettings {
  final bool showTrackingPortalQR;
  final bool showJobQR;
  final bool showBarcode;
  final bool showJobNo;
  final bool showCustomerName;
  final bool showModelBrand;
  final bool showDate;
  final bool showJobType;
  final bool showSymptom;
  final bool showPhysicalLocation;
  
  // + fromJson, toJson, copyWith methods
}
```

### Logging
Uses emoji-prefixed debug logging:
- 🏷️ Label content operations
- ✅ Successful saves
- ❌ Errors

---

## Testing Checklist

### Manual Testing:
1. ✅ Navigate to Label Content settings
2. ✅ Toggle various fields on/off
3. ✅ Click "Save Settings" - verify success snackbar
4. ✅ Close app completely (kill process)
5. ✅ Reopen app, navigate back to Label Content
6. ✅ Verify toggles are in saved state
7. ✅ Create a new job and navigate to label screen
8. ✅ Verify preview shows only enabled fields
9. ✅ Print label and verify physical output matches settings
10. ✅ Try different combinations of toggles

### Edge Cases:
- ✅ All fields disabled (empty label - not recommended but supported)
- ✅ Only QR codes enabled
- ✅ Only text fields enabled
- ✅ Tracking Portal QR vs Job QR toggle exclusivity

---

## Benefits

1. **Persistent Settings**: Survives app restarts
2. **Customizable Labels**: Users can hide irrelevant fields
3. **Print Efficiency**: Smaller labels use less paper/ink
4. **Consistent**: Settings apply to both preview and print
5. **Type Safe**: Strongly typed model with validation
6. **User Feedback**: Success/error messages guide users
7. **Follows Patterns**: Uses same approach as printer settings

---

## Files Modified

1. ✅ `lib/features/moreSettings/labelContent/service/label_content_settings_service.dart` - **NEW**
2. ✅ `lib/features/moreSettings/labelContent/label_content_screen.dart` - UPDATED
3. ✅ `lib/features/jobBooking/screens/job_device_label_screen.dart` - UPDATED

---

## Status: ✅ COMPLETE

All label content settings are now persistently saved and applied to both label previews and printed labels. Users have full control over what appears on their device labels.

---

## Future Enhancements (Optional)

- Add preset configurations (e.g., "Minimal", "Standard", "Full")
- Allow custom text/logo additions to labels
- Support for multiple label templates per printer
- Per-printer label content profiles
