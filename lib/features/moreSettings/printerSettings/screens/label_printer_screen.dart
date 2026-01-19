import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
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
  final TextEditingController _portController = TextEditingController(
    text: '9100',
  );
  String _selectedProtocol = 'TCP';
  bool _setAsDefault = false;
  bool _isSaving = false;

  List<PrinterConfigModel> _savedPrinters = [];

  // Models for each brand
  final Map<String, List<String>> _brandModels = {
    'Brother': [
      // TD-2D Series (Desktop Label Printers) - 50×26mm labels @ 300 DPI
      'TD-2030A',
      'TD-2125N',
      'TD-2125NWB',
      'TD-2135N',
      'TD-2135NWB',
      'TD-2350D', // Client's printer at 192.168.0.149
      'TD-2350DA',
      // TD-4D Series (Desktop Label Printers) - 100×150mm labels @ 300 DPI
      'TD-4210D',
      'TD-4410D',
      'TD-4420DN',
      'TD-4520DN',
      'TD-4550DNWB',
      'TD-455DNWB', // Client's printer at 192.168.0.7 (typo variant of TD-4550DNWB)
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
    });
    SnackbarDemo(
      message:
          'Form filled with ${printer.printerModel ?? printer.printerBrand} settings',
    ).showCustomSnackbar(context);
  }

  Future<void> _saveSettings() async {
    if (_ipController.text.isEmpty) {
      SnackbarDemo(
        message: 'Please enter IP address',
      ).showCustomSnackbar(context);
      return;
    }

    if (_selectedLabelSize == null) {
      SnackbarDemo(
        message: 'Please select label size',
      ).showCustomSnackbar(context);
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
      SnackbarDemo(
        message: '✅ Settings saved successfully!',
      ).showCustomSnackbar(context);
      _loadSavedPrinters(); // Refresh the list
      _clearForm();
    } catch (e) {
      SnackbarDemo(
        message: '❌ Failed to save settings',
      ).showCustomSnackbar(context);
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

  Future<void> _testConnection() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(
        message: 'Please enter IP address to test connection',
      ).showCustomSnackbar(context);
      return;
    }

    SnackbarDemo(
      message: 'Testing connection to $ip:$port...',
    ).showCustomSnackbar(context);

    try {
      debugPrint('🔍 [ConnectionTest] Attempting to connect to $ip:$port');
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      debugPrint('✅ [ConnectionTest] Successfully connected to $ip:$port');
      SnackbarDemo(
        message: '✅ Connection successful! Printer is reachable.',
      ).showCustomSnackbar(context);
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
        content: Text(
          'Delete ${printer.printerModel ?? printer.printerBrand}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
        SnackbarDemo(
          message: 'Failed to delete printer',
        ).showCustomSnackbar(context);
      }
    }
  }

  Future<void> _setAsDefaultPrinter(PrinterConfigModel printer) async {
    try {
      final updatedPrinter = printer.copyWith(isDefault: true);
      await _settingsService.savePrinterConfig(updatedPrinter);
      SnackbarDemo(
        message: '✅ Set as default printer',
      ).showCustomSnackbar(context);
      _loadSavedPrinters();
    } catch (e) {
      SnackbarDemo(
        message: 'Failed to set default',
      ).showCustomSnackbar(context);
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
      SnackbarDemo(
        message: 'Printer selected: ${result['ip']}',
      ).showCustomSnackbar(context);
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
              Icon(
                CupertinoIcons.back,
                size: 28.r,
                color: const Color(0xFF007AFF),
              ),
              SizedBox(width: 4.w),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: 17.sp,
                  color: const Color(0xFF007AFF),
                ),
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
                          color: printer.isDefault
                              ? Colors.green.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.label,
                          color: printer.isDefault
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                          size: 24.sp,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${printer.printerBrand} ${printer.printerModel ?? ""}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                          if (printer.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${printer.ipAddress}:${printer.port} (${printer.labelSize?.name ?? "N/A"}) • ${printer.protocol}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
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
                          if (!printer.isDefault)
                            const PopupMenuItem(
                              value: 'default',
                              child: Text('Set as Default'),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              items: _supportedBrands.map((brand) {
                return DropdownMenuItem(value: brand, child: Text(brand));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBrand = value!;
                  _selectedModel = null;
                  _selectedLabelSize =
                      null; // Reset label size when brand changes
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              items: _brandModels[_selectedBrand]?.map((model) {
                return DropdownMenuItem(value: model, child: Text(model));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedModel = value;
                  // Auto-select 50x26mm label size for both TD-2 and TD-4
                  // FIXED VERSION
                  if (value != null && _selectedBrand == 'Brother') {
                    if (value.startsWith('TD-4')) {
                      // TD-4 series: use 100×150mm labels
                      _selectedLabelSize = LabelSize(
                        width: 100,
                        height: 150,
                        name: '100x150 (TD-4)',
                      );
                      debugPrint(
                        '🔧 Auto-selected label size: 100×150mm for $value',
                      );
                    } else if (value.startsWith('TD-2')) {
                      // TD-2 series: use 50×26mm labels
                      _selectedLabelSize = LabelSize(
                        width: 50,
                        height: 26,
                        name: '50x26 (TD-2)',
                      );
                      debugPrint(
                        '🔧 Auto-selected label size: 50×26mm for $value',
                      );
                    }
                  }
                });
              },
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                prefixIcon: Icon(Icons.aspect_ratio, color: AppColors.primary),
              ),
              items: _getLabelSizesForBrand().map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('${size.name} (${size.width}×${size.height} mm)'),
                );
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
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Selected: ${_selectedLabelSize!.width}mm × ${_selectedLabelSize!.height}mm',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                      ),
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
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showWiFiScanner(),
                  icon: Icon(Icons.wifi_find, size: 18.sp),
                  label: const Text('Scan WiFi'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'e.g., 192.168.1.100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              items: ['TCP', 'IPP', 'USB'].map((protocol) {
                return DropdownMenuItem(value: protocol, child: Text(protocol));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProtocol = value!;
                  // Auto-update port based on protocol
                  if (value == 'IPP') {
                    _portController.text = '631';
                  } else if (value == 'TCP') {
                    _portController.text = '9100';
                  }
                });
              },
            ),
            // Protocol recommendation
            if (_selectedProtocol == 'IPP') ...[
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
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '✅ IPP is recommended for Brother printers! More reliable than raw TCP.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_selectedProtocol == 'TCP') ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.orange.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'ℹ️ If TCP doesn\'t work, try IPP protocol instead (port 631).',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
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

            // Test Button with EXACT 591x307 dots (50x26mm @ 300 DPI)
            if (_ipController.text.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () async {
                      SnackbarDemo(
                        message: 'Generating 591×307 test...',
                      ).showCustomSnackbar(context);

                      // Generate EXACT 591x307 border test
                      final testImage = await _generateExact591x307BorderTest();

                      if (testImage == null) {
                        SnackbarDemo(
                          message: '❌ Failed to generate test image',
                        ).showCustomSnackbar(context);
                        return;
                      }

                      // Prepare temporary printer config
                      final temp = PrinterConfigModel(
                        printerType: 'label',
                        printerBrand: _selectedBrand,
                        printerModel: _selectedModel,
                        ipAddress: _ipController.text.trim(),
                        protocol: _selectedProtocol,
                        port: int.tryParse(_portController.text),
                        isDefault: false,
                        labelSize: LabelSize(
                          width: 50,
                          height: 26,
                          name: '50x26',
                        ),
                      );

                      debugPrint(
                        '🖨️ [591x307 Test] Printing to ${_selectedModel ?? "unknown"}',
                      );

                      SnackbarDemo(
                        message: 'Sending 591×307 test...',
                      ).showCustomSnackbar(context);

                      try {
                        final res =
                            await PrinterServiceFactory.printLabelImageWithFallback(
                              config: temp,
                              imageBytes: testImage,
                            );

                        if (res.success) {
                          SnackbarDemo(
                            message:
                                '✅ ${res.message}\n🎯 Check: Border should touch all 4 edges',
                          ).showCustomSnackbar(context);
                        } else {
                          SnackbarDemo(
                            message: '❌ ${res.message}',
                          ).showCustomSnackbar(context);
                        }
                      } catch (e, st) {
                        debugPrint('❌ 591x307 test failed: $e\n$st');
                        SnackbarDemo(
                          message: '❌ Test failed: $e',
                        ).showCustomSnackbar(context);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.crop_square, color: Colors.orange),
                        SizedBox(width: 8.w),
                        Text(
                          'Test 591×307 (50×26mm @300DPI)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
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

  /// Generate test border image to verify full label dimensions
  /// Creates a 4-dot black border around the label edges at NATIVE printer resolution

  /// Generate EXACT 591x307 dots image (50x26mm @ 300 DPI)
  /// This is the exact resolution for TD-2350D at 300 DPI
  Future<Uint8List?> _generateExact591x307BorderTest() async {
    try {
      // EXACT dimensions: 591 x 307 dots = 50mm x 26mm @ 300 DPI
      const int widthPx = 591;
      const int heightPx = 307;

      debugPrint('🎨 [591x307 Test] EXACT: $widthPx×$heightPx dots');
      debugPrint('🎨 [591x307 Test] = 50×26mm @ 300 DPI (11.82 dots/mm)');

      // Create canvas at EXACT dimensions
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()),
      );

      // White background
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()),
        bgPaint,
      );

      // Shift the canvas origin to compensate for printer's unprintable margins
      // Adjust offsets: move content down more to center vertically
      const double offsetX = 50.0; // Shift right
      const double offsetY =
          50.0; // Shift down very little (reduced from 15 to move content DOWN more)
      canvas.translate(offsetX, offsetY);

      // Now all drawing is offset from the shifted origin
      // Calculate center position for debugging (in shifted coordinates)
      final centerX = (widthPx - offsetX) / 2;
      final centerY = (heightPx - offsetY) / 2;

      // Expand borders MUCH closer to actual label edges (borderInset pushes OUTSIDE translated area)
      const double borderInset =
          16.0; // Push borders 16px closer to physical edges

      // Draw thick black lines at edges (in shifted coordinate system)
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      // Top edge - 8 dots thick, close to edge
      canvas.drawRect(
        Rect.fromLTWH(
          -borderInset,
          -borderInset,
          widthPx - offsetX + borderInset * 2,
          8,
        ),
        borderPaint,
      );

      // Bottom edge - 8 dots thick, close to edge
      canvas.drawRect(
        Rect.fromLTWH(
          -borderInset,
          heightPx - offsetY - 8.0 + borderInset,
          widthPx - offsetX + borderInset * 2,
          8,
        ),
        borderPaint,
      );

      // Left edge - 8 dots thick, close to edge
      canvas.drawRect(
        Rect.fromLTWH(
          -borderInset,
          -borderInset,
          8,
          heightPx - offsetY + borderInset * 2,
        ),
        borderPaint,
      );

      // Right edge - 8 dots thick, close to edge
      canvas.drawRect(
        Rect.fromLTWH(
          widthPx - offsetX - 8.0 + borderInset,
          -borderInset,
          8,
          heightPx - offsetY + borderInset * 2,
        ),
        borderPaint,
      );

      // Add corner markers (24x24 squares) at shifted coordinates
      // Top-Left: TL
      canvas.drawRect(
        Rect.fromLTWH(-borderInset, -borderInset, 24, 24),
        borderPaint,
      );

      // Top-Right: TR
      canvas.drawRect(
        Rect.fromLTWH(
          widthPx - offsetX - 24.0 + borderInset,
          -borderInset,
          24,
          24,
        ),
        borderPaint,
      );

      // Bottom-Left: BL
      canvas.drawRect(
        Rect.fromLTWH(
          -borderInset,
          heightPx - offsetY - 24.0 + borderInset,
          24,
          24,
        ),
        borderPaint,
      );

      // Bottom-Right: BR
      canvas.drawRect(
        Rect.fromLTWH(
          widthPx - offsetX - 24.0 + borderInset,
          heightPx - offsetY - 24.0 + borderInset,
          24,
          24,
        ),
        borderPaint,
      );

      // Add centered text showing CENTER position
      final textStyle = ui.TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

      final paragraphStyle = ui.ParagraphStyle(textAlign: TextAlign.center);
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(
          '591×307\nCenter: ${centerX.toInt()},${centerY.toInt()}\nTL TR\nBL BR',
        );

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: widthPx - offsetX));

      canvas.drawParagraph(
        paragraph,
        Offset(
          (widthPx - offsetX - paragraph.width) / 2,
          (heightPx - offsetY - paragraph.height) / 2,
        ),
      );

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(widthPx, heightPx);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();

      if (byteData == null) {
        debugPrint('❌ Failed to convert 591x307 image to bytes');
        return null;
      }

      final imageBytes = byteData.buffer.asUint8List();
      final bytesLength = imageBytes.length;
      debugPrint(
        '✅ [591x307 Test] Generated EXACT $widthPx×$heightPx image ($bytesLength bytes)',
      );

      return imageBytes;
    } catch (e, st) {
      debugPrint('❌ Error generating 591x307 test: $e');
      debugPrint('Stack trace: $st');
      return null;
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
