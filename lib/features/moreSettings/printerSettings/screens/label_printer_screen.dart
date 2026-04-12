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
  final List<String> _supportedBrands = ['Brother', 'Xprinter',];

  // Models for each brand
  final Map<String, List<String>> _brandModels = {
    'Brother': [
      'TD-2350D',
      'TD-4550DNWB',
    ],
    'Xprinter': [
      'XP-410B',
    ],
    //'Dymo': ['LabelWriter 450', 'LabelWriter 4XL', 'LabelWriter 550'],
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
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Printer'),
        content: Text(
          'Are you sure you want to delete ${printer.printerModel ?? printer.printerBrand}?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
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

  Future<Map<String, dynamic>?> _showWiFiScanner() async {
    return await showDialog<Map<String, dynamic>>(
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
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 72.h),
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
                            onEdit: () =>
                                setState(() => _editingPrinter = printer),
                            onDelete: () => _deletePrinter(printer),
                            onSetDefault: () => _setAsDefaultPrinter(printer),
                            isDefault: printer.isDefault,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16.w,
                right: 16.w,
                bottom: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.kBg.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomNavButton(
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: AppColors.whiteColor, // Figma: border #FFFFFF
                        width: 1, // Figma: border-width 1px
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            28,
                            116,
                            115,
                            115,
                          ), // Figma: #0000001C
                          blurRadius: 2, // Figma: blur 20px
                          offset: Offset(0, 0), // Figma: 0px 0px (no offset)
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'Label Printer',
                      style: AppTypography.sfProHeadLineTextStyle22,
                    ),
                  ),
                  if (!isFormView)
                    CustomTextButton(
                      onPressed: () => setState(() => _isAdding = true),
                      text: 'Add',
                    )
                  else
                    const SizedBox(width: 44), // Spacer
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
