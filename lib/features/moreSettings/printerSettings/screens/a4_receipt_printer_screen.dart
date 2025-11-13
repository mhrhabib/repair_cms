import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/show_toast.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
import '../widgets/wifi_printer_scanner.dart';

class A4PrinterScreen extends StatefulWidget {
  const A4PrinterScreen({super.key});

  @override
  State<A4PrinterScreen> createState() => _A4PrinterScreenState();
}

class _A4PrinterScreenState extends State<A4PrinterScreen> {
  final PrinterSettingsService _settingsService = PrinterSettingsService();

  final TextEditingController _printerNameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '9100');
  String _selectedProtocol = 'TCP';
  bool _setAsDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  void _loadSavedSettings() {
    final defaultPrinter = _settingsService.getDefaultPrinter('a4');
    if (defaultPrinter != null) {
      setState(() {
        _printerNameController.text = defaultPrinter.printerModel ?? '';
        _ipController.text = defaultPrinter.ipAddress;
        _portController.text = defaultPrinter.port?.toString() ?? '9100';
        _selectedProtocol = defaultPrinter.protocol;
        _setAsDefault = defaultPrinter.isDefault;
      });
      debugPrint('📊 Loaded A4 printer settings');
    }
  }

  Future<void> _scanForPrinters() async {
    debugPrint('🔍 Opening WiFi printer scanner for A4 printer');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WiFiPrinterScanner(
        onPrinterSelected: (String ipAddress, int port) {
          Navigator.pop(context, {'ip': ipAddress, 'port': port});
        },
      ),
    );

    if (result != null) {
      setState(() {
        _ipController.text = result['ip'] as String;
        _portController.text = (result['port'] as int).toString();
      });
      debugPrint('✅ Selected printer: ${result['ip']}:${result['port']}');
      showCustomToast('Printer selected: ${result['ip']}', isError: false);
    }
  }

  Future<void> _saveSettings() async {
    if (_ipController.text.isEmpty && _selectedProtocol == 'TCP') {
      showCustomToast('Please enter IP address', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final config = PrinterConfigModel(
      printerType: 'a4',
      printerBrand: 'Generic',
      printerModel: _printerNameController.text.trim().isEmpty
          ? 'Generic A4 Printer'
          : _printerNameController.text.trim(),
      ipAddress: _ipController.text.trim(),
      protocol: _selectedProtocol,
      port: int.tryParse(_portController.text),
      isDefault: _setAsDefault,
    );

    try {
      await _settingsService.savePrinterConfig(config);
      debugPrint('✅ A4 printer config saved: ${config.ipAddress}');
      showCustomToast('✅ Settings saved successfully!', isError: false);
    } catch (e) {
      debugPrint('❌ Failed to save A4 printer config: $e');
      showCustomToast('❌ Failed to save settings', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A4 Printer'), backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'A4 printers use the system print dialog. Configure network settings below.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Printer Name
            Text(
              'Printer Name (Optional)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _printerNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Office HP Printer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 16.h),

            // IP Address with Scan WiFi button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'IP Address',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: _scanForPrinters,
                  icon: Icon(Icons.wifi_find, size: 18.sp),
                  label: Text('Scan WiFi', style: TextStyle(fontSize: 14.sp)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'e.g., 192.168.1.100',
                prefixIcon: const Icon(Icons.router),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
              value: _selectedProtocol,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              items: ['TCP', 'USB', 'System Default'].map((protocol) {
                return DropdownMenuItem(value: protocol, child: Text(protocol));
              }).toList(),
              onChanged: (value) => setState(() => _selectedProtocol = value!),
            ),
            SizedBox(height: 16.h),

            // Set as Default
            CheckboxListTile(
              title: const Text('Set as default A4 printer'),
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _printerNameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
