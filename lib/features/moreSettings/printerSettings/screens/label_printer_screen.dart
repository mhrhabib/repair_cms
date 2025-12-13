import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/show_toast.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
import '../widgets/wifi_printer_scanner.dart';

class LabelPrinterScreen extends StatefulWidget {
  const LabelPrinterScreen({super.key});

  @override
  State<LabelPrinterScreen> createState() => _LabelPrinterScreenState();
}

class _LabelPrinterScreenState extends State<LabelPrinterScreen> {
  final PrinterSettingsService _settingsService = PrinterSettingsService();

  // Supported label printer brands
  final List<String> _supportedBrands = ['Brother', 'Xprinter', 'Dymo'];

  String _selectedBrand = 'Brother';
  String? _selectedModel;
  LabelSize? _selectedLabelSize;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '9100');
  String _selectedProtocol = 'TCP';
  bool _setAsDefault = false;
  bool _isTesting = false;
  bool _isSaving = false;

  List<PrinterConfigModel> _savedPrinters = [];

  // Models for each brand
  final Map<String, List<String>> _brandModels = {
    'Brother': ['QL-820NWB', 'QL-1110NWB', 'PT-P750W', 'PT-P300BT', 'QL-700', 'QL-800'],
    'Xprinter': ['XP-420B', 'XP-470B', 'XP-DT425B'],
    'Dymo': ['LabelWriter 450', 'LabelWriter 4XL', 'LabelWriter 550'],
  };

  @override
  void initState() {
    super.initState();
    _loadSavedPrinters();
  }

  void _loadSavedPrinters() {
    setState(() {
      _savedPrinters = _settingsService.getPrinters('label');
    });
    debugPrint('📊 Loaded ${_savedPrinters.length} label printers');
  }

  void _fillFormFromPrinter(PrinterConfigModel printer) {
    setState(() {
      _selectedBrand = printer.printerBrand;
      _selectedModel = printer.printerModel;
      _selectedLabelSize = printer.labelSize;
      _ipController.text = printer.ipAddress;
      _portController.text = printer.port?.toString() ?? '9100';
      _selectedProtocol = printer.protocol;
      _setAsDefault = printer.isDefault;
    });
    showCustomToast('Form filled with ${printer.printerModel ?? printer.printerBrand} settings');
  }

  Future<void> _testPrint() async {
    if (_ipController.text.isEmpty) {
      showCustomToast('Please enter IP address', isError: true);
      return;
    }

    setState(() => _isTesting = true);

    final config = PrinterConfigModel(
      printerType: 'label',
      printerBrand: _selectedBrand,
      printerModel: _selectedModel,
      ipAddress: _ipController.text.trim(),
      protocol: _selectedProtocol,
      port: int.tryParse(_portController.text),
      isDefault: _setAsDefault,
    );

    // Log test print attempt
    debugPrint('\n${'=' * 60}');
    debugPrint('🧪 TEST PRINT - LABEL PRINTER');
    debugPrint('=' * 60);
    debugPrint('\n📋 WHAT SHOULD HAPPEN:');
    debugPrint('  1. Connect to label printer at ${config.ipAddress}:${config.port ?? 9100}');
    debugPrint('  2. Configure label size and settings');
    debugPrint('  3. Print test label with printer info');
    debugPrint('  4. Auto-cut label if supported');

    debugPrint('\n🔧 CONFIGURATION:');
    debugPrint('  • Brand: $_selectedBrand');
    debugPrint('  • Model: ${_selectedModel ?? 'Not selected'}');
    debugPrint('  • IP Address: ${_ipController.text.trim()}');
    debugPrint('  • Port: ${_portController.text}');
    debugPrint('  • Protocol: $_selectedProtocol');

    debugPrint('\n⚠️  CURRENT STATUS:');
    debugPrint('  • Test print functionality: NOT IMPLEMENTED YET');
    debugPrint('  • Reason: Requires brand-specific label configuration');
    debugPrint('  • Workaround: Save settings and test from receipt screen');

    debugPrint('\n💡 SUPPORTED LABEL SIZES ($_selectedBrand):');
    if (_selectedBrand == 'Brother') {
      debugPrint('  • 62mm × 100mm (W62)');
      debugPrint('  • 102mm × 152mm (W102)');
      debugPrint('  • Continuous tape');
    } else if (_selectedBrand == 'Dymo') {
      debugPrint('  • 54mm × 101mm (1744907)');
      debugPrint('  • 102mm × 159mm (4XL)');
    } else {
      debugPrint('  • 80mm × 80mm (standard)');
      debugPrint('  • Custom sizes supported');
    }

    debugPrint('\n💡 NEXT STEPS:');
    debugPrint('  1. Save these settings using the Save button');
    debugPrint('  2. Go to any job details screen');
    debugPrint('  3. Click Print Receipt to test actual label printing');
    debugPrint('${'=' * 60}\n');

    // Show user-friendly message
    showCustomToast('Test print not available yet. Please save and test from receipt screen.', isError: false);
    setState(() => _isTesting = false);
  }

  Future<void> _saveSettings() async {
    if (_ipController.text.isEmpty) {
      showCustomToast('Please enter IP address', isError: true);
      return;
    }

    if (_selectedLabelSize == null) {
      showCustomToast('Please select label size', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final config = PrinterConfigModel(
      printerType: 'label',
      printerBrand: _selectedBrand,
      printerModel: _selectedModel,
      ipAddress: _ipController.text.trim(),
      protocol: _selectedProtocol,
      port: int.tryParse(_portController.text),
      isDefault: _setAsDefault,
      labelSize: _selectedLabelSize,
    );

    try {
      await _settingsService.savePrinterConfig(config);
      showCustomToast('✅ Settings saved successfully!', isError: false);
      _loadSavedPrinters(); // Refresh the list
      _clearForm();
    } catch (e) {
      showCustomToast('❌ Failed to save settings', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _clearForm() {
    setState(() {
      _selectedBrand = 'Brother';
      _selectedModel = null;
      _selectedLabelSize = null;
      _ipController.clear();
      _portController.text = '9100';
      _selectedProtocol = 'TCP';
      _setAsDefault = false;
    });
  }

  Future<void> _deletePrinter(PrinterConfigModel printer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Printer'),
        content: Text('Delete ${printer.printerModel ?? printer.printerBrand}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _settingsService.deletePrinterConfig(printer);
        showCustomToast('Printer deleted');
        _loadSavedPrinters();
      } catch (e) {
        showCustomToast('Failed to delete printer', isError: true);
      }
    }
  }

  Future<void> _setAsDefaultPrinter(PrinterConfigModel printer) async {
    try {
      final updatedPrinter = printer.copyWith(isDefault: true);
      await _settingsService.savePrinterConfig(updatedPrinter);
      showCustomToast('✅ Set as default printer');
      _loadSavedPrinters();
    } catch (e) {
      showCustomToast('Failed to set default', isError: true);
    }
  }

  /// Show WiFi printer scanner dialog
  Future<void> _showWiFiScanner() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WiFiPrinterScanner(
        onPrinterSelected: (String ipAddress, int port) {
          // Fill the form immediately when "Use" is clicked
          setState(() {
            _ipController.text = ipAddress;
            _portController.text = port.toString();
          });
          Navigator.pop(context, {'ip': ipAddress, 'port': port});
        },
      ),
    );

    if (result != null) {
      debugPrint('✅ Selected printer: ${result['ip']}:${result['port']}');
      showCustomToast('Printer selected: ${result['ip']}', isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        border: null,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.back, size: 28.r, color: const Color(0xFF007AFF)),
              SizedBox(width: 4.w),
              Text(
                'Back',
                style: TextStyle(fontSize: 17.sp, color: const Color(0xFF007AFF)),
              ),
            ],
          ),
        ),
        middle: Text(
          'Label Printer',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved Printers List
            if (_savedPrinters.isNotEmpty) ...[
              Text(
                'Saved Printers',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedPrinters.length,
                itemBuilder: (context, index) {
                  final printer = _savedPrinters[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: printer.isDefault ? Colors.green.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.label,
                          color: printer.isDefault ? Colors.green.shade700 : Colors.grey.shade700,
                          size: 24.sp,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${printer.printerBrand} ${printer.printerModel ?? ""}',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
                            ),
                          ),
                          if (printer.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4.r)),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${printer.ipAddress}:${printer.port} (${printer.labelSize?.name ?? "N/A"})',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'use') {
                            _fillFormFromPrinter(printer);
                          } else if (value == 'default') {
                            _setAsDefaultPrinter(printer);
                          } else if (value == 'delete') {
                            _deletePrinter(printer);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'use', child: Text('Use')),
                          if (!printer.isDefault) const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              Divider(height: 1.h),
              SizedBox(height: 24.h),
            ],

            // Form Title
            Text(
              'Add New Printer',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            // Brand Selection
            Text(
              'Printer Brand',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedBrand,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              items: _supportedBrands.map((brand) {
                return DropdownMenuItem(value: brand, child: Text(brand));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBrand = value!;
                  _selectedModel = null;
                  _selectedLabelSize = null; // Reset label size when brand changes
                });
              },
            ),
            SizedBox(height: 16.h),

            // Model Selection
            Text(
              'Printer Model',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedModel,
              hint: const Text('Select Model'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              items: _brandModels[_selectedBrand]?.map((model) {
                return DropdownMenuItem(value: model, child: Text(model));
              }).toList(),
              onChanged: (value) => setState(() => _selectedModel = value),
            ),
            SizedBox(height: 16.h),

            // Label Size Selection
            Text(
              'Label Size',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<LabelSize>(
              initialValue: _selectedLabelSize,
              hint: const Text('Select Label Size'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                prefixIcon: Icon(Icons.aspect_ratio, color: AppColors.primary),
              ),
              items: _getLabelSizesForBrand().map((size) {
                return DropdownMenuItem(value: size, child: Text('${size.name} (${size.width}×${size.height} mm)'));
              }).toList(),
              onChanged: (value) => setState(() => _selectedLabelSize = value),
            ),
            if (_selectedLabelSize != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Selected: ${_selectedLabelSize!.width}mm × ${_selectedLabelSize!.height}mm',
                      style: TextStyle(fontSize: 13.sp, color: Colors.green.shade900, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16.h),

            // IP Address with WiFi scan button
            Row(
              children: [
                Text(
                  'IP Address',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showWiFiScanner(),
                  icon: Icon(Icons.wifi_find, size: 18.sp),
                  label: const Text('Scan WiFi'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'e.g., 192.168.1.100',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                suffixIcon: Icon(Icons.router, color: Colors.grey.shade400),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),

            // Port
            Text(
              'Port',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                hintText: 'Default: 9100',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),

            // Protocol
            Text(
              'Protocol',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedProtocol,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              items: ['TCP', 'USB'].map((protocol) {
                return DropdownMenuItem(value: protocol, child: Text(protocol));
              }).toList(),
              onChanged: (value) => setState(() => _selectedProtocol = value!),
            ),
            SizedBox(height: 16.h),

            // Set as Default
            CheckboxListTile(
              title: const Text('Set as default label printer'),
              value: _setAsDefault,
              onChanged: (value) => setState(() => _setAsDefault = value!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 24.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Settings',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 12.h),

            // Test Print Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _testPrint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: _isTesting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Test Print',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get label sizes based on selected brand
  List<LabelSize> _getLabelSizesForBrand() {
    switch (_selectedBrand) {
      case 'Brother':
        return LabelSize.getBrotherSizes();
      case 'Dymo':
        return LabelSize.getDymoSizes();
      case 'Xprinter':
        return LabelSize.getXprinterSizes();
      default:
        return LabelSize.getBrotherSizes();
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
