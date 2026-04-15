import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/utils/widgets/custom_text_button.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/helpers/snakbar_demo.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
import '../widgets/wifi_printer_scanner.dart';
import '../widgets/printer_empty_state.dart';
import '../widgets/printer_list_item.dart';
import '../widgets/printer_configuration_form.dart';
import '_test_pdf_base64.dart';

class A4ReceiptPrinterScreen extends StatefulWidget {
  const A4ReceiptPrinterScreen({super.key});

  @override
  State<A4ReceiptPrinterScreen> createState() => _A4ReceiptPrinterScreenState();
}

class _A4ReceiptPrinterScreenState extends State<A4ReceiptPrinterScreen> {
  final PrinterSettingsService _settingsService = PrinterSettingsService();

  // Supported A4 printer brands (for dropdown)
  final List<String> _supportedBrands = [
    'HP',
    'Canon',
    'Epson',
    'Brother',
    'Generic',
  ];

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
      _savedPrinters = _settingsService.getPrinters('a4');
    });
    debugPrint('📊 Loaded ${_savedPrinters.length} A4 printers');
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
    } catch (e, stack) {
      debugPrint('❌ Failed to save A4 printer settings: $e');
      debugPrint('$stack');
      SnackbarDemo(
        message: '❌ Failed to save settings: $e',
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

  /// Decode the bundled test PDF (base64) and send it to the configured
  /// printer. For raw/JetDirect/9100 protocols the bytes are streamed over a
  /// TCP socket directly; otherwise we fall back to the system print dialog.
  Future<void> _testPrint(PrinterConfigModel config) async {
    if (config.ipAddress.isEmpty) {
      SnackbarDemo(
        message: 'Please enter IP address to test print',
      ).showCustomSnackbar(context);
      return;
    }

    setState(() => _isPrinting = true);

    try {
      final base64String = kTestPdfBase64.contains(',')
          ? kTestPdfBase64.split(',').last
          : kTestPdfBase64;
      final Uint8List pdfBytes = base64Decode(base64String);

      final protocol = config.protocol.toLowerCase();
      final isRawTcp = const {'raw', 'tcp', 'jetdirect', '9100'}.contains(protocol);

      bool success = false;
      if (isRawTcp) {
        final port = config.port ?? 9100;
        try {
          final socket = await Socket.connect(
            config.ipAddress,
            port,
            timeout: const Duration(seconds: 5),
          );
          socket.add(pdfBytes);
          await socket.flush();
          socket.destroy();
          success = true;
        } catch (e) {
          debugPrint('❌ TCP send failed, falling back to system dialog: $e');
          success = await Printing.layoutPdf(
            onLayout: (_) async => pdfBytes,
            name: 'a4_test_print.pdf',
            format: PdfPageFormat.a4,
          );
        }
      } else {
        success = await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: 'a4_test_print.pdf',
          format: PdfPageFormat.a4,
        );
      }

      if (!mounted) return;
      SnackbarDemo(
        message: success
            ? '✅ Test PDF sent to printer!'
            : '❌ Print cancelled',
      ).showCustomSnackbar(context);
    } catch (e) {
      if (!mounted) return;
      SnackbarDemo(
        message: '❌ Test print error: $e',
      ).showCustomSnackbar(context);
    } finally {
      if (mounted) setState(() => _isPrinting = false);
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
                        printerType: 'a4',
                        initialConfig: _editingPrinter,
                        supportedBrands: _supportedBrands,
                        brandModels: const {},
                        onSave: _saveSettings,
                        onScan: _showWiFiScanner,
                        onTestPrint: _testPrint,
                        isSaving: _isSaving,
                        isPrinting: _isPrinting,
                      ),
                    )
                  : _savedPrinters.isEmpty
                  ? PrinterEmptyState(title: "No A4 Printer")
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
                            isDefault: printer.isDefault,
                            printer: printer,
                            onEdit: () =>
                                setState(() => _editingPrinter = printer),
                            onDelete: () => _deletePrinter(printer),
                            onSetDefault: () => _setAsDefaultPrinter(printer),
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                      'A4 Printer',
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
