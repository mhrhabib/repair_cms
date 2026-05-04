import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:solar_icons/solar_icons.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.job});
  final SingleJobModel job;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final _settingsService = PrinterSettingsService();
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final jobId = widget.job.data?.sId;
    if (jobId == null || jobId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid job: missing job ID';
      });
      return;
    }

    try {
      final bytes = await _fetchReceiptPdfBytes(jobId);
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load PDF: $e';
        });
      }
    }
  }

  /// Fetch the receipt PDF (base64) from the server, then print it.
  Future<void> _showPrinterSelection(BuildContext context) async {
    debugPrint('🖨️ Starting receipt print flow');

    if (_pdfBytes == null) {
      SnackbarDemo(message: 'PDF not loaded yet').showCustomSnackbar(context);
      return;
    }

    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> configuredPrinters = [
      ...allPrinters['a4'] ?? [],
    ];

    if (configuredPrinters.isEmpty) {
      SnackbarDemo(
        message:
            'No A4 printers configured. Please configure an A4 printer in Settings > Printer Settings',
      ).showCustomSnackbar(context);
      return;
    }

    if (configuredPrinters.length == 1) {
      await _printPdfBytes(context, _pdfBytes!, configuredPrinters.first);
      return;
    }

    final defaultA4 = _settingsService.getDefaultPrinter('a4');
    final defaultPrinterType = defaultA4 != null ? 'a4' : null;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _PrinterSelectionDialog(
        printers: configuredPrinters,
        defaultPrinterType: defaultPrinterType,
        onPrint: (printer) => _printPdfBytes(context, _pdfBytes!, printer),
      ),
    );
  }

  /// Call the receipt API and dump the response to the console for debugging.
  /// Does NOT send anything to a printer — use the print button for that.
  Future<void> _testReceiptApi(BuildContext context) async {
    final jobId = widget.job.data?.sId;
    if (jobId == null || jobId.isEmpty) {
      SnackbarDemo(
        message: 'Invalid job: missing job ID',
      ).showCustomSnackbar(context);
      return;
    }

    final url = ApiEndpoints.jobReceiptPdf.replaceAll('<id>', jobId);
    debugPrint('🧪 [ReceiptApiTest] POST $url');

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final dio.Response response = await BaseClient.post(
        url: url,
        payload: {},
      );
      debugPrint('🧪 [ReceiptApiTest] status=${response.statusCode}');
      debugPrint('🧪 [ReceiptApiTest] headers=${response.headers.map}');

      final dynamic raw = response.data;
      debugPrint('🧪 [ReceiptApiTest] body type=${raw.runtimeType}');

      final Map<String, dynamic> body = raw is String
          ? jsonDecode(raw) as Map<String, dynamic>
          : raw as Map<String, dynamic>;

      debugPrint('🧪 [ReceiptApiTest] body keys=${body.keys.toList()}');
      debugPrint('🧪 [ReceiptApiTest] success=${body['success']}');
      debugPrint('🧪 [ReceiptApiTest] message=${body['message']}');

      final data = body['data'];
      debugPrint('🧪 [ReceiptApiTest] data type=${data.runtimeType}');

      if (data is Map<String, dynamic>) {
        debugPrint('🧪 [ReceiptApiTest] data keys=${data.keys.toList()}');
        final base64Str = data['base64'] as String?;
        if (base64Str == null || base64Str.isEmpty) {
          debugPrint('🧪 [ReceiptApiTest] ⚠ base64 missing or empty');
        } else {
          final normalized = base64Str.contains(',')
              ? base64Str.split(',').last
              : base64Str;
          debugPrint(
            '🧪 [ReceiptApiTest] base64 raw length=${base64Str.length}, normalized length=${normalized.length}',
          );
          debugPrint(
            '🧪 [ReceiptApiTest] base64 prefix=${base64Str.substring(0, base64Str.length.clamp(0, 80))}',
          );
          try {
            final bytes = base64Decode(normalized);
            debugPrint(
              '🧪 [ReceiptApiTest] decoded PDF bytes=${bytes.length} (first 4=${bytes.take(4).toList()})',
            );
          } catch (e) {
            debugPrint('🧪 [ReceiptApiTest] ❌ base64 decode failed: $e');
          }
        }
      } else {
        debugPrint('🧪 [ReceiptApiTest] data preview=$data');
      }

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('API test complete — check console')),
      );
    } catch (e, st) {
      debugPrint('🧪 [ReceiptApiTest] ❌ error: $e');
      debugPrint('$st');
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('API test error: $e')),
      );
    }
  }

  /// Fetch job receipt PDF bytes from the receipt API.
  Future<Uint8List> _fetchReceiptPdfBytes(String jobId) async {
    final url = ApiEndpoints.jobReceiptPdf.replaceAll('<id>', jobId);
    final dio.Response response = await BaseClient.post(url: url, payload: {});

    if (response.statusCode != 200) {
      throw Exception(
        'Receipt request failed: ${response.statusCode} ${response.data}',
      );
    }

    final dynamic raw = response.data;
    final Map<String, dynamic> body = raw is String
        ? jsonDecode(raw) as Map<String, dynamic>
        : raw as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception(
        'Receipt request unsuccessful: ${body['message'] ?? body}',
      );
    }

    final data = body['data'];
    final String? base64Str = data is Map<String, dynamic>
        ? data['base64'] as String?
        : null;
    if (base64Str == null || base64Str.isEmpty) {
      throw Exception('Receipt response missing base64 PDF');
    }

    const int chunkSize = 800;
    for (int i = 0; i < base64Str.length; i += chunkSize) {
      final end = (i + chunkSize < base64Str.length)
          ? i + chunkSize
          : base64Str.length;
      // ignore: avoid_print
      print('receipt.base64[$i-$end]: ${base64Str.substring(i, end)}');
    }

    final normalized = base64Str.contains(',')
        ? base64Str.split(',').last
        : base64Str;
    return base64Decode(normalized);
  }

  /// Send decoded PDF bytes to the selected printer.
  Future<void> _printPdfBytes(
    BuildContext context,
    Uint8List pdfBytes,
    PrinterConfigModel printer,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success = false;
      final pdfName = 'Job_Receipt_${widget.job.data?.jobNo ?? 'pdf'}.pdf';

      // Always use system print dialog for A4 printers.
      // Sending raw PDF bytes over TCP crashes A4 printer firmware.
      success = await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: pdfName,
        format: PdfPageFormat.a4,
      );

      try {
        navigator.pop();
      } catch (_) {}
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Receipt printed successfully!' : 'Print cancelled',
          ),
        ),
      );
    } catch (e) {
      try {
        navigator.pop();
      } catch (_) {}
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Print error: $e')),
      );
    }
  }

  String get jobId => widget.job.data?.sId ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 72.h,
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _pdfBytes == null
                  ? const Center(child: Text('No PDF data'))
                  : PdfPreview(
                      build: (_) async => _pdfBytes!,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                      allowPrinting: false,
                      allowSharing: false,
                      pdfFileName:
                          'receipt_${widget.job.data?.jobNo ?? 'pdf'}.pdf',
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
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.arrow_back_ios_new,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
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
                      'Job Receipt',
                      style: AppTypography.sfProHeadLineTextStyle22,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (kDebugMode)
                        CustomNavButton(
                          onPressed: () => _testReceiptApi(context),
                          icon: SolarIconsOutline.bug,
                          iconColor: AppColors.fontSecondaryColor,
                          size: 24.r,
                        ),
                      SizedBox(width: 8.w),
                      CustomNavButton(
                        onPressed: () => _showPrinterSelection(context),
                        icon: SolarIconsOutline.printer,
                        iconColor: AppColors.fontSecondaryColor,
                        size: 24.r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrintSettingsPage extends StatefulWidget {
  final SingleJobModel jobData;

  const PrintSettingsPage({super.key, required this.jobData});

  @override
  State<PrintSettingsPage> createState() => _PrintSettingsPageState();
}

class _PrintSettingsPageState extends State<PrintSettingsPage> {
  int copies = 1;
  bool isPortrait = false;
  String selectedPages = 'All';
  String selectedColor = 'Color';
  String selectedPaperSize = 'ISO A4';
  String selectedPrintType = 'Single-sided';

  @override
  Widget build(BuildContext context) {
    final Color figmaBlue = const Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        leading: CustomNavButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CupertinoIcons.back,
        ),
        middle: Text(
          'Print Settings',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        trailing: CustomNavButton(
          onPressed: () {},
          icon: CupertinoIcons.ellipsis,
          iconColor: figmaBlue,
          size: 22.r,
        ),
      ),
      body: Column(
        children: [
          // Preview thumbnail
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Job Receipt',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            'Job No: ${widget.jobData.data?.jobNo ?? 'N/A'}\n'
                            'Customer: ${widget.jobData.data?.customerDetails?.firstName ?? 'N/A'} ${widget.jobData.data?.customerDetails?.lastName ?? ''}\n'
                            'Device: ${widget.jobData.data?.deviceData?.brand ?? 'N/A'} ${widget.jobData.data?.deviceData?.model ?? ''}\n'
                            'Total: ${_formatCurrency(widget.jobData.data?.total)}\n\n'
                            'This is a preview of the job receipt.',
                            style: TextStyle(
                              fontSize: 6,
                              color: Colors.grey[700],
                            ),
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSettingTile(
                  title: 'Printer',
                  value: 'Not selected',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildSettingTile(
                  title: 'Copies',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: copies > 1
                            ? () => setState(() => copies--)
                            : null,
                      ),
                      Text(
                        '$copies',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => copies++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingTile(
                  title: 'Orientation',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOrientationButton(false),
                      const SizedBox(width: 8),
                      _buildOrientationButton(true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownTile('Pages', selectedPages, () {}),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownTile('Color', selectedColor, () {}),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownTile(
                        'Paper size',
                        selectedPaperSize,
                        () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownTile(
                        'Print type',
                        selectedPrintType,
                        () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Print button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print initiated')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Print',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0.00';
    try {
      final numericAmount = double.tryParse(amount.toString()) ?? 0.0;
      return '${numericAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildSettingTile({
    required String title,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing:
            trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdownTile(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.expand_more, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrientationButton(bool portrait) {
    final isSelected = isPortrait == portrait;
    return GestureDetector(
      onTap: () => setState(() => isPortrait = portrait),
      child: Container(
        width: 40,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            width: portrait ? 20 : 30,
            height: portrait ? 30 : 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey[400]!,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Printer selection dialog
class _PrinterSelectionDialog extends StatelessWidget {
  final List<PrinterConfigModel> printers;
  final String? defaultPrinterType;
  final Future<void> Function(PrinterConfigModel) onPrint;

  const _PrinterSelectionDialog({
    required this.printers,
    this.defaultPrinterType,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(
        'Select Printer',
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
      ),
      message: Text(
        'Choose a printer to print the receipt',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      ),
      actions: printers.map((printer) {
        final isDefault =
            printer.printerType == defaultPrinterType && printer.isDefault;
        return CupertinoActionSheetAction(
          onPressed: () async {
            debugPrint(
              '🎯 User selected: ${printer.printerBrand} ${printer.printerType} printer',
            );
            // Close dialog first
            Navigator.of(context).pop();

            // Then execute print and wait for result
            await onPrint(printer);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  _getPrinterIcon(printer.printerType),
                  size: 24.r,
                  color: AppColors.fontMainColor,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${printer.printerBrand} ${printer.printerModel ?? ""}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF007AFF),
                          ),
                        ),
                        if (isDefault) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      printer.ipAddress,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _getPrinterTitle(printer.printerType),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        isDefaultAction: true,
        child: const Text('Cancel'),
      ),
    );
  }

  IconData _getPrinterIcon(String printerType) {
    switch (printerType) {
      case 'thermal':
        return Icons.receipt_long;
      case 'label':
        return Icons.label;
      case 'a4':
        return Icons.description;
      default:
        return Icons.print;
    }
  }

  String _getPrinterTitle(String printerType) {
    switch (printerType) {
      case 'thermal':
        return 'Thermal Printer (80mm)';
      case 'label':
        return 'Label Printer';
      case 'a4':
        return 'A4 Receipt Printer';
      default:
        return 'Printer';
    }
  }
}
