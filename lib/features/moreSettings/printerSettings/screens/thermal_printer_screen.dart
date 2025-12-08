import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/show_toast.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
import '../widgets/wifi_printer_scanner.dart';

class ThermalPrinterScreen extends StatefulWidget {
  const ThermalPrinterScreen({super.key});

  @override
  State<ThermalPrinterScreen> createState() => _ThermalPrinterScreenState();
}

class _ThermalPrinterScreenState extends State<ThermalPrinterScreen> {
  final PrinterSettingsService _settingsService = PrinterSettingsService();

  // Supported thermal printer brands
  final List<String> _supportedBrands = ['Epson', 'Star', 'Xprinter', 'Brother'];

  String _selectedBrand = 'Epson';
  String? _selectedModel;
  int _paperWidth = 80; // Default 80mm
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '9100');
  String _selectedProtocol = 'TCP';
  bool _setAsDefault = false;
  bool _isTesting = false;
  bool _isSaving = false;

  // Models for each brand
  final Map<String, List<String>> _brandModels = {
    'Epson': ['TM-T20II', 'TM-T82', 'TM-T88V', 'TM-M30'],
    'Star': ['TSP143III', 'TSP650II', 'TSP700II', 'TSP847II'],
    'Xprinter': ['XP-80C', 'XP-365B', 'XP-N160II'],
    'Brother': ['TD-2130N', 'TD-4420TN', 'TD-4550DNWB'],
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  void _loadSavedSettings() {
    final defaultPrinter = _settingsService.getDefaultPrinter('thermal');
    if (defaultPrinter != null) {
      setState(() {
        _selectedBrand = defaultPrinter.printerBrand;
        _selectedModel = defaultPrinter.printerModel;
        _paperWidth = defaultPrinter.paperWidth ?? 80;
        _ipController.text = defaultPrinter.ipAddress;
        _portController.text = defaultPrinter.port?.toString() ?? '9100';
        _selectedProtocol = defaultPrinter.protocol;
        _setAsDefault = defaultPrinter.isDefault;
      });
      debugPrint('📊 Loaded thermal printer settings: $_selectedBrand');
    }
  }

  Future<void> _testPrint() async {
    if (_ipController.text.isEmpty) {
      showCustomToast('Please enter IP address', isError: true);
      return;
    }

    setState(() => _isTesting = true);

    final config = PrinterConfigModel(
      printerType: 'thermal',
      printerBrand: _selectedBrand,
      printerModel: _selectedModel,
      ipAddress: _ipController.text.trim(),
      protocol: _selectedProtocol,
      port: int.tryParse(_portController.text),
      isDefault: _setAsDefault,
    );

    // Log test print attempt
    debugPrint('\n${'=' * 60}');
    debugPrint('🧪 TEST PRINT - THERMAL PRINTER');
    debugPrint('=' * 60);
    debugPrint('\n📋 WHAT SHOULD HAPPEN:');
    debugPrint('  1. Connect to printer at ${config.ipAddress}:${config.port ?? 9100}');
    debugPrint('  2. Send test pattern with printer info');
    debugPrint('  3. Print confirmation receipt');
    debugPrint('  4. Verify printer responds correctly');

    debugPrint('\n🔧 CONFIGURATION:');
    debugPrint('  • Brand: $_selectedBrand');
    debugPrint('  • Model: ${_selectedModel ?? 'Not selected'}');
    debugPrint('  • IP Address: ${_ipController.text.trim()}');
    debugPrint('  • Port: ${_portController.text}');
    debugPrint('  • Protocol: $_selectedProtocol');

    debugPrint('\n⚠️  CURRENT STATUS:');
    debugPrint('  • Test print functionality: NOT IMPLEMENTED YET');
    debugPrint('  • Reason: Requires printer-specific driver integration');
    debugPrint('  • Workaround: Save settings and test from receipt screen');

    debugPrint('\n💡 NEXT STEPS:');
    debugPrint('  1. Save these settings using the Save button');
    debugPrint('  2. Go to any job details screen');
    debugPrint('  3. Click Print Receipt to test actual printing');
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

    setState(() => _isSaving = true);

    final config = PrinterConfigModel(
      printerType: 'thermal',
      printerBrand: _selectedBrand,
      printerModel: _selectedModel,
      ipAddress: _ipController.text.trim(),
      protocol: _selectedProtocol,
      port: int.tryParse(_portController.text),
      isDefault: _setAsDefault,
      paperWidth: _paperWidth,
    );

    try {
      await _settingsService.savePrinterConfig(config);
      showCustomToast('✅ Settings saved successfully!', isError: false);
    } catch (e) {
      showCustomToast('❌ Failed to save settings', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Show WiFi printer scanner dialog
  void _showWiFiScanner() {
    showDialog(
      context: context,
      builder: (context) => WiFiPrinterScanner(
        onPrinterSelected: (ipAddress, port) {
          setState(() {
            _ipController.text = ipAddress;
            _portController.text = port.toString();
          });
          showCustomToast('✅ Printer selected: $ipAddress:$port', isError: false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thermal Printer (80mm)'), backgroundColor: AppColors.scaffoldBackgroundColor),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  _selectedModel = null; // Reset model when brand changes
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
              hint: const Text('Select Model (Optional)'),
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

            // Paper Width Selection
            Text(
              'Paper Width',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<int>(
              initialValue: _paperWidth,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                prefixIcon: Icon(Icons.straighten, color: AppColors.primary),
              ),
              items: [80, 58].map((width) {
                return DropdownMenuItem(
                  value: width,
                  child: Text('${width}mm ${width == 80 ? '(Standard)' : '(Compact)'}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _paperWidth = value!),
            ),
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

            // Protocol Selection
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

            // Set as Default Checkbox
            CheckboxListTile(
              title: const Text('Set as default thermal printer'),
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

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
