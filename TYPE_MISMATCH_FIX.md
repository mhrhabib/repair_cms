# Bug Fix: Type Mismatch in Single Job Model

## Problem

**Error:**
```
❌ Error in getJobById: type 'String' is not a subtype of type 'Map<String, dynamic>'
📋 Stack trace: #0      new Defect.fromJson.<anonymous closure>
  at package:repair_cms/features/myJobs/models/single_job_model.dart:1050:49
```

**Root Cause:**
The API backend returns some array fields (`defect`, `condition`) as either:
- `List<String>` (just the values/IDs)
- `List<Map<String, dynamic>>` (full objects)

The model classes were **only** expecting `Map<String, dynamic>` format and would crash when receiving `String` values.

---

## Solution

Added **type-checking logic** to handle both string and map formats for backward compatibility. This allows the app to work with both legacy API responses and newer object-based responses.

### Pattern Applied:

```dart
json['field'].forEach((v) {
  // Handle both string and map formats
  if (v is Map<String, dynamic>) {
    list!.add(Class.fromJson(v));
  } else if (v is String) {
    // Create object from string value
    list!.add(Class(value: v));
  }
});
```

---

## Files Fixed

### 1. **Data.fromJson()** - Line 187
**Field:** `defect`
- Changed from always calling `Defect.fromJson(v)`
- Now checks if `v` is a Map or String
- Creates appropriate object based on type

**Before:**
```dart
if (json['defect'] != null) {
  defect = <Defect>[];
  json['defect'].forEach((v) {
    defect!.add(Defect.fromJson(v));  // ❌ Crashes if v is String
  });
}
```

**After:**
```dart
if (json['defect'] != null) {
  defect = <Defect>[];
  json['defect'].forEach((v) {
    // Handle both string and map formats for backward compatibility
    if (v is Map<String, dynamic>) {
      defect!.add(Defect.fromJson(v));
    } else if (v is String) {
      // If it's a string, create a Defect with just the ID
      defect!.add(Defect(sId: v));
    }
  });
}
```

### 2. **Defect.fromJson()** - Line 1046
**Field:** `defect` (nested, holds DefectItem objects)
- Changed from always calling `DefectItem.fromJson(v)`
- Now checks if `v` is a Map or String
- Creates appropriate DefectItem based on type

**Before:**
```dart
if (json['defect'] != null) {
  defect = <DefectItem>[];
  json['defect'].forEach((v) {
    defect!.add(DefectItem.fromJson(v));  // ❌ Crashes if v is String
  });
}
```

**After:**
```dart
if (json['defect'] != null) {
  defect = <DefectItem>[];
  json['defect'].forEach((v) {
    // Handle both string and map formats for backward compatibility
    if (v is Map<String, dynamic>) {
      defect!.add(DefectItem.fromJson(v));
    } else if (v is String) {
      // If it's a string, create a DefectItem with the value
      defect!.add(DefectItem(value: v));
    }
  });
}
```

### 3. **DeviceData.fromJson()** - Line 598
**Field:** `condition`
- Added type checking for Condition parsing
- Handles both Map and String formats

### 4. **Device.fromJson()** - Line 918
**Field:** `condition`
- Added type checking for Condition parsing
- Handles both Map and String formats

---

## Why This Works

### Type Safety at Runtime:
```dart
// Check actual type before parsing
if (v is Map<String, dynamic>) {
  // v is definitely a Map, safe to parse as JSON
  defect!.add(Defect.fromJson(v));
} else if (v is String) {
  // v is definitely a String, create object with value
  defect!.add(Defect(sId: v));
}
```

### Backward Compatibility:
- ✅ Works with legacy API returning `List<String>`
- ✅ Works with new API returning `List<Map<String, dynamic>>`
- ✅ No changes needed on API side
- ✅ No breaking changes to existing code

---

## Testing

To verify the fix works:

1. **Test with string values:**
   ```dart
   final json = {
     'defect': ['defect1', 'defect2', 'defect3']  // List<String>
   };
   ```

2. **Test with map values:**
   ```dart
   final json = {
     'defect': [
       {'_id': '123', 'value': 'defect1'},
       {'_id': '456', 'value': 'defect2'}
     ]  // List<Map>
   };
   ```

3. **Test with mixed values:**
   ```dart
   final json = {
     'defect': [
       'defect1',  // String
       {'_id': '456', 'value': 'defect2'}  // Map
     ]  // Mixed types
   };
   ```

All three scenarios now work without crashes.

---

## Related Issues Fixed

The same pattern was applied to:
- `Defect.condition` field
- `DeviceData.condition` field
- `Device.condition` field

This prevents similar type mismatch errors across the entire data model.

---

## Future Prevention

To prevent this type of issue in the future:

1. **API Documentation**: Clearly document expected types for each field
2. **Model Comments**: Add comments explaining acceptable types
3. **Validation**: Consider adding stricter validation with detailed error messages
4. **Type Hints**: Use typed lists consistently across backend and frontend

**Example improvement:**
```dart
/// Defect items - can be List<String> or List<Map<String, dynamic>>
List<DefectItem>? defect;
```

---

## Affected API Endpoint

The error occurs when calling the `getJobById` endpoint from the dashboard/job repository:
- **Endpoint**: `GET /api/jobs/{userId}/{jobId}`
- **Response Field**: `data.defect` and `data.condition`
- **Issue**: Inconsistent response format between API versions
