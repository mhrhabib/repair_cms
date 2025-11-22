# Job Receipt Preview Screen

## Overview
This screen displays a preview of the job receipt or device label after a job is successfully created, matching the Figma design specifications.

## Features

### 📱 Preview Modes
1. **A4 Receipt** - Full-page receipt with company logo, customer details, services, and terms
2. **Thermal Receipt** - Compact 80mm/58mm thermal receipt format
3. **Device Label** - Barcode label with QR code for device tracking

### 🎨 Design Components

#### Header (Dark Blue Background)
- Close button (top-left)
- "Receipt Preview" title (center)
- Print button (top-right)

#### Receipt Preview Content
- **Company Logo** - Placeholder for company branding
- **Customer Information** - Name, address, city, country
- **Job Header** - Job number, date, barcode
- **Device Details** - Brand, model, IMEI
- **Services List** - Service names and prices
- **Terms & Conditions** - Important notes and policies
- **QR Code** - For job tracking
- **Footer** - Company info and opening hours

#### Device Label Preview
- **Barcode** - Device IMEI in Code 128 format
- **QR Code** - Combined job ID and IMEI data
- **Device Info** - Address number, customer name, phone/IMEI
- **Status** - Current device status (e.g., "LCD-Defekt | BOX: 14C")

### 🔄 User Flow

```
Job Booking Flow (Step 14: Select Printer)
    ↓
User selects printer type (A4/Thermal/Label)
    ↓
Clicks "Create Job"
    ↓
Job created via API
    ↓
Files uploaded (if any)
    ↓
Navigate to Receipt Preview Screen ← YOU ARE HERE
    ↓
User can:
  - View receipt/label preview
  - Print to configured printer
  - Close and return to home
```

### 📋 Implementation Details

#### File Location
`lib/features/jobBooking/screens/job_receipt_preview_screen.dart`

#### Dependencies
```yaml
dependencies:
  qr_flutter: ^4.1.0        # QR code generation
  barcode_widget: ^2.0.4    # Barcode generation
  intl: ^0.18.1             # Date formatting
```

#### Constructor Parameters
```dart
JobReceiptPreviewScreen({
  required CreateJobResponse jobResponse,  // Job creation response
  required String printOption,             // 'A4 Receipt', 'Thermal Receipt', or 'Device Label'
})
```

#### Navigation
Called from `job_booking_select_printer_screen.dart` after successful job creation:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => JobReceiptPreviewScreen(
      jobResponse: jobCreateState.response,
      printOption: _selectedPrinterType,
    ),
  ),
);
```

### 🎯 Key Features

#### Dynamic Content Rendering
- **Conditional Display**: Shows receipt or label based on `printOption`
- **Data Mapping**: Extracts customer, device, and service data from `CreateJobResponse`
- **Null Safety**: Handles missing data gracefully with fallback values

#### Print Options Modal
Bottom sheet with two options:
1. **Device Label** - Print barcode label
2. **Job Receipt** - Print full receipt

Triggered by print button in header.

#### Responsive Design
- Uses `flutter_screenutil` for consistent sizing
- Adapts to different screen sizes
- Maintains Figma design proportions

### 🎨 Styling

#### Colors (from Figma)
- Background: `#3D4A6C` (Dark blue)
- Preview Container: `#FFFFFF` (White)
- Header Icons: White with 20% opacity background

#### Typography
- Headers: `AppTypography.fontSize16` (bold)
- Body Text: `AppTypography.fontSize12`
- Small Text: `AppTypography.fontSize10`

### 📊 Data Structure

#### Required Data from `CreateJobResponse`
```dart
jobResponse.data:
  - sId (Job ID)
  - model (Job number)
  - createdAt (Date)
  - services[] (Service list)
  - contact[0] (Customer details)
  - device[0] (Device information)
```

### 🖨️ Print Integration

#### Next Steps for Printing
1. Get saved printer settings from `PrinterSettingsService`
2. Based on printer type:
   - **Thermal**: Use paper width setting (80mm/58mm)
   - **Label**: Use label size setting (e.g., 62x100mm)
   - **A4**: Use system print dialog

Example:
```dart
final _settingsService = PrinterSettingsService();

void _printReceipt() {
  if (printOption == 'Thermal Receipt') {
    final printer = _settingsService.getDefaultPrinter('thermal');
    final paperWidth = printer?.paperWidth ?? 80;
    // Print with thermal printer...
  } else if (printOption == 'Device Label') {
    final printer = _settingsService.getDefaultPrinter('label');
    final labelSize = printer?.labelSize;
    // Print label with dimensions...
  }
}
```

### ✅ Testing Checklist

- [ ] Preview displays correctly for A4 Receipt
- [ ] Preview displays correctly for Thermal Receipt
- [ ] Preview displays correctly for Device Label
- [ ] Customer data populates correctly
- [ ] Device data populates correctly
- [ ] Services list shows all items
- [ ] Barcode generates from IMEI
- [ ] QR code generates from job ID
- [ ] Print options modal opens
- [ ] Close button returns to home
- [ ] Works with missing/null data
- [ ] Responsive on different screen sizes

### 🐛 Troubleshooting

#### Preview is blank
- Check if `jobResponse.data` is not null
- Verify customer/device/service arrays are populated
- Check console for data mapping errors

#### Barcode/QR code not showing
- Ensure IMEI/Job ID data is available
- Verify `barcode_widget` and `qr_flutter` packages installed
- Check barcode data format (Code 128 requires alphanumeric)

#### Navigation issues
- Verify `JobCreateCubit` state is `JobCreateCreated`
- Check `jobCreateState.response.data` is not null
- Ensure route replacement is working correctly

### 📝 Future Enhancements

- [ ] Add actual printing functionality
- [ ] Support for multiple receipt formats
- [ ] Email receipt option
- [ ] Save receipt as PDF
- [ ] Share receipt via social media
- [ ] Preview history/archive
- [ ] Custom receipt templates
- [ ] Multi-language support

### 🔗 Related Files

- `job_booking_select_printer_screen.dart` - Printer selection screen
- `create_job_request.dart` - Job data models
- `printer_settings_service.dart` - Printer configuration
- `printer_config_model.dart` - Printer settings model

---

**Created**: 2025-11-21  
**Last Updated**: 2025-11-21  
**Author**: AI Assistant  
**Status**: ✅ Complete
