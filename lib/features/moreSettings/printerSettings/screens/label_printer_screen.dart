import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/utils/widgets/custom_text_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/helpers/snakbar_demo.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
import '../service/printer_service_factory.dart';
import '../widgets/wifi_printer_scanner.dart';
import '../widgets/printer_empty_state.dart';
import '../widgets/printer_list_item.dart';
import '../widgets/printer_configuration_form.dart';

class LabelPrinterScreen extends StatefulWidget {
  const LabelPrinterScreen({super.key});

  @override
  State<LabelPrinterScreen> createState() => _LabelPrinterScreenState();
}

class _LabelPrinterScreenState extends State<LabelPrinterScreen> {
  final PrinterSettingsService _settingsService = PrinterSettingsService();

  // Supported label printer brands
  final List<String> _supportedBrands = ['Brother', 'Xprinter', 'Dymo'];

  // Models for each brand
  final Map<String, List<String>> _brandModels = {
    'Brother': [
      'TD-2030A',
      'TD-2125N',
      'TD-2125NWB',
      'TD-2135N',
      'TD-2135NWB',
      'TD-2350D',
      'TD-2350DA',
      'TD-4210D',
      'TD-4410D',
      'TD-4420DN',
      'TD-4520DN',
      'TD-4550DNWB',
      'TD-455DNWB',
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

  List<PrinterConfigModel> _savedPrinters = [];
  bool _isAdding = false;
  PrinterConfigModel? _editingPrinter;
  bool _isSaving = false;
  bool _isPrinting = false;

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

  Future<void> _saveSettings(PrinterConfigModel config) async {
    setState(() => _isSaving = true);

    try {
      await _settingsService.savePrinterConfig(config);
      SnackbarDemo(
        message: '✅ Settings saved successfully!',
      ).showCustomSnackbar(context);
      _loadSavedPrinters(); // Refresh the list
      setState(() {
        _isAdding = false;
        _editingPrinter = null;
      });
    } catch (e) {
      SnackbarDemo(
        message: '❌ Failed to save settings',
      ).showCustomSnackbar(context);
    } finally {
      setState(() => _isSaving = false);
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

  Future<void> _showWiFiScanner() async {
    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WiFiPrinterScanner(
        onPrinterSelected: (String ipAddress, int port) {
          Navigator.pop(context, {'ip': ipAddress, 'port': port});
        },
      ),
    );
  }

  Future<void> _testReceiptPrint(PrinterConfigModel config) async {
    if (config.ipAddress.isEmpty) {
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

Printer: ${config.printerBrand} ${config.printerModel ?? ''}
IP Address: ${config.ipAddress}
Port: ${config.port}

========================================
           TEST SUCCESSFUL
========================================

Date: ${DateTime.now().toString().split('.')[0]}

This is a test print to verify your
label printer's receipt mode.

========================================
''';

    try {
      final printerService = PrinterServiceFactory.getPrinterServiceForConfig(
        config,
      );
      final result = await printerService.printThermalReceipt(
        ipAddress: config.ipAddress,
        text: testReceipt,
        port: config.port ?? 9100,
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

  Future<void> _testLabelPrint(PrinterConfigModel config) async {
    if (config.ipAddress.isEmpty) {
      SnackbarDemo(
        message: 'Please enter IP address to test label',
      ).showCustomSnackbar(context);
      return;
    }

    setState(() => _isPrinting = true);

    try {
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
    bool isFormView = _isAdding || _editingPrinter != null;

    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.kBg,
        leading: CustomNavButton(
          onPressed: () {
            if (isFormView) {
              setState(() {
                _isAdding = false;
                _editingPrinter = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icons.arrow_back_ios_new,
        ),
        middle: Text(
          'Label Printer',
          style: AppTypography.sfProHeadLineTextStyle22,
        ),
        trailing: !isFormView
            ? Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: CustomTextButton(
                  onPressed: () => setState(() => _isAdding = true),
                  text: 'Add',
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: isFormView
            ? SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: PrinterConfigurationForm(
                  printerType: 'label',
                  initialConfig: _editingPrinter,
                  supportedBrands: _supportedBrands,
                  brandModels: _brandModels,
                  onSave: _saveSettings,
                  onScan: _showWiFiScanner,
                  onTestPrint: _testReceiptPrint,
                  onTestLabel: _testLabelPrint,
                  isSaving: _isSaving,
                  isPrinting: _isPrinting,
                ),
              )
            : _savedPrinters.isEmpty
            ? PrinterEmptyState(title: "No Label Printer")
            : ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
                    child: Text(
                      'Available Printers',
                      style: AppTypography.sfProText15.copyWith(
                        color: AppColors.fontSecondaryColor.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  ..._savedPrinters.map(
                    (printer) => PrinterListItem(
                      printer: printer,
                      onEdit: () => setState(() => _editingPrinter = printer),
                      onDelete: () => _deletePrinter(printer),
                      onSetDefault: () => _setAsDefaultPrinter(printer),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
