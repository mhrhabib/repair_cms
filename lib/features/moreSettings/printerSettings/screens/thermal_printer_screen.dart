import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
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
  final List<String> _supportedBrands = ['Epson', 'Star', 'Brother'];

  String _selectedBrand = 'Epson';
  String? _selectedModel;
  int _paperWidth = 80; // Default 80mm
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(
    text: '9100',
  );
  String _selectedProtocol = 'TCP';
  bool _setAsDefault = false;
  bool _isSaving = false;
  bool isPrinting = false;

  List<PrinterConfigModel> _savedPrinters = [];

  // Models for each brand
  final Map<String, List<String>> _brandModels = {
    'Epson': ['TM-T20II', 'TM-T82', 'TM-T88V', 'TM-M30'],
    'Star': ['TSP143III', 'TSP650II', 'TSP700II', 'TSP847II'],
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
      _selectedBrand = 'Epson';
      _selectedModel = null;
      _paperWidth = 80;
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

  /// Test print functionality
  Future<void> _testPrint() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(
        message: 'Please enter IP address to test print',
      ).showCustomSnackbar(context);
      return;
    }

    setState(() => isPrinting = true);

    debugPrint('🖨️ [TestPrint] Starting test print to $ip:$port');

    // Create a simple test receipt text
    final testReceipt =
        '''
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

      debugPrint(
        '📋 [TestPrint] Using config: ${config.printerBrand} ${config.printerModel}',
      );

      // Use the printer service factory to get appropriate service
      final printerService = PrinterServiceFactory.getPrinterServiceForConfig(
        config,
      );

      final result = await printerService.printThermalReceipt(
        ipAddress: ip,
        text: testReceipt,
        port: port,
      );

      if (result.success) {
        debugPrint('✅ [TestPrint] Print successful');
        SnackbarDemo(
          message: '✅ Test print successful!',
        ).showCustomSnackbar(context);
      } else {
        debugPrint('❌ [TestPrint] Print failed: ${result.message}');
        SnackbarDemo(
          message: '❌ Test print failed: ${result.message}',
        ).showCustomSnackbar(context);
      }
    } catch (e) {
      debugPrint('❌ [TestPrint] Error: $e');
      SnackbarDemo(
        message: '❌ Test print error: $e',
      ).showCustomSnackbar(context);
    } finally {
      setState(() => isPrinting = false);
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
          'Thermal Printer',
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
                      onChanged: (value) =>
                          setState(() => _selectedModel = value),
                    ),
                    SizedBox(height: 16.h),

                    // Paper Width
                    _buildLabel('Paper Width'),
                    _buildDropdownFieldGeneric<int>(
                      hint: 'Select Width',
                      value: _paperWidth,
                      items: [80, 58],
                      itemBuilder: (width) =>
                          '${width}mm ${width == 80 ? '(Standard)' : '(Compact)'}',
                      onChanged: (value) =>
                          setState(() => _paperWidth = value!),
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
                      items: ['TCP', 'USB'],
                      onChanged: (value) =>
                          setState(() => _selectedProtocol = value!),
                    ),

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
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed: isPrinting ? null : _testPrint,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Test Print',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
              Icons.print_rounded,
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
                  '${printer.ipAddress} • ${printer.paperWidth}mm',
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

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
