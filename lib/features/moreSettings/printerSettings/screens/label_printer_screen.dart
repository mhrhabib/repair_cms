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
  bool _isSaving = false;
  bool _useSdk = false;

  List<PrinterConfigModel> _savedPrinters = [];

  // Models for each brand
  final Map<String, List<String>> _brandModels = {
    'Brother': [
      // QL Series (Label Printers)
      'QL-820NWB',
      'QL-1110NWB',
      'QL-700',
      'QL-800',
      // PT Series (Label Makers)
      'PT-P750W',
      'PT-P300BT',
      // TD-2D Series (Desktop Label Printers) - Supported by another_brother SDK
      'TD-2030A',
      'TD-2125N',
      'TD-2125NWB',
      'TD-2135N',
      'TD-2135NWB',
      // TD-4D Series (Desktop Label Printers) - May work with another_brother SDK
      'TD-4210D',
      'TD-4410D',
      'TD-4420DN',
      'TD-4520DN',
      'TD-4550DNWB',
    ],
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
      _useSdk = printer.useSdk ?? false;
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

    if (_selectedLabelSize == null) {
      SnackbarDemo(message: 'Please select label size').showCustomSnackbar(context);
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
      useSdk: _useSdk,
      labelSize: _selectedLabelSize,
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
      _selectedBrand = 'Brother';
      _selectedModel = null;
      _selectedLabelSize = null;
      _ipController.clear();
      _portController.text = '9100';
      _selectedProtocol = 'TCP';
      _setAsDefault = false;
      _useSdk = false;
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
                        '${printer.ipAddress}:${printer.port} (${printer.labelSize?.name ?? "N/A"}) • ${printer.useSdk == true ? 'SDK' : 'Raw TCP'}',
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
            if (_selectedBrand == 'Brother')
              CheckboxListTile(
                title: const Text('Use Brother SDK (recommended for TD/QL series)'),
                value: _useSdk,
                onChanged: (value) => setState(() => _useSdk = value ?? false),
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
            if (_ipController.text.trim().isNotEmpty) SizedBox(height: 8.h),

            // Test Print Button
            if (_ipController.text.trim().isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: () async {
                    // Build a simple test label text
                    final testText = 'RepairCMS Label Test\n\nMODEL: ${_selectedModel ?? ''}';

                    // Prepare a temporary PrinterConfigModel for this test
                    final temp = PrinterConfigModel(
                      printerType: 'label',
                      printerBrand: _selectedBrand,
                      printerModel: _selectedModel,
                      ipAddress: _ipController.text.trim(),
                      protocol: _selectedProtocol,
                      port: int.tryParse(_portController.text),
                      isDefault: false,
                      labelSize: _selectedLabelSize,
                      useSdk: _useSdk,
                    );

                    // Console debug: show payload and config for debugging
                    debugPrint('🖨️ Test Print — payload:\n$testText');
                    debugPrint('🖨️ Test Print — config: ${temp.toJson()}');
                    debugPrint('🖨️ Selected LabelSize: ${_selectedLabelSize?.toString() ?? 'N/A'}');

                    SnackbarDemo(message: 'Sending test print...').showCustomSnackbar(context);

                    try {
                      final res = await PrinterServiceFactory.getPrinterServiceForConfig(
                        temp,
                      ).printLabel(ipAddress: temp.ipAddress, text: testText, port: temp.port ?? 9100);

                      debugPrint('🖨️ Print result: success=${res.success}, code=${res.code}, message=${res.message}');
                      SnackbarDemo(message: res.message).showCustomSnackbar(context);
                    } catch (e, st) {
                      debugPrint('❌ Test print failed: $e\n$st');
                      SnackbarDemo(message: '❌ Test print failed').showCustomSnackbar(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Test Print (Label)', style: TextStyle(fontSize: 16.sp)),
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
