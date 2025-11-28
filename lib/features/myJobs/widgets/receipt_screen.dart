import 'package:flutter/material.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/brother_printer_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:repair_cms/features/myJobs/widgets/job_receipt_widget_new.dart';

class ReceiptScreen extends StatelessWidget {
  ReceiptScreen({super.key, required this.job});
  final SingleJobModel job;

  final _settingsService = PrinterSettingsService();
  final _brotherPrinterService = BrotherPrinterService();

  /// Show printer selection dialog
  Future<void> _showPrinterSelection(BuildContext context) async {
    debugPrint('🖨️ Opening printer selection dialog');

    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> configuredPrinters = [
      ...allPrinters['thermal'] ?? [],
      ...allPrinters['label'] ?? [],
      ...allPrinters['a4'] ?? [],
    ];

    debugPrint('📊 Found ${configuredPrinters.length} configured printers');

    if (configuredPrinters.isEmpty) {
      showCustomToast(
        'No printers configured. Please configure a printer in Settings > Printer Settings',
        isError: true,
      );
      return;
    }

    // Get default printer
    String? defaultPrinterType;
    final defaultThermal = _settingsService.getDefaultPrinter('thermal');
    final defaultLabel = _settingsService.getDefaultPrinter('label');
    final defaultA4 = _settingsService.getDefaultPrinter('a4');

    if (defaultThermal != null) {
      defaultPrinterType = 'thermal';
    } else if (defaultLabel != null) {
      defaultPrinterType = 'label';
    } else if (defaultA4 != null) {
      defaultPrinterType = 'a4';
    }

    debugPrint('✅ Default printer type: $defaultPrinterType');

    // ignore: use_build_context_synchronously
    final selectedPrinter = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (context) =>
          _PrinterSelectionDialog(printers: configuredPrinters, defaultPrinterType: defaultPrinterType),
    );

    if (selectedPrinter != null && context.mounted) {
      debugPrint('🎯 User selected: ${selectedPrinter.printerBrand} ${selectedPrinter.printerType} printer');
      _printReceipt(context, selectedPrinter);
    }
  }

  /// Print receipt with selected printer
  Future<void> _printReceipt(BuildContext context, PrinterConfigModel printer) async {
    debugPrint('🚀 Starting print job with ${printer.printerBrand} ${printer.printerType}');

    // Generate receipt text from job data
    final receiptText = _generateReceiptText();

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
        success = await _printA4Receipt(context);
      } else if (printer.printerBrand.toLowerCase() == 'brother') {
        debugPrint('🖨️ Printing to Brother ${printer.printerType} printer');
        final result = await _brotherPrinterService.printThermalReceipt(
          ipAddress: printer.ipAddress,
          text: receiptText,
        );
        success = result.success;
        errorMessage = result.message;
      } else {
        errorMessage =
            '${printer.printerBrand} ${printer.printerType} printers not yet supported. Only Brother and A4 (generic) printers are currently supported.';
        debugPrint('❌ $errorMessage');
      }

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show result
      if (context.mounted) {
        if (success) {
          debugPrint('✅ Print job completed successfully');
          showCustomToast('Receipt printed successfully!', isError: false);
        } else {
          debugPrint('❌ Print job failed: $errorMessage');
          showCustomToast(errorMessage ?? 'Print failed', isError: true);
        }
      }
    } catch (e) {
      debugPrint('❌ Print error: $e');

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        showCustomToast('Print error: $e', isError: true);
      }
    }
  }

  /// Print to A4 printer using system print dialog
  Future<bool> _printA4Receipt(BuildContext context) async {
    try {
      debugPrint('📄 Generating PDF for A4 receipt');

      final pdf = pw.Document();
      final customer = job.data?.customerDetails;
      final device = job.data?.deviceData;
      final services = job.data?.services ?? [];
      final defect = job.data?.defect?.isNotEmpty == true ? job.data!.defect![0] : null;
      final receiptFooter = job.data?.receiptFooter;

      // Format currency values
      final formattedSubTotal = _formatCurrency(job.data?.subTotal);
      final formattedTotal = _formatCurrency(job.data?.total);
      final formattedVat = _formatCurrency(job.data?.vat);
      final formattedDiscount = _formatCurrency(job.data?.discount);

      // Load company logo if available
      pw.ImageProvider? logoImage;
      if (receiptFooter?.companyLogoURL != null && receiptFooter!.companyLogoURL!.isNotEmpty) {
        try {
          debugPrint('📷 Loading company logo from: ${receiptFooter.companyLogoURL}');
          logoImage = await networkImage(receiptFooter.companyLogoURL!);
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
                          if (receiptFooter?.address != null) ...[
                            pw.Text(
                              receiptFooter!.address!.companyName ?? 'Company Name',
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '${receiptFooter.address!.street ?? ''} ${receiptFooter.address!.num ?? ''}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              '${receiptFooter.address!.zip ?? ''} ${receiptFooter.address!.city ?? ''}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(receiptFooter.address!.country ?? '', style: const pw.TextStyle(fontSize: 8)),
                          ] else ...[
                            pw.Text('Company Name', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Address not available', style: const pw.TextStyle(fontSize: 8)),
                          ],
                        ],
                      ),
                    ),
                    // Company Logo
                    pw.Container(
                      width: 70,
                      height: 70,
                      decoration: pw.BoxDecoration(
                        border: logoImage == null ? pw.Border.all(color: PdfColors.grey300) : null,
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
                        _buildPdfRow('Customer No:', customer?.customerNo ?? 'N/A'),
                        _buildPdfRow('Tracking No:', job.data?.jobTrackingNumber ?? 'N/A'),
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
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          height: 40,
                          child: pw.Row(
                            children: List.generate(20, (index) {
                              return pw.Expanded(
                                child: pw.Container(color: index % 2 == 0 ? PdfColors.black : PdfColors.white),
                              );
                            }),
                          ),
                        ),
                        pw.Text(job.data?.jobNo ?? 'N/A', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),

                // Job Receipt Title
                pw.Text('Job Receipt', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        width: 120,
                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Device details:',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Physical location:',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text('Job type:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 4),
                            pw.Text('Description:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
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
                                job.data?.jobTypes ?? job.data?.jobType ?? 'N/A',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                defect?.description ?? 'No description provided',
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
                if (services.isNotEmpty)
                  pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                    child: pw.Column(
                      children: [
                        // Header
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey200,
                            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text('Service', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.SizedBox(
                                  width: 100,
                                  child: pw.Text(
                                    'Price',
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Service items (if available in data model)
                        // Note: Add service items here if they're available in the model

                        // Financial Summary
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Column(
                              children: [
                                _buildPdfRow('Subtotal:', formattedSubTotal),
                                if (job.data?.vat != null && job.data!.vat! > 0) _buildPdfRow('VAT:', formattedVat),
                                if (job.data?.discount != null && job.data!.discount! > 0)
                                  _buildPdfRow('Discount:', formattedDiscount),
                              ],
                            ),
                          ),
                        ),
                        // Total
                        pw.Container(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.SizedBox(
                                  width: 100,
                                  child: pw.Text(
                                    formattedTotal,
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                    child: pw.Center(
                      child: pw.Text('No services added', style: const pw.TextStyle(color: PdfColors.grey)),
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
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                    child: pw.Center(child: pw.Text('QR', style: const pw.TextStyle(fontSize: 24))),
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
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                          ),
                          if (receiptFooter?.address != null) ...[
                            pw.Text(
                              receiptFooter!.address!.companyName ?? 'Company Name',
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
                            pw.Text(receiptFooter.address!.country ?? '', style: const pw.TextStyle(fontSize: 8)),
                          ] else
                            pw.Text('Address not available', style: const pw.TextStyle(fontSize: 8)),
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
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
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
                            pw.Text('Contact not available', style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    // Bank Information
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bank Information', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          if (receiptFooter?.bank != null) ...[
                            pw.Text(
                              'Bank: ${receiptFooter!.bank!.bankName ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              'IBAN: ${receiptFooter.bank!.iban ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text('BIC: ${receiptFooter.bank!.bic ?? 'N/A'}', style: const pw.TextStyle(fontSize: 8)),
                          ] else
                            pw.Text('Bank details not available', style: const pw.TextStyle(fontSize: 8)),
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

      debugPrint('✅ PDF generated, opening system print dialog');

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
    } catch (e) {
      debugPrint('❌ A4 print error: $e');
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
          pw.Text(label, style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
          pw.Text(value, style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
        ],
      ),
    );
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Job Receipt'),
        actions: [IconButton(icon: const Icon(Icons.print_outlined), onPressed: () => _showPrinterSelection(context))],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: JobReceiptWidgetNew(jobData: job),
          ),
        ),
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
    final defect = jobData.data?.defect?.isNotEmpty == true ? jobData.data!.defect![0] : null;
    final contact = jobData.data?.contact?.isNotEmpty == true ? jobData.data!.contact![0] : null;
    final receiptFooter = jobData.data?.receiptFooter;

    // Format currency values
    final formattedSubTotal = _formatCurrency(jobData.data?.subTotal);
    final formattedTotal = _formatCurrency(jobData.data?.total);
    final formattedVat = _formatCurrency(jobData.data?.vat);
    final formattedDiscount = _formatCurrency(jobData.data?.discount);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 600), // Add minimum width constraint
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company address from receipt footer
                      if (receiptFooter?.address != null) ...[
                        Text(
                          receiptFooter!.address!.companyName ?? 'Company Name',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          '${receiptFooter.address!.street ?? ''} ${receiptFooter.address!.num ?? ''}',
                          style: const TextStyle(fontSize: 8),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          '${receiptFooter.address!.zip ?? ''} ${receiptFooter.address!.city ?? ''}',
                          style: const TextStyle(fontSize: 8),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          receiptFooter.address!.country ?? '',
                          style: const TextStyle(fontSize: 8),
                          textAlign: TextAlign.right,
                        ),
                      ] else ...[
                        const Text(
                          'Company Name',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                        const Text('Address not available', style: TextStyle(fontSize: 8), textAlign: TextAlign.right),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (receiptFooter?.companyLogoURL != null)
                  Image.network(receiptFooter!.companyLogoURL!, width: 70, height: 70, fit: BoxFit.contain)
                else
                  const Text(
                    'Sakani',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF00A86B),
                      fontStyle: FontStyle.italic,
                    ),
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
                      Text('Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
                      Text('Job No:', style: TextStyle(fontSize: 8)),
                      Text('Customer No:', style: TextStyle(fontSize: 8)),
                      Text('Tracking No:', style: TextStyle(fontSize: 8)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatDate(jobData.data?.createdAt), style: TextStyle(fontSize: 8)),
                      Text(jobData.data?.jobNo ?? 'N/A', style: TextStyle(fontSize: 8)),
                      Text(customer?.customerNo ?? 'N/A', style: TextStyle(fontSize: 8)),
                      Text(jobData.data?.jobTrackingNumber ?? 'N/A', style: TextStyle(fontSize: 8)),
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
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: List.generate(20, (index) {
                          return Expanded(child: Container(color: index % 2 == 0 ? Colors.black : Colors.white));
                        }),
                      ),
                    ),
                    Text(jobData.data?.jobNo ?? 'N/A', style: const TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ),

            // Job Receipt Title
            const Text('Job Receipt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
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
                        Text('Device details:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Physical location:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text('Job type:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text('Description:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500)),
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
                          Text(jobData.data?.physicalLocation ?? 'Not specified', style: TextStyle(fontSize: 8)),
                          SizedBox(height: 4),
                          Text(jobData.data?.jobTypes ?? jobData.data?.jobType ?? 'N/A', style: TextStyle(fontSize: 8)),
                          SizedBox(height: 4),
                          Text(defect?.description ?? 'No description provided', style: TextStyle(fontSize: 8)),
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
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
                child: Column(
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Service', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildFinancialRow('Subtotal:', formattedSubTotal),
                            if (jobData.data?.vat != null && jobData.data!.vat! > 0)
                              _buildFinancialRow('VAT:', formattedVat),
                            if (jobData.data?.discount != null && jobData.data!.discount! > 0)
                              _buildFinancialRow('Discount:', formattedDiscount),
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
                              child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                formattedTotal,
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
                child: const Center(
                  child: Text('No services added', style: TextStyle(color: Colors.grey)),
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
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
                child: const Center(child: Text('QR', style: TextStyle(fontSize: 24))),
              ),
            ),
            const SizedBox(height: 32),

            // Footer - Fixed with proper constraints
            Row(
              spacing: 8, // Horizontal spacing between columns

              children: [
                // Company Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Company Information', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                      if (receiptFooter?.address != null) ...[
                        Text(receiptFooter!.address!.companyName ?? 'Company Name', style: TextStyle(fontSize: 8)),
                        Text(
                          '${receiptFooter.address!.street ?? ''} ${receiptFooter.address!.num ?? ''}',
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(
                          '${receiptFooter.address!.zip ?? ''} ${receiptFooter.address!.city ?? ''}',
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(receiptFooter.address!.country ?? '', style: TextStyle(fontSize: 8)),
                      ] else
                        const Text('Address not available', style: TextStyle(fontSize: 8)),
                    ],
                  ),
                ),

                // Contact Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contact Information', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                      if (receiptFooter?.contact != null) ...[
                        Text('CEO: ${receiptFooter!.contact!.ceo ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                        Text('Tel: ${receiptFooter.contact!.telephone ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                        Text('Email: ${receiptFooter.contact!.email ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                        Text('Web: ${receiptFooter.contact!.website ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                      ] else if (contact != null) ...[
                        Text('Tel: ${contact.telephone ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                        Text('Email: ${contact.email ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                      ] else
                        const Text('Contact not available', style: TextStyle(fontSize: 8)),
                    ],
                  ),
                ),

                // Bank Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bank Information', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                      if (receiptFooter?.bank != null) ...[
                        Text('Bank: ${receiptFooter!.bank!.bankName ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                        Text('IBAN: ${receiptFooter.bank!.iban ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                        Text('BIC: ${receiptFooter.bank!.bic ?? 'N/A'}', style: TextStyle(fontSize: 8)),
                      ] else
                        const Text('Bank details not available', style: TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
              ],
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
    return Text(cleanText, style: TextStyle(fontSize: 8, color: Colors.grey[700]));
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Print Settings'),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
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
                        const Text('Job Receipt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            'Job No: ${widget.jobData.data?.jobNo ?? 'N/A'}\n'
                            'Customer: ${widget.jobData.data?.customerDetails?.firstName ?? 'N/A'} ${widget.jobData.data?.customerDetails?.lastName ?? ''}\n'
                            'Device: ${widget.jobData.data?.deviceData?.brand ?? 'N/A'} ${widget.jobData.data?.deviceData?.model ?? ''}\n'
                            'Total: ${_formatCurrency(widget.jobData.data?.total)}\n\n'
                            'This is a preview of the job receipt.',
                            style: TextStyle(fontSize: 6, color: Colors.grey[700]),
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
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
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
                _buildSettingTile(title: 'Printer', value: 'Not selected', onTap: () {}),
                const SizedBox(height: 16),
                _buildSettingTile(
                  title: 'Copies',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: copies > 1 ? () => setState(() => copies--) : null,
                      ),
                      Text('$copies', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => copies++)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingTile(
                  title: 'Orientation',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildOrientationButton(false), const SizedBox(width: 8), _buildOrientationButton(true)],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDropdownTile('Pages', selectedPages, () {})),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDropdownTile('Color', selectedColor, () {})),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDropdownTile('Paper size', selectedPaperSize, () {})),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDropdownTile('Print type', selectedPrintType, () {})),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print initiated')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text(
                  'Print',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildSettingTile({required String title, String? value, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing:
            trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value ?? '', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Icon(Icons.expand_more, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500),
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
          border: Border.all(color: isSelected ? Colors.green : Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            width: portrait ? 20 : 30,
            height: portrait ? 30 : 20,
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.white : Colors.grey[400]!, width: 2),
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

  const _PrinterSelectionDialog({required this.printers, this.defaultPrinterType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Printer'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: printers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final printer = printers[index];
            final isDefault = printer.printerType == defaultPrinterType;

            return ListTile(
              leading: Icon(_getPrinterIcon(printer.printerType), color: Colors.blue, size: 32),
              title: Text(_getPrinterTitle(printer.printerType), style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(printer.printerModel ?? 'Unknown Model'),
                  Text(printer.ipAddress, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).pop(printer),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
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
