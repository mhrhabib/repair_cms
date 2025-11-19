# Print Profiling Console Output Examples

## Overview
The printer profiling system logs detailed information about what **should** happen versus what **is actually** happening during print operations. This helps debug printer connectivity and configuration issues.

---

## Example 1: Successful Print from Receipt Screen

When you print a receipt successfully, you'll see this in the console:

```
============================================================
🚀 PRINT PROFILE - START
Timestamp: 2025-11-13T14:32:15.234567
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001234
  • Printer Type: THERMAL
  • Printer Brand: Brother
  • Printer Model: QL-820NWB
  • Target IP: 192.168.1.100
  • Port: 9100
  • Protocol: TCP
  • Is Default: Yes

🔧 ACTUAL EXECUTION:
  ✓ Printer configuration loaded from GetStorage
  ✓ Receipt content generated (856 characters)
  ✓ Print job initiated
  → Connecting to 192.168.1.100:9100...

📄 JOB DETAILS:
  • Job Number: JOB-2024-001234
  • Customer: John Doe
  • Device: Apple iPhone 14 Pro
  • Total Amount: $299.99
  • Status: Completed
============================================================

============================================================
📊 PRINT PROFILE - CONTENT_GENERATED
Timestamp: 2025-11-13T14:32:15.345678
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001234
  • Printer Type: THERMAL
  • Printer Brand: Brother
  • Printer Model: QL-820NWB
  • Target IP: 192.168.1.100
  • Port: 9100
  • Protocol: TCP
  • Is Default: Yes

🔧 ACTUAL EXECUTION:
  ✓ Content generation completed
  → Content preview:
     ═══════════════════════════════
           REPAIR RECEIPT
     ═══════════════════════════════
     
     Job No: JOB-2024-001234
     ... (42 total lines)
============================================================

============================================================
📊 PRINT PROFILE - CONNECTING
Timestamp: 2025-11-13T14:32:15.456789
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001234
  • Printer Type: THERMAL
  • Printer Brand: Brother
  • Printer Model: QL-820NWB
  • Target IP: 192.168.1.100
  • Port: 9100
  • Protocol: TCP
  • Is Default: Yes

🔧 ACTUAL EXECUTION:
  → Establishing network connection...
  → Using Brother driver
  → Model configuration: QL-820NWB

📦 ADDITIONAL DATA:
  • driver: BrotherPrinterService
  • method: printThermalReceipt
  • model_enum: Model.QL_820NWB
============================================================

============================================================
📊 PRINT PROFILE - SENDING_DATA
Timestamp: 2025-11-13T14:32:16.123456
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001234
  • Printer Type: THERMAL
  • Printer Brand: Brother
  • Printer Model: QL-820NWB
  • Target IP: 192.168.1.100
  • Port: 9100
  • Protocol: TCP
  • Is Default: Yes

🔧 ACTUAL EXECUTION:
  ✓ Connection established
  → Sending print data to printer...
  → Data format: ESC/POS commands

📦 ADDITIONAL DATA:
  • content_length: 856
  • estimated_lines: 42
============================================================

============================================================
✅ PRINT PROFILE - SUCCESS
Timestamp: 2025-11-13T14:32:17.234567
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001234
  • Printer Type: THERMAL
  • Printer Brand: Brother
  • Printer Model: QL-820NWB
  • Target IP: 192.168.1.100
  • Port: 9100
  • Protocol: TCP
  • Is Default: Yes

🔧 ACTUAL EXECUTION:
  ✅ Print job completed successfully!
  ✓ Data sent to printer
  ✓ Printer acknowledged receipt
  ✓ Connection closed properly

📦 ADDITIONAL DATA:
  • result_message: Print successful
  • error_code: ErrorCode.ERROR_NONE

📄 JOB DETAILS:
  • Job Number: JOB-2024-001234
  • Customer: John Doe
  • Device: Apple iPhone 14 Pro
  • Total Amount: $299.99
  • Status: Completed
============================================================
```

---

## Example 2: Failed Print (Network Error)

When the printer cannot be reached:

```
============================================================
🚀 PRINT PROFILE - START
Timestamp: 2025-11-13T14:35:22.123456
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001235
  • Printer Type: THERMAL
  • Printer Brand: Brother
  • Printer Model: QL-820NWB
  • Target IP: 192.168.1.100
  • Port: 9100
  • Protocol: TCP
  • Is Default: Yes

🔧 ACTUAL EXECUTION:
  ✓ Printer configuration loaded from GetStorage
  ✓ Receipt content generated (892 characters)
  ✓ Print job initiated
  → Connecting to 192.168.1.100:9100...

📄 JOB DETAILS:
  • Job Number: JOB-2024-001235
  • Customer: Jane Smith
  • Device: Samsung Galaxy S23
  • Total Amount: $199.99
  • Status: In Progress
============================================================

[... CONTENT_GENERATED and CONNECTING stages ...]

============================================================
❌ PRINT PROFILE - ERROR
Timestamp: 2025-11-13T14:35:28.345678
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001235
  • Printer Type: THERMAL
  • Printer Brand: Brother
  • Printer Model: QL-820NWB
  • Target IP: 192.168.1.100
  • Port: 9100
  • Protocol: TCP
  • Is Default: Yes

🔧 ACTUAL EXECUTION:
  ❌ Print job failed!
  ❌ Error: Network connection timeout
  ❌ Error Code: ErrorCode.ERROR_TIMEOUT

  💡 Troubleshooting:
     1. Verify printer is powered on
     2. Check IP address: 192.168.1.100
     3. Ensure printer is on same network
     4. Check firewall settings (port 9100)
     5. Verify printer supports Brother protocol

📦 ADDITIONAL DATA:
  • error: Network connection timeout
  • errorCode: ErrorCode.ERROR_TIMEOUT
============================================================
```

---

## Example 3: Test Print from Thermal Printer Settings

When you click "Test Print" in printer configuration:

```
============================================================
🧪 TEST PRINT - THERMAL PRINTER
============================================================

📋 WHAT SHOULD HAPPEN:
  1. Connect to printer at 192.168.1.100:9100
  2. Send test pattern with printer info
  3. Print confirmation receipt
  4. Verify printer responds correctly

🔧 CONFIGURATION:
  • Brand: Brother
  • Model: QL-820NWB
  • IP Address: 192.168.1.100
  • Port: 9100
  • Protocol: TCP

⚠️  CURRENT STATUS:
  • Test print functionality: NOT IMPLEMENTED YET
  • Reason: Requires printer-specific driver integration
  • Workaround: Save settings and test from receipt screen

💡 NEXT STEPS:
  1. Save these settings using the Save button
  2. Go to any job details screen
  3. Click Print Receipt to test actual printing
============================================================
```

---

## Example 4: Test Print from Label Printer Settings

When you click "Test Print" for a label printer:

```
============================================================
🧪 TEST PRINT - LABEL PRINTER
============================================================

📋 WHAT SHOULD HAPPEN:
  1. Connect to label printer at 192.168.1.105:9100
  2. Configure label size and settings
  3. Print test label with printer info
  4. Auto-cut label if supported

🔧 CONFIGURATION:
  • Brand: Brother
  • Model: QL-820NWB
  • IP Address: 192.168.1.105
  • Port: 9100
  • Protocol: TCP

⚠️  CURRENT STATUS:
  • Test print functionality: NOT IMPLEMENTED YET
  • Reason: Requires brand-specific label configuration
  • Workaround: Save settings and test from receipt screen

💡 SUPPORTED LABEL SIZES (Brother):
  • 62mm × 100mm (W62)
  • 102mm × 152mm (W102)
  • Continuous tape

💡 NEXT STEPS:
  1. Save these settings using the Save button
  2. Go to any job details screen
  3. Click Print Receipt to test actual label printing
============================================================
```

---

## Example 5: Unsupported Printer Brand

When trying to use an unsupported printer brand:

```
============================================================
🚀 PRINT PROFILE - START
Timestamp: 2025-11-13T14:40:15.123456
============================================================

[... START and CONTENT_GENERATED stages ...]

============================================================
❌ PRINT PROFILE - ERROR
Timestamp: 2025-11-13T14:40:15.456789
============================================================

📋 EXPECTED BEHAVIOR:
  • Action: Print receipt for Job #JOB-2024-001236
  • Printer Type: THERMAL
  • Printer Brand: Epson
  • Printer Model: TM-T88VI
  • Target IP: 192.168.1.110
  • Port: 9100
  • Protocol: TCP
  • Is Default: No

🔧 ACTUAL EXECUTION:
  ❌ Print job failed!

  💡 Troubleshooting:
     1. Verify printer is powered on
     2. Check IP address: 192.168.1.110
     3. Ensure printer is on same network
     4. Check firewall settings (port 9100)
     5. Verify printer supports Epson protocol

📦 ADDITIONAL DATA:
  • error: Printer brand not supported
  • supported_brands: Brother
  • requested_brand: Epson
============================================================
```

---

## How to Use This Information

### For Development/Debugging:
1. **Watch the console** during print operations
2. **Check timestamps** to see where delays occur
3. **Review error codes** to identify specific issues
4. **Verify configuration** matches expected values

### For Troubleshooting:
1. **Connection Issues**: Check IP address, port, and network connectivity
2. **Configuration Issues**: Verify printer brand, model, and protocol settings
3. **Content Issues**: Review the content preview to ensure formatting is correct
4. **Driver Issues**: Check if the correct printer service is being used

### Key Sections to Monitor:
- **EXPECTED BEHAVIOR**: What the system is configured to do
- **ACTUAL EXECUTION**: What's actually happening in real-time
- **ADDITIONAL DATA**: Specific technical details for debugging
- **JOB DETAILS**: Context about the receipt being printed
- **Troubleshooting**: Suggested fixes when errors occur

---

## Benefits of This Profiling System

1. ✅ **Clear visibility** into print process stages
2. ✅ **Immediate error identification** with specific codes
3. ✅ **Troubleshooting guidance** built into error messages
4. ✅ **Configuration validation** at each step
5. ✅ **Performance metrics** via timestamps
6. ✅ **Content preview** to verify formatting before sending
7. ✅ **Network diagnostics** for connectivity issues
