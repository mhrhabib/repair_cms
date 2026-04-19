
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
import 'package:repair_cms/features/myJobs/widgets/job_receipt_widget_new.dart';
import 'package:repair_cms/features/company/cubits/company_cubit.dart';
import 'package:repair_cms/core/services/file_service.dart';
import 'dart:convert';

import 'package:solar_icons/solar_icons.dart';

class ReceiptScreen extends StatelessWidget {
  ReceiptScreen({super.key, required this.job});
  final SingleJobModel job;

  final _settingsService = PrinterSettingsService();

  // Key to capture the on-screen receipt widget for printing
  final GlobalKey _printKey = GlobalKey();

  /// Fetch the receipt PDF (base64) from the server, then print it.
  Future<void> _showPrinterSelection(BuildContext context) async {
    debugPrint('🖨️ Starting receipt print flow');

    final jobId = job.data?.sId;
    if (jobId == null || jobId.isEmpty) {
      SnackbarDemo(message: 'Invalid job: missing job ID')
          .showCustomSnackbar(context);
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

    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    Uint8List pdfBytes;
    try {
      pdfBytes = await _fetchReceiptPdfBytes(jobId);
    } catch (e) {
      try {
        navigator.pop();
      } catch (_) {}
      debugPrint('❌ Failed to fetch receipt PDF: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to fetch receipt: $e')),
      );
      return;
    }

    try {
      navigator.pop();
    } catch (_) {}

    if (configuredPrinters.length == 1) {
      // ignore: use_build_context_synchronously
      await _printPdfBytes(context, pdfBytes, configuredPrinters.first);
      return;
    }

    final defaultA4 = _settingsService.getDefaultPrinter('a4');
    final defaultPrinterType = defaultA4 != null ? 'a4' : null;

    // ignore: use_build_context_synchronously
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _PrinterSelectionDialog(
        printers: configuredPrinters,
        defaultPrinterType: defaultPrinterType,
        onPrint: (printer) => _printPdfBytes(context, pdfBytes, printer),
      ),
    );
  }

  /// Call the receipt API and dump the response to the console for debugging.
  /// Does NOT send anything to a printer — use the print button for that.
  Future<void> _testReceiptApi(BuildContext context) async {
    final jobId = job.data?.sId;
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
      final dio.Response response = await BaseClient.post(url: url, payload: {});
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
      throw Exception('Receipt request unsuccessful: ${body['message'] ?? body}');
    }

    final data = body['data'];
    final String? base64Str =
        data is Map<String, dynamic> ? data['base64'] as String? : null;
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

    final normalized =
        base64Str.contains(',') ? base64Str.split(',').last : base64Str;
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
      final pdfName = 'Job_Receipt_${job.data?.jobNo ?? jobId}.pdf';

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

  String get jobId => job.data?.sId ?? '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 82.h),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  key: _printKey,
                  child: JobReceiptWidgetNew(jobData: job),
                ),
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
                      if (kDebugMode)  CustomNavButton(
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

// ... rest of the file remains the same (JobReceiptWidget, PrintSettingsPage, _PrinterSelectionDialog)

class JobReceiptWidget extends StatelessWidget {
  final SingleJobModel jobData;

  const JobReceiptWidget({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    final customer = jobData.data?.customerDetails;
    final device = jobData.data?.deviceData;
    final services = jobData.data?.services ?? [];
    final defect = jobData.data?.defect?.isNotEmpty == true
        ? jobData.data!.defect![0]
        : null;
    final contact = jobData.data?.contact?.isNotEmpty == true
        ? jobData.data!.contact![0]
        : null;
    final receiptFooter = jobData.data?.receiptFooter;

    // Format currency values
    final formattedSubTotal = _formatCurrency(jobData.data?.subTotal);
    final formattedTotal = _formatCurrency(jobData.data?.total);
    final formattedVat = _formatCurrency(jobData.data?.vat);
    final formattedDiscount = _formatCurrency(jobData.data?.discount);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 600,
      ), // Add minimum width constraint
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and company name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BlocBuilder<CompanyCubit, CompanyState>(
                    builder: (context, companyState) {
                      final company = companyState is CompanyLoaded
                          ? companyState.company
                          : null;
                      final address = receiptFooter?.address;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company address from receipt footer
                          if (address != null ||
                              (company != null &&
                                  company.companyName.isNotEmpty)) ...[
                            Text(
                              address?.companyName ??
                                  company?.companyName ??
                                  'Company Name',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            if (address != null) ...[
                              Text(
                                '${address.street ?? ''} ${address.num ?? ''}',
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.right,
                              ),
                              Text(
                                '${address.zip ?? ''} ${address.city ?? ''}',
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.right,
                              ),
                              Text(
                                address.country ?? '',
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.right,
                              ),
                            ] else if (company != null &&
                                company.companyAddress != null &&
                                company.companyAddress!.isNotEmpty) ...[
                              Text(
                                '${company.companyAddress![0].street ?? ''} ${company.companyAddress![0].num ?? ''}',
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.right,
                              ),
                              Text(
                                '${company.companyAddress![0].zip ?? ''} ${company.companyAddress![0].city ?? ''}',
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.right,
                              ),
                              Text(
                                company.companyAddress![0].country,
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ] else ...[
                            const Text(
                              'Company Name',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const Text(
                              'Address not available',
                              style: TextStyle(fontSize: 8),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                BlocBuilder<CompanyCubit, CompanyState>(
                  builder: (context, companyState) {
                    String? logoUrl =
                        (receiptFooter?.companyLogoURL != null &&
                            receiptFooter!.companyLogoURL!.isNotEmpty)
                        ? receiptFooter.companyLogoURL
                        : null;

                    if (logoUrl == null && companyState is CompanyLoaded) {
                      final companyLogo = companyState.company.companyLogo;
                      if (companyLogo != null && companyLogo.isNotEmpty) {
                        logoUrl = FileService.getImageUrl(companyLogo[0].image);
                      }
                    }

                    if (logoUrl != null && logoUrl.isNotEmpty) {
                      return Image.network(
                        logoUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      );
                    }

                    return const Text(
                      'Sakani',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF00A86B),
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date and Job Info - Fixed Row with proper constraints
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                      Text('Job No:', style: TextStyle(fontSize: 8)),
                      Text('Customer No:', style: TextStyle(fontSize: 8)),
                      Text('Tracking No:', style: TextStyle(fontSize: 8)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(jobData.data?.createdAt),
                        style: TextStyle(fontSize: 8),
                      ),
                      Text(
                        jobData.data?.jobNo ?? 'N/A',
                        style: TextStyle(fontSize: 8),
                      ),
                      Text(
                        customer?.customerNo ?? 'N/A',
                        style: TextStyle(fontSize: 8),
                      ),
                      Text(
                        jobData.data?.jobTrackingNumber ?? 'N/A',
                        style: TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Barcode and job info
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 60,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: List.generate(20, (index) {
                          return Expanded(
                            child: Container(
                              color: index % 2 == 0
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                    Text(
                      jobData.data?.jobNo ?? 'N/A',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Job Receipt Title
            const Text(
              'Job Receipt',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Salutation
            if (jobData.data?.salutationHTMLmarkup != null)
              _buildHtmlContent(jobData.data!.salutationHTMLmarkup!)
            else
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi there,', style: TextStyle(fontSize: 8)),
                  Text(
                    'Thank you for your trust. We are committed to processing your order as quickly as possible.',
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Device Details - Side by side
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    width: 120, // Fixed width for labels
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device details:',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Physical location:',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Job type:',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device != null
                                ? '${device.brand} ${device.model ?? ''}, SN: ${device.serialNo ?? 'N/A'}'
                                : 'Device information not available',
                            style: TextStyle(fontSize: 8),
                          ),
                          SizedBox(height: 4),
                          Text(
                            jobData.data?.physicalLocation ?? 'Not specified',
                            style: TextStyle(fontSize: 8),
                          ),
                          SizedBox(height: 4),
                          Text(
                            jobData.data?.jobTypes ??
                                jobData.data?.jobType ??
                                'N/A',
                            style: TextStyle(fontSize: 8),
                          ),
                          SizedBox(height: 4),
                          Text(
                            defect?.description ?? 'No description provided',
                            style: TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Service Section
            if (services.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Service',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Price',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Service items
                    // ...services.map((service) {
                    //   return Container(
                    //     decoration: BoxDecoration(
                    //       border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    //     ),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(12.0),
                    //       child: Row(
                    //         children: [
                    //           Expanded(
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: [
                    //                 Text(service ?? 'Unnamed Service'),
                    //                 if (service.description != null && service.description!.isNotEmpty)
                    //                   Text(
                    //                     service.description!,
                    //                     style: const TextStyle(fontSize: 12, color: Colors.grey),
                    //                   ),
                    //               ],
                    //             ),
                    //           ),
                    //           SizedBox(
                    //             width: 100,
                    //             child: Text(
                    //               _formatCurrency(service.priceInclVat ?? service.priceExclVat),
                    //               textAlign: TextAlign.right,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   );
                    // }).toList(),

                    // Financial Summary
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildFinancialRow('Subtotal:', formattedSubTotal),
                            if (jobData.data?.vat != null &&
                                jobData.data!.vat! > 0)
                              _buildFinancialRow('VAT:', formattedVat),
                            if (jobData.data?.discount != null &&
                                jobData.data!.discount! > 0)
                              _buildFinancialRow(
                                'Discount:',
                                formattedDiscount,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Total
                    Container(
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                formattedTotal,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Text(
                    'No services added',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Terms and Conditions
            if (jobData.data?.termsAndConditionsHTMLmarkup != null)
              _buildHtmlContent(jobData.data!.termsAndConditionsHTMLmarkup!)
            else
              Text(
                'Terms of service: If the defect is not covered by the manufacturer\'s warranty, I agree to the following.The execution of a paid repair after the creation of a cost estimate at the price of XXX euros including VAT. (Note: If a repair order is subsequently issued, only the actual repair costs according to the cost estimate will be invoiced). I want to be informed before the execution of a paid repair. If I decide against the execution of a repair or if it is not feasible, a handling or inspection fee of XXX euros including VAT will be charged upon return of the device. Note: The repair service within the framework of the manufacturer\'s device warranty is a voluntary service to our customers. For repairs covered by the manufacturer\'s device warranty, there are no costs for the customer. The inspection of the device in the shop can only be superficial. If, upon closer inspection by a professional, it is found that the defect of the device is not covered by the manufacturer\'s device warranty, the repair is chargeable. This applies in particular to damages due to liquid or moisture ingress, impact damages, and proven self-interference. Any warranty claims remain unaffected. The repaired or replaced device must be picked up within 3 months from the date of submission at any shop where it was received. If not collected, the device becomes the property of the client. The device will be stored for another 3 months, after which it will be disposed of or recycled. We assume no liability for data loss or encryption, data stored in the device may be lost. The client is obligated to use the loaned device with care. If the loaned device is damaged or not returned after the completion of the order, the replacement of the respective loaned device plus a processing fee of EUR 50 plus VAT will be invoiced. The terms and conditions of XXXXX apply.',
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              ),
            const SizedBox(height: 24),

            // QR Code placeholder
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Text('QR', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer - Fixed with proper constraints
            BlocBuilder<CompanyCubit, CompanyState>(
              builder: (context, companyState) {
                final company = companyState is CompanyLoaded
                    ? companyState.company
                    : null;

                return Row(
                  spacing: 8, // Horizontal spacing between columns

                  children: [
                    // Company Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company Information',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (receiptFooter?.address != null ||
                              (company != null &&
                                  company.companyName.isNotEmpty)) ...[
                            Text(
                              receiptFooter?.address?.companyName ??
                                  company?.companyName ??
                                  'Company Name',
                              style: const TextStyle(fontSize: 8),
                            ),
                            if (receiptFooter?.address != null) ...[
                              Text(
                                '${receiptFooter!.address!.street ?? ''} ${receiptFooter.address!.num ?? ''}',
                                style: const TextStyle(fontSize: 8),
                              ),
                              Text(
                                '${receiptFooter.address!.zip ?? ''} ${receiptFooter.address!.city ?? ''}',
                                style: const TextStyle(fontSize: 8),
                              ),
                              Text(
                                receiptFooter.address!.country ?? '',
                                style: const TextStyle(fontSize: 8),
                              ),
                            ] else if (company != null &&
                                company.companyAddress != null &&
                                company.companyAddress!.isNotEmpty) ...[
                              Text(
                                '${company.companyAddress![0].street ?? ''} ${company.companyAddress![0].num ?? ''}',
                                style: const TextStyle(fontSize: 8),
                              ),
                              Text(
                                '${company.companyAddress![0].zip ?? ''} ${company.companyAddress![0].city ?? ''}',
                                style: const TextStyle(fontSize: 8),
                              ),
                              Text(
                                company.companyAddress![0].country,
                                style: const TextStyle(fontSize: 8),
                              ),
                            ],
                          ] else
                            const Text(
                              'Address not available',
                              style: TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ),

                    // Contact Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (receiptFooter?.contact != null ||
                              (company != null &&
                                  company.companyContactDetail != null &&
                                  company
                                      .companyContactDetail!
                                      .isNotEmpty)) ...[
                            Text(
                              'CEO: ${receiptFooter?.contact?.ceo ?? (company?.companyTaxDetail?.isNotEmpty == true ? company!.companyTaxDetail![0].ceo : 'N/A')}',
                              style: const TextStyle(fontSize: 8),
                            ),
                            Text(
                              'Tel: ${receiptFooter?.contact?.telephone ?? (company?.companyContactDetail?.isNotEmpty == true ? company!.companyContactDetail![0].telephone : 'N/A')}',
                              style: const TextStyle(fontSize: 8),
                            ),
                            Text(
                              'Email: ${receiptFooter?.contact?.email ?? (company?.companyContactDetail?.isNotEmpty == true ? company!.companyContactDetail![0].email : 'N/A')}',
                              style: const TextStyle(fontSize: 8),
                            ),
                            Text(
                              'Web: ${receiptFooter?.contact?.website ?? (company?.companyContactDetail?.isNotEmpty == true ? company!.companyContactDetail![0].website : 'N/A')}',
                              style: const TextStyle(fontSize: 8),
                            ),
                          ] else if (contact != null) ...[
                            Text(
                              'Tel: ${contact.telephone ?? 'N/A'}',
                              style: const TextStyle(fontSize: 8),
                            ),
                            Text(
                              'Email: ${contact.email ?? 'N/A'}',
                              style: const TextStyle(fontSize: 8),
                            ),
                          ] else
                            const Text(
                              'Contact not available',
                              style: TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ),

                    // Bank Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bank Information',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (receiptFooter?.bank != null ||
                              (company != null &&
                                  company.companyBankDetail != null &&
                                  company.companyBankDetail!.isNotEmpty)) ...[
                            Text(
                              'Bank: ${receiptFooter?.bank?.bankName ?? (company?.companyBankDetail?.isNotEmpty == true ? company!.companyBankDetail![0].bankName : 'N/A')}',
                              style: const TextStyle(fontSize: 8),
                            ),
                            Text(
                              'IBAN: ${receiptFooter?.bank?.iban ?? (company?.companyBankDetail?.isNotEmpty == true ? company!.companyBankDetail![0].iban : 'N/A')}',
                              style: const TextStyle(fontSize: 8),
                            ),
                            Text(
                              'BIC: ${receiptFooter?.bank?.bic ?? (company?.companyBankDetail?.isNotEmpty == true ? company!.companyBankDetail![0].bic : 'N/A')}',
                              style: const TextStyle(fontSize: 8),
                            ),
                          ] else
                            const Text(
                              'Bank details not available',
                              style: TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '€0.00';

    try {
      final numericAmount = double.tryParse(amount.toString()) ?? 0.0;
      return '€${numericAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '€0.00';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildFinancialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHtmlContent(String html) {
    // Simple HTML content parser - you might want to use a proper HTML renderer
    final cleanText = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return Text(
      cleanText,
      style: TextStyle(fontSize: 8, color: Colors.grey[700]),
    );
  }
}

// Keep the PrintSettingsPage class as it was...

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
    if (amount == null) return '£0.00';
    try {
      final numericAmount = double.tryParse(amount.toString()) ?? 0.0;
      return '£${numericAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '£0.00';
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
