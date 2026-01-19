import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/snakbar_demo.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
import '../service/printer_service_factory.dart';
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
  bool _isSaving = false;
  bool isPrinting = false;

  List<PrinterConfigModel> _savedPrinters = [];

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
    _loadSavedPrinters();
  }

  void _loadSavedPrinters() {
    setState(() {
      _savedPrinters = _settingsService.getPrinters('thermal');
    });
    debugPrint('📊 Loaded ${_savedPrinters.length} thermal printers');
  }

  void _fillFormFromPrinter(PrinterConfigModel printer) {
    setState(() {
      _selectedBrand = printer.printerBrand;
      _selectedModel = printer.printerModel;
      _paperWidth = printer.paperWidth ?? 80;
      _ipController.text = printer.ipAddress;
      _portController.text = printer.port?.toString() ?? '9100';
      _selectedProtocol = printer.protocol;
      _setAsDefault = printer.isDefault;
    });
    SnackbarDemo(
      message: 'Form filled with ${printer.printerModel ?? printer.printerBrand} settings',
    ).showCustomSnackbar(context);
  }

  Future<void> _saveSettings() async {
    if (_ipController.text.isEmpty) {
      SnackbarDemo(message: 'Please enter IP address').showCustomSnackbar(context);
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
      SnackbarDemo(message: '✅ Settings saved successfully!').showCustomSnackbar(context);
      _loadSavedPrinters(); // Refresh the list
      _clearForm();
    } catch (e) {
      SnackbarDemo(message: '❌ Failed to save settings').showCustomSnackbar(context);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _clearForm() {
    setState(() {
      _selectedBrand = 'Epson';
      _selectedModel = null;
      _paperWidth = 80;
      _ipController.clear();
      _portController.text = '9100';
      _selectedProtocol = 'TCP';
      _setAsDefault = false;
    });
  }

  Future<void> _testConnection() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(message: 'Please enter IP address to test connection').showCustomSnackbar(context);
      return;
    }

    SnackbarDemo(message: 'Testing connection to $ip:$port...').showCustomSnackbar(context);

    try {
      debugPrint('🔍 [ConnectionTest] Attempting to connect to $ip:$port');
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      socket.destroy();
      debugPrint('✅ [ConnectionTest] Successfully connected to $ip:$port');
      SnackbarDemo(message: '✅ Connection successful! Printer is reachable.').showCustomSnackbar(context);
    } catch (e) {
      debugPrint('❌ [ConnectionTest] Failed to connect: $e');
      String errorMsg = '❌ Connection failed: ';
      if (e.toString().contains('timeout')) {
        errorMsg += 'Timeout. Check if printer is on and IP is correct.';
      } else if (e.toString().contains('refused')) {
        errorMsg += 'Connection refused. Check port number or firewall.';
      } else {
        errorMsg += 'Check network, IP address, and printer power.';
      }
      SnackbarDemo(message: errorMsg).showCustomSnackbar(context);
    }
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
        SnackbarDemo(message: 'Printer deleted').showCustomSnackbar(context);
        _loadSavedPrinters();
      } catch (e) {
        SnackbarDemo(message: 'Failed to delete printer').showCustomSnackbar(context);
      }
    }
  }

  Future<void> _setAsDefaultPrinter(PrinterConfigModel printer) async {
    try {
      final updatedPrinter = printer.copyWith(isDefault: true);
      await _settingsService.savePrinterConfig(updatedPrinter);
      SnackbarDemo(message: '✅ Set as default printer').showCustomSnackbar(context);
      _loadSavedPrinters();
    } catch (e) {
      SnackbarDemo(message: 'Failed to set default').showCustomSnackbar(context);
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
      SnackbarDemo(message: 'Printer selected: ${result['ip']}').showCustomSnackbar(context);
    }
  }

  /// Test print functionality
  Future<void> _testPrint() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(message: 'Please enter IP address to test print').showCustomSnackbar(context);
      return;
    }

    setState(() => isPrinting = true);

    debugPrint('🖨️ [TestPrint] Starting test print to $ip:$port');

    // Create a simple test receipt text
    final testReceipt = '''
========================================
           TEST RECEIPT
========================================

Printer: $_selectedBrand ${_selectedModel ?? ''}
Paper Width: ${_paperWidth}mm
IP Address: $ip
Port: $port
Protocol: $_selectedProtocol

========================================
           TEST SUCCESSFUL
========================================

Date: ${DateTime.now().toString().split('.')[0]}

This is a test print to verify your
thermal printer configuration.

========================================
''';

    try {
      // Import the printer service factory
      final config = PrinterConfigModel(
        printerType: 'thermal',
        printerBrand: _selectedBrand,
        printerModel: _selectedModel,
        ipAddress: ip,
        protocol: _selectedProtocol,
        port: port,
        paperWidth: _paperWidth,
        isDefault: false,
      );

      debugPrint('📋 [TestPrint] Using config: ${config.printerBrand} ${config.printerModel}');

      // Use the printer service factory to get appropriate service
      final printerService = PrinterServiceFactory.getPrinterServiceForConfig(config);
      
      final result = await printerService.printThermalReceipt(
        ipAddress: ip,
        text: testReceipt,
        port: port,
      );

      if (result.success) {
        debugPrint('✅ [TestPrint] Print successful');
        SnackbarDemo(message: '✅ Test print successful!').showCustomSnackbar(context);
      } else {
        debugPrint('❌ [TestPrint] Print failed: ${result.message}');
        SnackbarDemo(message: '❌ Test print failed: ${result.message}').showCustomSnackbar(context);
      }
    } catch (e) {
      debugPrint('❌ [TestPrint] Error: $e');
      SnackbarDemo(message: '❌ Test print error: $e').showCustomSnackbar(context);
    } finally {
      setState(() => isPrinting = false);
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
          'Thermal Printer (80mm)',
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
                          Icons.print,
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
                        '${printer.ipAddress}:${printer.port} (${printer.paperWidth}mm)',
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
              keyboardType: TextInputType.text,
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
            // Connection Test Button
            if (_ipController.text.trim().isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: _testConnection,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    side: const BorderSide(color: Colors.blue),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.network_check, color: Colors.blue),
                      SizedBox(width: 8.w),
                      Text(
                        'Test Connection',
                        style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            if (_ipController.text.trim().isNotEmpty) SizedBox(height: 12.h),
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
            Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isPrinting ? null : _testPrint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isPrinting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Test Print',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
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
