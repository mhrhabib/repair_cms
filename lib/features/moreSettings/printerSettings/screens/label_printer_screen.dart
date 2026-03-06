import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
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
  bool _isPrinting = false;

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
    'Xprinter': [
      'XP-80C',
      'XP-365B',
      'XP-N160II',
      'XP-410B',
      'XP-420B',
      'XP-470B',
      'XP-DT425B',
    ],
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

  /// Test receipt print (text-based)
  Future<void> _testReceiptPrint() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(
        message: 'Please enter IP address to test print',
      ).showCustomSnackbar(context);
      return;
    }

    setState(() => _isPrinting = true);

    final testReceipt =
        '''
========================================
           TEST RECEIPT
========================================

Printer: $_selectedBrand ${_selectedModel ?? ''}
IP Address: $ip
Port: $port

========================================
           TEST SUCCESSFUL
========================================

Date: ${DateTime.now().toString().split('.')[0]}

This is a test print to verify your
label printer's receipt mode.

========================================
''';

    try {
      final config = PrinterConfigModel(
        printerType: 'label',
        printerBrand: _selectedBrand,
        printerModel: _selectedModel,
        ipAddress: ip,
        protocol: _selectedProtocol,
        port: port,
        isDefault: false,
      );

      final printerService = PrinterServiceFactory.getPrinterServiceForConfig(
        config,
      );
      final result = await printerService.printThermalReceipt(
        ipAddress: ip,
        text: testReceipt,
        port: port,
      );

      if (result.success) {
        SnackbarDemo(
          message: '✅ Test receipt printed successfully!',
        ).showCustomSnackbar(context);
      } else {
        SnackbarDemo(
          message: '❌ Test receipt failed: ${result.message}',
        ).showCustomSnackbar(context);
      }
    } catch (e) {
      SnackbarDemo(
        message: '❌ Test receipt error: $e',
      ).showCustomSnackbar(context);
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  /// Test label print (structured data)
  Future<void> _testLabelPrint() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(
        message: 'Please enter IP address to test label',
      ).showCustomSnackbar(context);
      return;
    }

    setState(() => _isPrinting = true);

    try {
      final config = PrinterConfigModel(
        printerType: 'label',
        printerBrand: _selectedBrand,
        printerModel: _selectedModel,
        ipAddress: ip,
        protocol: _selectedProtocol,
        port: port,
        isDefault: false,
        labelSize: _selectedLabelSize,
      );

      final labelData = {
        'jobNumber': 'JOB-12345',
        'customerName': 'Test Customer',
        'deviceName': 'iPhone 13 Pro',
        'imei': '123456789012345',
        'defect': 'Broken Screen',
        'location': 'Shelf A-1',
        'jobId': '888',
      };

      final result = await PrinterServiceFactory.printDeviceLabelWithFallback(
        config: config,
        labelData: labelData,
      );

      if (result.success) {
        SnackbarDemo(
          message: '✅ Test label printed successfully!',
        ).showCustomSnackbar(context);
      } else {
        SnackbarDemo(
          message: '❌ Test label failed: ${result.message}',
        ).showCustomSnackbar(context);
      }
    } catch (e) {
      SnackbarDemo(
        message: '❌ Test label error: $e',
      ).showCustomSnackbar(context);
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: CustomNavButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new,
          ),
        ),
        title: Text(
          'Label Printer',
          style: AppTypography.sfProHeadLineTextStyle22,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Printer Configuration',
                      style: AppTypography.sfProText15.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Brand Selection
                    _buildLabel('Printer Brand'),
                    _buildDropdownField(
                      hint: 'Select Brand',
                      value: _selectedBrand,
                      items: _supportedBrands,
                      onChanged: (value) {
                        setState(() {
                          _selectedBrand = value!;
                          _selectedModel = null;
                          _selectedLabelSize = null;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Model Selection
                    _buildLabel('Printer Model'),
                    _buildDropdownField(
                      hint: 'Select Model',
                      value: _selectedModel,
                      items: _brandModels[_selectedBrand] ?? [],
                      onChanged: (value) {
                        setState(() {
                          _selectedModel = value;
                          if (value != null && _selectedBrand == 'Brother') {
                            if (value.startsWith('TD-4')) {
                              _selectedLabelSize = LabelSize(
                                width: 100,
                                height: 150,
                                name: '100x150 (TD-4)',
                              );
                            } else if (value.startsWith('TD-2')) {
                              _selectedLabelSize = LabelSize(
                                width: 50,
                                height: 26,
                                name: '50x26 (TD-2)',
                              );
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Label Size
                    _buildLabel('Label Size'),
                    _buildDropdownFieldGeneric<LabelSize>(
                      hint: 'Select Size',
                      value: _selectedLabelSize,
                      items: _getLabelSizesForBrand(),
                      itemBuilder: (size) =>
                          '${size.name} (${size.width}×${size.height} mm)',
                      onChanged: (value) =>
                          setState(() => _selectedLabelSize = value),
                    ),
                    SizedBox(height: 16.h),

                    // IP Address
                    _buildLabel('IP Address'),
                    _buildInputField(
                      controller: _ipController,
                      hint: '192.169.5.1',
                      suffixIcon: GestureDetector(
                        onTap: _showWiFiScanner,
                        child: Icon(
                          Icons.wifi_find,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Port
                    _buildLabel('Port'),
                    _buildInputField(
                      controller: _portController,
                      hint: '9100',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.h),

                    // Protocol
                    _buildLabel('Printer Protocol'),
                    _buildDropdownField(
                      hint: 'Protocol',
                      value: _selectedProtocol,
                      items: ['TCP', 'IPP', 'USB'],
                      onChanged: (value) {
                        setState(() {
                          _selectedProtocol = value!;
                          if (value == 'IPP') {
                            _portController.text = '631';
                          } else if (value == 'TCP') {
                            _portController.text = '9100';
                          }
                        });
                      },
                    ),

                    if (_selectedProtocol == 'IPP' &&
                        _selectedBrand == 'Brother') ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'IPP is recommended for Brother printers!',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 16.h),

                    // Default switch
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _setAsDefault,
                            onChanged: (val) =>
                                setState(() => _setAsDefault = val!),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Set as default printer',
                          style: AppTypography.sfProText15.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Save Settings',
                                style: AppTypography.primaryButtonTextStyle
                                    .copyWith(fontSize: 16.sp),
                              ),
                      ),
                    ),

                    if (_ipController.text.trim().isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52.h,
                              child: OutlinedButton(
                                onPressed: _isPrinting
                                    ? null
                                    : _testReceiptPrint,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Test Receipt',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: SizedBox(
                              height: 52.h,
                              child: OutlinedButton(
                                onPressed: _isPrinting ? null : _testLabelPrint,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Test Label',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Saved Printers Section
            if (_savedPrinters.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Printers',
                      style: AppTypography.sfProText15.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ..._savedPrinters.map(
                      (printer) => _buildSavedPrinterCard(printer),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(
        label,
        style: AppTypography.sfProText15.copyWith(
          fontSize: 14.sp,
          color: AppColors.fontSecondaryColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.sfProText15,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.sfProText15.copyWith(
          color: AppColors.fontSecondaryColor.withValues(alpha: 0.3),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(
            hint,
            style: AppTypography.sfProText15.copyWith(
              color: AppColors.fontSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
          isExpanded: true,
          style: AppTypography.sfProText15,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownFieldGeneric<T>({
    required String hint,
    T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.contains(value) ? value : null,
          hint: Text(
            hint,
            style: AppTypography.sfProText15.copyWith(
              color: AppColors.fontSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
          isExpanded: true,
          style: AppTypography.sfProText15,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSavedPrinterCard(PrinterConfigModel printer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: printer.isDefault
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.label_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${printer.printerBrand} ${printer.printerModel ?? ""}',
                  style: AppTypography.sfProText15.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${printer.ipAddress} • ${printer.labelSize?.name ?? "N/A"}',
                  style: AppTypography.sfProText15.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.fontSecondaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (printer.isDefault)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'DEFAULT',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.fontSecondaryColor,
            ),
            onSelected: (value) {
              if (value == 'use')
                _fillFormFromPrinter(printer);
              else if (value == 'default')
                _setAsDefaultPrinter(printer);
              else if (value == 'delete')
                _deletePrinter(printer);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'use', child: Text('Use')),
              if (!printer.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Text('Set as Default'),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // IP Address with WiFi scan button
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
