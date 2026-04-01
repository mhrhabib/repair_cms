import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter/rendering.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_service_factory.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:repair_cms/features/myJobs/widgets/job_receipt_widget_new.dart';
import 'package:repair_cms/features/company/cubits/company_cubit.dart';
import 'package:repair_cms/core/services/file_service.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:solar_icons/solar_icons.dart';

class ReceiptScreen extends StatelessWidget {
  ReceiptScreen({super.key, required this.job});
  final SingleJobModel job;

  final _settingsService = PrinterSettingsService();

  // Key to capture the on-screen receipt widget for printing
  final GlobalKey _printKey = GlobalKey();

  /// Show printer selection dialog
  Future<void> _showPrinterSelection(BuildContext context) async {
    debugPrint('🖨️ Opening printer selection dialog');

    final allPrinters = _settingsService.getAllPrinters();
    // Show all configured printers so user can choose between A4, Label (Xprinter), or Thermal
    final List<PrinterConfigModel> configuredPrinters = [
      ...allPrinters['a4'] ?? [],
      // ...allPrinters['thermal'] ?? [],
      // ...allPrinters['label'] ?? [],
    ];

    debugPrint('📊 Found ${configuredPrinters.length} A4 printers');

    if (configuredPrinters.isEmpty) {
      SnackbarDemo(
        message:
            'No A4 printers configured. Please configure an A4 printer in Settings > Printer Settings',
      ).showCustomSnackbar(context);
      return;
    }

    // Get default A4 printer
    final defaultA4 = _settingsService.getDefaultPrinter('a4');
    final defaultPrinterType = defaultA4 != null ? 'a4' : null;

    debugPrint('✅ Default printer type: $defaultPrinterType');

    // ignore: use_build_context_synchronously
    await showCupertinoModalPopup<PrinterConfigModel>(
      context: context,
      builder: (context) => _PrinterSelectionDialog(
        printers: configuredPrinters,
        defaultPrinterType: defaultPrinterType,
        onPrint: (printer) => _printReceipt(context, printer),
      ),
    );
  }

  /// Print receipt with selected printer
  Future<void> _printReceipt(
    BuildContext context,
    PrinterConfigModel printer,
  ) async {
    debugPrint(
      '🚀 Starting print job with ${printer.printerBrand} ${printer.printerType}',
    );

    // Generate receipt text from job data
    final receiptText = _generateReceiptText();

    // Capture navigator before async operations
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success = false;
      String? errorMessage;

      // Route to appropriate printer based on type and brand
      if (printer.printerType == 'a4') {
        debugPrint('📄 Printing to A4 printer via system dialog');
        success = await _printA4Receipt(context, targetPrinter: printer);
      } else if (printer.protocol.toLowerCase() == 'usb') {
        // USB printers require special handling
        final usbService = PrinterServiceFactory.getUSBPrinterService();
        final result = await usbService.printThermalReceipt(
          ipAddress: printer.ipAddress,
          text: receiptText,
        );
        success = result.success;
        errorMessage = result.message;
      } else {
        // Network printers - use factory to get appropriate service
        debugPrint(
          '🖨️ Printing to ${printer.printerBrand} ${printer.printerType} printer',
        );
        final printerService = PrinterServiceFactory.getPrinterServiceForConfig(
          printer,
        );

        if (printer.printerType == 'thermal') {
          final result = await printerService.printThermalReceipt(
            ipAddress: printer.ipAddress,
            text: receiptText,
          );
          success = result.success;
          errorMessage = result.message;
        } else if (printer.printerType == 'label') {
          final result = await PrinterServiceFactory.printLabelWithFallback(
            config: printer,
            text: receiptText,
          );
          success = result.success;
          errorMessage = result.message;
        } else {
          errorMessage = 'Unsupported printer type: ${printer.printerType}';
        }
      }

      // Hide loading (use root navigator to match showDialog's default)
      debugPrint('🔄 Attempting to dismiss loading dialog');
      try {
        // Use the captured navigator instead of context which may be unmounted
        navigator.pop();
        debugPrint('✅ Loading dialog dismissed');
      } catch (e) {
        debugPrint('⚠️ Error dismissing dialog: $e');
        // ignore any errors if the dialog was already dismissed
      }

      // Show result
      if (success) {
        debugPrint('✅ Print job completed successfully');
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Receipt printed successfully!')),
        );
      } else {
        debugPrint('❌ Print job failed: $errorMessage');
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMessage ?? 'Print failed')),
        );
      }
    } catch (e) {
      debugPrint('❌ Print error: $e');

      // Hide loading (ensure we pop the root dialog)
      try {
        navigator.pop();
        debugPrint('✅ Loading dialog dismissed (error case)');
      } catch (popError) {
        debugPrint('⚠️ Error dismissing dialog in catch: $popError');
        // ignore any errors if the dialog was already dismissed
      }

      // Show error
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Print error: $e')),
      );
    }
  }

  /// Print to A4 printer using system print dialog
  Future<bool> _printA4Receipt(
    BuildContext context, {
    PrinterConfigModel? targetPrinter,
  }) async {
    try {
      debugPrint('📄 Generating PDF for A4 receipt');
      // Try to capture the on-screen receipt widget as an image and embed that into the PDF
      Uint8List? capturedPng;
      try {
        final boundary =
            _printKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary != null) {
          final pixelRatio = MediaQuery.of(context).devicePixelRatio;
          final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
          final ByteData? byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          capturedPng = byteData?.buffer.asUint8List();
          debugPrint(
            '📷 Captured on-screen receipt: ${capturedPng?.lengthInBytes ?? 0} bytes — image ${image.width}x${image.height} (pixelRatio $pixelRatio)',
          );
        }
      } catch (e) {
        debugPrint('❌ Widget capture failed: $e');
        capturedPng = null;
      }

      if (capturedPng != null) {
        final pdf = pw.Document();
        final pw.ImageProvider img = pw.MemoryImage(capturedPng);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context ctx) {
              return pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain));
            },
          ),
        );

        debugPrint('✅ PDF (from captured image) generated');

        // If printer is configured for raw TCP (jetdirect/9100), try sending PDF bytes directly
        if (targetPrinter != null &&
            [
              'raw',
              'tcp',
              'jetdirect',
              '9100',
            ].contains(targetPrinter.protocol.toLowerCase())) {
          final bytes = await pdf.save();
          final port = targetPrinter.port ?? 9100;
          try {
            debugPrint(
              '🔌 Attempting raw TCP send to ${targetPrinter.ipAddress}:$port',
            );
            final socket = await Socket.connect(
              targetPrinter.ipAddress,
              port,
              timeout: const Duration(seconds: 5),
            );
            socket.add(bytes);
            await socket.flush();
            socket.destroy();
            debugPrint(
              '✅ Sent PDF via raw TCP to ${targetPrinter.ipAddress}:$port',
            );
            return true;
          } catch (e, s) {
            debugPrint('❌ Raw TCP send failed: $e');
            debugPrint('Stack:\n$s');
            // fall through to system dialog fallback
          }
        }

        debugPrint('🖨️ Opening system print dialog (fallback)');

        final printResult = await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Job_Receipt_${job.data?.jobNo ?? "unknown"}.pdf',
          format: PdfPageFormat.a4,
        );

        if (printResult) {
          debugPrint('✅ User completed printing from system dialog (image)');
        } else {
          debugPrint('⚠️ User cancelled print dialog (image)');
        }

        return printResult;
      }

      // Fall back to programmatic PDF build if capture failed
      final pdf = pw.Document();
      final customer = job.data?.customerDetails;
      final device = job.data?.deviceData;
      final List<dynamic> allItems = [
        ...?job.data?.services,
        ...?job.data?.assignedItems,
      ];

      final defect = job.data?.defect?.isNotEmpty == true
          ? job.data!.defect![0]
          : null;
      final receiptFooter = job.data?.receiptFooter;

      // Recalculate subtotal if it's 0 but we have items
      double subTotal = job.data?.subTotal?.toDouble() ?? 0.0;
      if (subTotal == 0 && allItems.isNotEmpty) {
        for (final item in allItems) {
          if (item is Map) {
            final price =
                item['price_incl_vat'] ??
                item['priceInclVat'] ??
                item['salePriceIncVat'] ??
                item['sale_price_inc_vat'] ??
                0;
            subTotal += (price is num ? price.toDouble() : 0.0);
          }
        }
      }

      final discount = job.data?.discount?.toDouble() ?? 0.0;
      final vat = job.data?.vat?.toDouble() ?? 0.0;
      final total = subTotal + vat - discount;

      // Format currency values
      final formattedSubTotal = _formatCurrency(subTotal);
      final formattedTotal = _formatCurrency(total);
      final formattedVat = _formatCurrency(vat);
      final formattedDiscount = _formatCurrency(discount);

      // Load company logo if available
      pw.ImageProvider? logoImage;
      final companyState = context.read<CompanyCubit>().state;
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
        try {
          debugPrint('📷 Loading company logo from: $logoUrl');
          logoImage = await networkImage(logoUrl);
          debugPrint('✅ Company logo loaded successfully');
        } catch (e) {
          debugPrint('❌ Failed to load company logo: $e');
          // Will fall back to text logo
        }
      }

      // Build complete PDF document
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with company info and logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Company address
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (receiptFooter?.address != null ||
                              (companyState is CompanyLoaded &&
                                  companyState
                                      .company
                                      .companyName
                                      .isNotEmpty)) ...[
                            pw.Text(
                              receiptFooter?.address?.companyName ??
                                  (companyState is CompanyLoaded
                                      ? companyState.company.companyName
                                      : 'Company Name'),
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            if (receiptFooter?.address != null) ...[
                              pw.Text(
                                '${receiptFooter!.address!.street ?? ''} ${receiptFooter.address!.num ?? ''}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.Text(
                                '${receiptFooter.address!.zip ?? ''} ${receiptFooter.address!.city ?? ''}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.Text(
                                receiptFooter.address!.country ?? '',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ] else if (companyState is CompanyLoaded &&
                                companyState.company.companyAddress != null &&
                                companyState
                                    .company
                                    .companyAddress!
                                    .isNotEmpty) ...[
                              pw.Text(
                                '${companyState.company.companyAddress![0].street ?? ''} ${companyState.company.companyAddress![0].num ?? ''}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.Text(
                                '${companyState.company.companyAddress![0].zip ?? ''} ${companyState.company.companyAddress![0].city ?? ''}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.Text(
                                companyState.company.companyAddress![0].country,
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ],
                          ] else ...[
                            pw.Text(
                              'Company Name',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'Address not available',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Company Logo
                    pw.Container(
                      width: 70,
                      height: 70,
                      decoration: pw.BoxDecoration(
                        border: logoImage == null
                            ? pw.Border.all(color: PdfColors.grey300)
                            : null,
                      ),
                      child: logoImage != null
                          ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                          : pw.Center(
                              child: pw.Text(
                                'LOGO',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.normal,
                                  color: PdfColors.green,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),

                // Date and Job Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildPdfRow('Date:', _formatDate(job.data?.createdAt)),
                        _buildPdfRow('Job No:', job.data?.jobNo ?? 'N/A'),
                        _buildPdfRow(
                          'Customer No:',
                          customer?.customerNo ?? 'N/A',
                        ),
                        _buildPdfRow(
                          'Tracking No:',
                          job.data?.jobTrackingNumber ?? 'N/A',
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),

                // Barcode placeholder
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    height: 60,
                    width: 100,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          height: 40,
                          child: pw.Row(
                            children: List.generate(20, (index) {
                              return pw.Expanded(
                                child: pw.Container(
                                  color: index % 2 == 0
                                      ? PdfColors.black
                                      : PdfColors.white,
                                ),
                              );
                            }),
                          ),
                        ),
                        pw.Text(
                          job.data?.jobNo ?? 'N/A',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),

                // Job Receipt Title
                pw.Text(
                  'Job Receipt',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),

                // Salutation
                pw.Text('Hi there,', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(
                  'Thank you for your trust. We are committed to processing your order as quickly as possible.',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 8),

                // Device Details
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        width: 120,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Device details:',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Physical location:',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Job type:',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Description:',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey200,
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                device != null
                                    ? '${device.brand} ${device.model ?? ''}, SN: ${device.serialNo ?? 'N/A'}'
                                    : 'Device information not available',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                job.data?.physicalLocation ?? 'Not specified',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                job.data?.jobTypes ??
                                    job.data?.jobType ??
                                    'N/A',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                defect?.description ??
                                    'No description provided',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                // Service Section
                if (allItems.isNotEmpty)
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      children: [
                        // Header
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey200,
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey300),
                            ),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    'Service',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.SizedBox(
                                  width: 100,
                                  child: pw.Text(
                                    'Price',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Service items
                        ...allItems.map((item) {
                          String name = 'Item';
                          double priceValue = 0;

                          if (item is Map) {
                            name =
                                item['productName'] ?? item['name'] ?? 'Item';
                            final p =
                                item['price_incl_vat'] ??
                                item['priceInclVat'] ??
                                item['salePriceIncVat'] ??
                                item['sale_price_inc_vat'] ??
                                0;
                            priceValue = p is num ? p.toDouble() : 0.0;
                          }

                          return pw.Container(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(color: PdfColors.grey300),
                              ),
                            ),
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(
                                      name,
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                                  pw.SizedBox(
                                    width: 100,
                                    child: pw.Text(
                                      _formatCurrency(priceValue),
                                      textAlign: pw.TextAlign.right,
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                        // Financial Summary
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey300),
                            ),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Column(
                              children: [
                                _buildPdfRow('Subtotal:', formattedSubTotal),
                                if (job.data?.vat != null && job.data!.vat! > 0)
                                  _buildPdfRow('VAT:', formattedVat),
                                if (job.data?.discount != null &&
                                    job.data!.discount! > 0)
                                  _buildPdfRow('Discount:', formattedDiscount),
                              ],
                            ),
                          ),
                        ),
                        // Total
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey100,
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    'Total',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.SizedBox(
                                  width: 100,
                                  child: pw.Text(
                                    formattedTotal,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.right,
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
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'No services added',
                        style: const pw.TextStyle(color: PdfColors.grey),
                      ),
                    ),
                  ),
                pw.SizedBox(height: 32),

                // Terms and Conditions
                pw.Text(
                  'Terms of service: If the defect is not covered by the manufacturer\'s warranty, I agree to the following. The execution of a paid repair after the creation of a cost estimate at the price of XXX euros including VAT. (Note: If a repair order is subsequently issued, only the actual repair costs according to the cost estimate will be invoiced). I want to be informed before the execution of a paid repair. If I decide against the execution of a repair or if it is not feasible, a handling or inspection fee of XXX euros including VAT will be charged upon return of the device.',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 24),

                // QR Code placeholder
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 100,
                    height: 100,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'QR',
                        style: const pw.TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
                pw.Spacer(),

                // Footer with company information
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Company Address
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Company Information',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (receiptFooter?.address != null) ...[
                            pw.Text(
                              receiptFooter!.address!.companyName ??
                                  'Company Name',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              '${receiptFooter.address!.street ?? ''} ${receiptFooter.address!.num ?? ''}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              '${receiptFooter.address!.zip ?? ''} ${receiptFooter.address!.city ?? ''}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              receiptFooter.address!.country ?? '',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ] else
                            pw.Text(
                              'Address not available',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    // Contact Information
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Contact Information',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (receiptFooter?.contact != null) ...[
                            pw.Text(
                              'CEO: ${receiptFooter!.contact!.ceo ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              'Tel: ${receiptFooter.contact!.telephone ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              'Email: ${receiptFooter.contact!.email ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              'Web: ${receiptFooter.contact!.website ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ] else
                            pw.Text(
                              'Contact not available',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    // Bank Information
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bank Information',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (receiptFooter?.bank != null) ...[
                            pw.Text(
                              'Bank: ${receiptFooter!.bank!.bankName ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              'IBAN: ${receiptFooter.bank!.iban ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              'BIC: ${receiptFooter.bank!.bic ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ] else
                            pw.Text(
                              'Bank details not available',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      debugPrint('✅ PDF generated');

      // If printer is configured for raw TCP (jetdirect/9100), try sending PDF bytes directly
      if (targetPrinter != null &&
          [
            'raw',
            'tcp',
            'jetdirect',
            '9100',
          ].contains(targetPrinter.protocol.toLowerCase())) {
        final bytes = await pdf.save();
        final port = targetPrinter.port ?? 9100;
        try {
          debugPrint(
            '🔌 Attempting raw TCP send to ${targetPrinter.ipAddress}:$port',
          );
          final socket = await Socket.connect(
            targetPrinter.ipAddress,
            port,
            timeout: const Duration(seconds: 5),
          );
          socket.add(bytes);
          await socket.flush();
          socket.destroy();
          debugPrint(
            '✅ Sent PDF via raw TCP to ${targetPrinter.ipAddress}:$port',
          );
          return true;
        } catch (e, s) {
          debugPrint('❌ Raw TCP send failed: $e');
          debugPrint('Stack:\n$s');
          // fall through to system dialog fallback
        }
      }

      debugPrint('🖨️ Opening system print dialog (fallback)');

      // Show system print dialog and wait for result
      final printResult = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Job_Receipt_${job.data?.jobNo ?? "unknown"}.pdf',
        format: PdfPageFormat.a4,
      );

      // layoutPdf returns true if user printed, false if cancelled
      if (printResult) {
        debugPrint('✅ User completed printing from system dialog');
      } else {
        debugPrint('⚠️ User cancelled print dialog');
      }

      return printResult;
    } catch (e, s) {
      // Log full stack trace to help debugging native/platform errors coming from Printing
      debugPrint('❌ A4 print error: $e');
      debugPrint('Stack trace:\n$s');
      return false;
    }
  }

  /// Helper to build PDF rows
  pw.Widget _buildPdfRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
          pw.Text(
            value,
            style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  /// Test print using hardcoded base64 PDF — routes through saved printers
  Future<void> _testPrintBase64Pdf(BuildContext context) async {
    const rawValue =
        'application/pdf;base64,JVBERi0xLjMKJf////8KOSAwIG9iago8PAovVHlwZSAvRXh0R1N0YXRlCi9jYSAxCj4+CmVuZG9iago4IDAgb2JqCjw8Ci9UeXBlIC9QYWdlCi9QYXJlbnQgMSAwIFIKL01lZGlhQm94IFswIDAgNTk1LjI4MDAyOSA4NDEuODkwMDE1XQovQ29udGVudHMgNiAwIFIKL1Jlc291cmNlcyA3IDAgUgovVXNlclVuaXQgMQo+PgplbmRvYmoKNyAwIG9iago8PAovUHJvY1NldCBbL1BERiAvVGV4dCAvSW1hZ2VCIC9JbWFnZUMgL0ltYWdlSV0KL0V4dEdTdGF0ZSA8PAovR3MxIDkgMCBSCj4+Ci9Gb250IDw8Ci9GMSAxMCAwIFIKL0YyIDEyIDAgUgo+PgovWE9iamVjdCA8PAovSTEgMTEgMCBSCj4+Ci9Db2xvclNwYWNlIDw8Cj4+Cj4+CmVuZG9iagoxNCAwIG9iagoocmVhY3QtcGRmKQplbmRvYmoKMTUgMCBvYmoKKHJlYWN0LXBkZikKZW5kb2JqCjE2IDAgb2JqCihEOjIwMjYwNDAxMTI0NDI5WikKZW5kb2JqCjEzIDAgb2JqCjw8Ci9Qcm9kdWNlciAxNCAwIFIKL0NyZWF0b3IgMTUgMCBSCi9DcmVhdGlvbkRhdGUgMTYgMCBSCj4+CmVuZG9iagoxMCAwIG9iago8PAovVHlwZSAvRm9udAovQmFzZUZvbnQgL0hlbHZldGljYQovU3VidHlwZSAvVHlwZTEKL0VuY29kaW5nIC9XaW5BbnNpRW5jb2RpbmcKPj4KZW5kb2JqCjEyIDAgb2JqCjw8Ci9UeXBlIC9Gb250Ci9CYXNlRm9udCAvSGVsdmV0aWNhLUJvbGQKL1N1YnR5cGUgL1R5cGUxCi9FbmNvZGluZyAvV2luQW5zaUVuY29kaW5nCj4+CmVuZG9iago0IDAgb2JqCjw8Cj4+CmVuZG9iagozIDAgb2JqCjw8Ci9UeXBlIC9DYXRhbG9nCi9QYWdlcyAxIDAgUgovTmFtZXMgMiAwIFIKL1ZpZXdlclByZWZlcmVuY2VzIDUgMCBSCj4+CmVuZG9iagoxIDAgb2JqCjw8Ci9UeXBlIC9QYWdlcwovQ291bnQgMQovS2lkcyBbOCAwIFJdCj4+CmVuZG9iagoyIDAg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MDAwMDAwIDY1NTM1IGYgCjAwMDAwMDA4MzkgMDAwMDAgbiAKMDAwMDAwMDg5NiAwMDAwMCBuIAowMDAwMDAwNzUyIDAwMDAwIG4gCjAwMDAwMDA3MzEgMDAwMDAgbiAKMDAwMDAwMDk0MyAwMDAwMCBuIAowMDAwMDAzNjk4IDAwMDAwIG4gCjAwMDAwMDAxODkgMDAwMDAgbiAKMDAwMDAwMDA1OSAwMDAwMCBuIAowMDAwMDAwMDE1IDAwMDAwIG4gCjAwMDAwMDA1MzAgMDAwMDAgbiAKMDAwMDAwMzM1MyAwMDAwMCBuIAowMDAwMDAwNjI4IDAwMDAwIG4gCjAwMDAwMDA0NTQgMDAwMDAgbiAKMDAwMDAwMDM2MiAwMDAwMCBuIAowMDAwMDAwMzkwIDAwMDAwIG4gCjAwMDAwMDA0MTggMDAwMDAgbiAKMDAwMDAwMDk4NiAwMDAwMCBuIAp0cmFpbGVyCjw8Ci9TaXplIDE4Ci9Sb290IDMgMCBSCi9JbmZvIDEzIDAgUgovSUQgWzwxNTA3ODU5MWViNjA1NTI5NDA4NDEyZDBkODUyNTZjYj4gPDE1MDc4NTkxZWI2MDU1Mjk0MDg0MTJkMGQ4NTI1NmNiPl0KPj4Kc3RhcnR4cmVmCjcxODYKJSVFT0YK';

    final base64String = rawValue.contains(',')
        ? rawValue.split(',').last
        : rawValue;
    final Uint8List pdfBytes = base64Decode(base64String);

    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> configuredPrinters = [
      ...allPrinters['a4'] ?? [],
    ];

    if (configuredPrinters.isEmpty) {
      // No saved printers — fall back to system dialog
      // ignore: use_build_context_synchronously
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'test_web_receipt.pdf',
        format: PdfPageFormat.a4,
      );
      return;
    }

    final defaultA4 = _settingsService.getDefaultPrinter('a4');
    final defaultPrinterType = defaultA4 != null ? 'a4' : null;

    // ignore: use_build_context_synchronously
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _PrinterSelectionDialog(
        printers: configuredPrinters,
        defaultPrinterType: defaultPrinterType,
        onPrint: (printer) => _sendPdfBytesToPrinter(context, pdfBytes, printer),
      ),
    );
  }

  /// Send already-decoded PDF bytes to a selected printer
  Future<void> _sendPdfBytesToPrinter(
    BuildContext context,
    Uint8List pdfBytes,
    PrinterConfigModel printer,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success = false;

      if (['raw', 'tcp', 'jetdirect', '9100']
          .contains(printer.protocol.toLowerCase())) {
        final port = printer.port ?? 9100;
        try {
          final socket = await Socket.connect(
            printer.ipAddress,
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
            name: 'test_web_receipt.pdf',
            format: PdfPageFormat.a4,
          );
        }
      } else {
        success = await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: 'test_web_receipt.pdf',
          format: PdfPageFormat.a4,
        );
      }

      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(success ? 'Test PDF sent to printer!' : 'Print cancelled'),
        ),
      );
    } catch (e) {
      try { navigator.pop(); } catch (_) {}
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Print error: $e')),
      );
    }
  }

  /// Generate receipt text from job data
  String _generateReceiptText() {
    final customer = job.data?.customerDetails;
    final device = job.data?.deviceData;
    final jobNo = job.data?.jobNo ?? 'N/A';
    final total = job.data?.total ?? 0;

    return '''
    ================================
           JOB RECEIPT
    ================================
    
    Job No: $jobNo
    Date: ${_formatDate(job.data?.createdAt)}
    
    Customer:
    ${customer?.firstName ?? 'N/A'} ${customer?.lastName ?? ''}
    Customer No: ${customer?.customerNo ?? 'N/A'}
    
    Device:
    ${device?.brand ?? 'N/A'} ${device?.model ?? ''}
    SN: ${device?.serialNo ?? 'N/A'}
    
    --------------------------------
    Total: €${total.toStringAsFixed(2)}
    --------------------------------
    
    Thank you for your business!
    
    ================================
    ''';
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

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '€0.00';

    try {
      final numericAmount = double.tryParse(amount.toString()) ?? 0.0;
      return '€${numericAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '€0.00';
    }
  }

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

          // Temporary test button — remove after testing
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () => _testPrintBase64Pdf(context),
                child: const Text('Test Base64 PDF Print'),
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
                  CustomNavButton(
                    onPressed: () => _showPrinterSelection(context),
                    icon: SolarIconsOutline.printer,
                    iconColor: AppColors.fontSecondaryColor,
                    size: 24.r,
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
