import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/services/file_service.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/routes/route_names.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart' as job_booking;
import 'package:repair_cms/features/myJobs/models/single_job_model.dart' as my_jobs;
import 'package:repair_cms/features/myJobs/widgets/job_receipt_widget_new.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_service_factory.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/features/moreSettings/labelContent/service/label_content_settings_service.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';
import 'package:flutter/rendering.dart';
import 'package:repair_cms/features/jobBooking/services/escpos_generator_service.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:solar_icons/solar_icons.dart';

class JobReceiptPreviewScreen extends StatefulWidget {
  final job_booking.CreateJobResponse jobResponse;
  final String printOption; // 'A4 Receipt', 'Thermal Receipt', 'Device Label'

  const JobReceiptPreviewScreen({super.key, required this.jobResponse, required this.printOption});

  @override
  State<JobReceiptPreviewScreen> createState() => _JobReceiptPreviewScreenState();
}

class _JobReceiptPreviewScreenState extends State<JobReceiptPreviewScreen> {
  final _settingsService = PrinterSettingsService();
  final _labelContentService = LabelContentSettingsService();
  my_jobs.SingleJobModel? _completeJobData;
  bool _isLoadingCompleteData = false;
  late LabelContentSettings _labelSettings;
  final GlobalKey _receiptKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchCompleteJobData();
    _labelSettings = _labelContentService.getSettings();
  }

  Future<void> _fetchCompleteJobData() async {
    final jobId = widget.jobResponse.data?.sId;
    if (jobId == null || jobId.isEmpty) return;
    setState(() => _isLoadingCompleteData = true);
    context.read<JobCubit>().getJobById(jobId);
  }

  // ─── Shared data getters (used by label section) ───────────────────────────

  String _getJobNumber() => widget.jobResponse.data?.jobNo?.toString() ?? 'N/A';

  String _getDeviceName() {
    final device = widget.jobResponse.data?.device?.firstOrNull;
    if (device != null) {
      return '${device.brand ?? ''} ${device.model ?? ''}'.trim();
    }
    return 'Device';
  }

  String _getDeviceIMEI() => widget.jobResponse.data?.device?.firstOrNull?.imei ?? '';

  String _getDeviceSerialNumber() => widget.jobResponse.data?.device?.firstOrNull?.serialNo ?? '';

  String _getCustomerName() {
    final contact = widget.jobResponse.data?.contact?.firstOrNull;
    if (contact != null) {
      return '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
    }
    return 'Customer';
  }

  String _getDefect() {
    final defect = widget.jobResponse.data?.defect?.firstOrNull;
    if (defect != null && defect.defect != null && defect.defect!.isNotEmpty) {
      return defect.defect!.map((d) => d.value).join(', ');
    }
    return 'N/A';
  }

  String _getPhysicalLocation() => widget.jobResponse.data?.physicalLocation ?? 'N/A';

  String _getQRCodeData() => widget.jobResponse.data?.sId ?? '';

  String _getBarcodeData() => _getJobNumber().replaceAll(RegExp(r'[^0-9]'), '').padLeft(13, '0');

  // ──────────────────────────────────────────────────────────────────────────
  // Print Options Bottom Sheet
  // ──────────────────────────────────────────────────────────────────────────

  void _showPrintOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PrintOptionsSheet(
        onPrintLabel: () {
          Navigator.of(ctx).pop();
          _handleLabelPrint();
        },
        onPrintReceipt: () {
          Navigator.of(ctx).pop();
          _handleReceiptPrint();
        },
      ),
    );
  }

  // ─── Label print ───────────────────────────────────────────────────────────

  Future<void> _handleLabelPrint() async {
    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> labelPrinters = allPrinters['label'] ?? [];

    if (labelPrinters.isEmpty) {
      showCustomToast('No label printers configured', isError: true);
      return;
    }

    if (labelPrinters.length == 1) {
      await _printLabel(labelPrinters.first);
      return;
    }

    final selectedPrinter = await showCupertinoModalPopup<PrinterConfigModel>(
      context: context,
      builder: (_) => _PrinterPickerSheet(title: 'Select Label Printer', printers: labelPrinters),
    );
    if (selectedPrinter != null) await _printLabel(selectedPrinter);
  }

  Future<void> _printLabel(PrinterConfigModel printer) async {
    try {
      SnackbarDemo(message: 'Preparing label...').showCustomSnackbar(context);

      final labelData = {
        'jobNumber': _getJobNumber(),
        'customerName': _getCustomerName(),
        'deviceName': _getDeviceName(),
        'imei': _getDeviceIMEI(),
        'defect': _getDefect(),
        'location': _getPhysicalLocation(),
        'jobId': widget.jobResponse.data?.sId ?? 'N/A',
      };

      SnackbarDemo(message: 'Sending to printer...').showCustomSnackbar(context);

      final canPrintImage = printer.printerType == 'label';
      if (canPrintImage) {
        final imageBytes = await _captureLabelAsImage(printer);
        if (imageBytes == null) {
          throw Exception('Failed to capture label image');
        }

        final imageResult = await PrinterServiceFactory.printLabelImageWithFallback(
          config: printer,
          imageBytes: imageBytes,
        );

        if (imageResult.success) {
          SnackbarDemo(message: imageResult.message).showCustomSnackbar(context);
          return;
        }

        final labelText = _buildLabelText();
        final textResult = await PrinterServiceFactory.printLabelWithFallback(config: printer, text: labelText);
        if (textResult.success) {
          SnackbarDemo(message: textResult.message).showCustomSnackbar(context);
        } else {
          throw Exception(textResult.message);
        }
      } else {
        final result = await PrinterServiceFactory.printDeviceLabelWithFallback(config: printer, labelData: labelData);
        if (result.success) {
          SnackbarDemo(message: result.message).showCustomSnackbar(context);
        } else {
          throw Exception(result.message);
        }
      }
    } catch (e) {
      SnackbarDemo(message: 'Print failed: $e').showCustomSnackbar(context);
    }
  }

  String _buildLabelText() {
    final buffer = StringBuffer();
    buffer.writeln('*** DEVICE LABEL ***');
    buffer.writeln('JOB: ${_getJobNumber()}');
    buffer.writeln('CUSTOMER: ${_getCustomerName()}');
    buffer.writeln('DEVICE: ${_getDeviceName()}');
    buffer.writeln('IMEI: ${_getDeviceIMEI()}');
    buffer.writeln('DEFECT: ${_getDefect()}');
    buffer.writeln('LOCATION: ${_getPhysicalLocation()}');
    buffer.writeln('ID: ${widget.jobResponse.data?.sId ?? 'N/A'}');
    return buffer.toString();
  }

  // ─── Receipt print ─────────────────────────────────────────────────────────

  Future<void> _handleReceiptPrint() async {
    final allPrinters = _settingsService.getAllPrinters();

    List<PrinterConfigModel> configuredPrinters;
    String printerTypeLabel;

    if (widget.printOption == 'Thermal Receipt') {
      configuredPrinters = allPrinters['thermal'] ?? [];
      printerTypeLabel = 'thermal';
    } else if (widget.printOption == 'Device Label') {
      configuredPrinters = allPrinters['label'] ?? [];
      printerTypeLabel = 'label';
    } else {
      configuredPrinters = allPrinters['a4'] ?? [];
      printerTypeLabel = 'A4';
    }

    if (configuredPrinters.isEmpty) {
      final shouldDiscover = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('No $printerTypeLabel Printers Configured'),
          content: Text('No $printerTypeLabel printers configured. Search for printers on your network?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Search')),
          ],
        ),
      );
      if (shouldDiscover == true && mounted) _discoverPrinters();
      return;
    }

    String? defaultPrinterType = widget.printOption == 'Thermal Receipt'
        ? 'thermal'
        : widget.printOption == 'Device Label'
        ? 'label'
        : 'a4';

    final selectedPrinter = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (_) => _PrinterSelectionDialog(printers: configuredPrinters, defaultPrinterType: defaultPrinterType),
    );

    if (selectedPrinter != null && mounted) {
      _printReceipt(selectedPrinter);
    }
  }

  Future<void> _printReceipt(PrinterConfigModel printer) async {
    debugPrint('🚀 Starting print job with ${printer.printerBrand} ${printer.printerType}');

    try {
      if (printer.printerType == 'thermal') {
        SnackbarDemo(message: 'Generating thermal receipt...').showCustomSnackbar(context);

        final jobDataMap = _convertToSingleJobModel().toJson()['data'];
        if (jobDataMap == null) throw Exception('Failed to prepare job data');

        final bytes = EscPosGeneratorService.generateThermalReceipt(
          jobData: jobDataMap,
          paperWidth: printer.paperWidth ?? 80,
        );

        SnackbarDemo(message: 'Sending to thermal printer...').showCustomSnackbar(context);
        final result = await PrinterServiceFactory.printRawEscPos(config: printer, escposBytes: bytes);

        if (result.success) {
          SnackbarDemo(message: 'Print successful!').showCustomSnackbar(context);
        } else {
          throw Exception(result.message);
        }
      } else if (printer.printerType == 'label') {
        await _printLabel(printer);
      } else {
        // A4 printer
        SnackbarDemo(message: 'Preparing A4 PDF...').showCustomSnackbar(context);

        final imageBytes = await _captureReceiptAsImage();
        if (imageBytes == null) throw Exception('Failed to capture receipt image');

        final a4Service = PrinterServiceFactory.getA4NetworkPrinterService();
        final pdfBytes = await a4Service.generatePdfFromImage(imageBytes: imageBytes);

        SnackbarDemo(message: 'Sending to A4 printer...').showCustomSnackbar(context);
        final result = await a4Service.printA4Receipt(
          ipAddress: printer.ipAddress,
          pdfBytes: pdfBytes,
          port: printer.port ?? 9100,
        );

        if (result.success) {
          SnackbarDemo(message: 'Print successful!').showCustomSnackbar(context);
        } else {
          throw Exception(result.message);
        }
      }
    } catch (e) {
      debugPrint('❌ Print error: $e');
      SnackbarDemo(message: 'Print failed: $e').showCustomSnackbar(context);
    }
  }

  Future<Uint8List?> _captureReceiptAsImage() async {
    try {
      final boundary = _receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Use high pixel ratio for A4 quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Error capturing receipt: $e');
      return null;
    }
  }

  Future<void> _discoverPrinters() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Searching for printers...')],
            ),
          ),
        ),
      ),
    );
    try {
      final discoveredPrinters = await _scanForNetworkPrinters();
      if (mounted) Navigator.of(context).pop();
      if (discoveredPrinters.isEmpty) {
        if (mounted) {
          SnackbarDemo(message: 'No printers found on the network.').showCustomSnackbar(context);
        }
        return;
      }
      if (mounted) {
        final selectedPrinter = await showDialog<Map<String, String>>(
          context: context,
          builder: (_) => _DiscoveredPrintersDialog(printers: discoveredPrinters),
        );
        if (selectedPrinter != null && mounted) {
          _configurePrinter(selectedPrinter);
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        SnackbarDemo(message: 'Failed to discover printers: ${e.toString()}').showCustomSnackbar(context);
      }
    }
  }

  Future<List<Map<String, String>>> _scanForNetworkPrinters() async {
    final List<Map<String, String>> discoveredPrinters = [];
    try {
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();
      if (wifiIP == null) return discoveredPrinters;
      final ipParts = wifiIP.split('.');
      if (ipParts.length != 4) return discoveredPrinters;
      final networkPrefix = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';
      final printerPorts = [9100, 515, 631];
      for (int i = 1; i <= 254; i++) {
        final ip = '$networkPrefix.$i';
        if (ip == wifiIP) continue;
        for (final port in printerPorts) {
          try {
            final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 100));
            socket.destroy();
            discoveredPrinters.add({'ip': ip, 'port': port.toString(), 'name': 'Printer at $ip'});
            break;
          } catch (_) {
            continue;
          }
        }
      }
    } catch (_) {}
    return discoveredPrinters;
  }

  Future<void> _configurePrinter(Map<String, String> printerInfo) async {
    final config = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (_) => _PrinterConfigurationDialog(printerInfo: printerInfo),
    );
    if (config != null) {
      try {
        await _settingsService.savePrinterConfig(config);
        if (mounted) {
          SnackbarDemo(message: 'Printer configured successfully!').showCustomSnackbar(context);
          _handleReceiptPrint();
        }
      } catch (_) {
        if (mounted) {
          SnackbarDemo(message: 'Failed to save printer configuration').showCustomSnackbar(context);
        }
      }
    }
  }

  // ─── Convert job response to SingleJobModel ────────────────────────────────

  my_jobs.SingleJobModel _convertToSingleJobModel() {
    final data = widget.jobResponse.data;
    final jobBookingCubit = context.read<JobBookingCubit>();
    final jobBookingState = jobBookingCubit.state;

    job_booking.ReceiptFooter? receiptFooterFromCubit;
    job_booking.CustomerDetails? customerDetailsFromCubit;
    String? salutationFromCubit;
    String? termsFromCubit;

    if (jobBookingState is JobBookingData) {
      receiptFooterFromCubit = jobBookingState.job.receiptFooter;
      customerDetailsFromCubit = jobBookingState.job.customerDetails;
      salutationFromCubit = jobBookingState.job.salutationHTMLmarkup;
      termsFromCubit = jobBookingState.job.termsAndConditionsHTMLmarkup;
    }

    final finalSalutation = data?.salutationHTMLmarkup ?? salutationFromCubit;
    final finalTerms = data?.termsAndConditionsHTMLmarkup ?? termsFromCubit;

    // Helper to pick the first non-empty value
    String pick(String? resp, String? cubit, [String fallback = '']) {
      if (resp != null && resp.trim().isNotEmpty) return resp;
      if (cubit != null && cubit.trim().isNotEmpty) return cubit;
      return fallback;
    }

    final respFooter = data?.receiptFooter;
    final cubitFooter = receiptFooterFromCubit;

    // Get current logged-in user for the "Agent" field
    final userData = storage.read('user');
    List<my_jobs.LoggedUser>? agentUser;
    if (userData != null) {
      final userMap = userData is String ? jsonDecode(userData) : userData;
      agentUser = [
        my_jobs.LoggedUser(fullName: userMap['fullName'] ?? userMap['name'] ?? 'N/A', email: userMap['email'] ?? ''),
      ];
    }

    final List<Map<String, dynamic>> combinedItems = [];

    if (data?.assignedItems != null) {
      for (final item in data!.assignedItems!) {
        combinedItems.add({
          'productName': item.productName ?? 'Item',
          'name': item.productName ?? 'Item',
          'price_incl_vat': item.salePriceIncVat ?? 0,
        });
      }
    }

    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    final calculatedSubTotal = [
      ...?data?.services?.map((s) => parsePrice(s.priceInclVat)),
      ...combinedItems.map((item) => parsePrice(item['price_incl_vat'])),
    ].fold(0.0, (sum, val) => sum + val);

    final customerDetails = data?.customerDetails ?? customerDetailsFromCubit;

    return my_jobs.SingleJobModel(
      success: widget.jobResponse.success,
      data: my_jobs.Data(
        sId: data?.sId,
        jobType: data?.jobType,
        jobTypes: data?.jobType,
        model: data?.model,
        deviceId: data?.deviceId,
        jobContactId: data?.jobContactId,
        defectId: data?.defectId,
        physicalLocation: data?.physicalLocation,
        emailConfirmation: data?.emailConfirmation,
        files: data?.files?.map((f) => my_jobs.File(id: f.id, file: f.file, fileName: null, size: null)).toList(),
        signatureFilePath: (data?.signatureFilePath != null && data!.signatureFilePath!.isNotEmpty)
            ? data.signatureFilePath
            : (jobBookingState is JobBookingData ? jobBookingState.job.signatureFilePath : null),
        printOption: data?.printOption,
        printDeviceLabel: data?.printDeviceLabel,
        jobStatus: data?.jobStatus
            ?.map(
              (js) => my_jobs.JobStatus(
                title: js.title,
                userId: js.userId,
                colorCode: js.colorCode,
                userName: js.userName,
                createAtStatus: js.createAtStatus,
                notifications: js.notifications,
                notes: js.notes,
              ),
            )
            .toList(),
        userId: data?.userId,
        createdAt: data?.createdAt,
        updatedAt: data?.updatedAt,
        services: data?.services,
        assignedItems: combinedItems,
        device: data?.device
            ?.map(
              (d) => my_jobs.Device(
                sId: d.sId,
                brand: d.brand,
                model: d.model,
                condition: d.condition?.map((c) => my_jobs.Condition(value: c.value, id: c.id)).toList(),
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        contact: data?.contact
            ?.map(
              (c) => my_jobs.Contact(
                sId: c.sId,
                type: c.type,
                salutation: c.salutation,
                firstName: c.firstName,
                lastName: c.lastName,
                telephone: c.telephone,
                email: c.email,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              ),
            )
            .toList(),
        defect: data?.defect
            ?.map(
              (d) => my_jobs.Defect(
                sId: d.sId,
                defect: d.defect?.map((item) => my_jobs.DefectItem(value: item.value, id: item.id)).toList(),
                description: d.description,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        jobNo: data?.jobNo ?? data?.model ?? data?.sId ?? 'N/A',
        total: calculatedSubTotal,
        subTotal: calculatedSubTotal,
        vat: 0.0,
        discount: 0.0,
        jobTrackingNumber: _completeJobData?.data?.jobTrackingNumber ?? data?.jobTrackingNumber ?? data?.jobNo,
        receiptFooter: my_jobs.ReceiptFooter(
          companyLogo: pick(respFooter?.companyLogo, cubitFooter?.companyLogo),
          companyLogoURL: FileService.getImageUrl(pick(respFooter?.companyLogoURL, cubitFooter?.companyLogoURL)),
          address: my_jobs.Address(
            companyName: pick(
              respFooter?.address.companyName,
              cubitFooter?.address.companyName,
              storage.read('companyName') ?? '',
            ),
            street: pick(respFooter?.address.street, cubitFooter?.address.street),
            num: pick(respFooter?.address.num, cubitFooter?.address.num),
            zip: pick(respFooter?.address.zip, cubitFooter?.address.zip),
            city: pick(respFooter?.address.city, cubitFooter?.address.city),
            country: pick(respFooter?.address.country, cubitFooter?.address.country),
          ),
          contact: my_jobs.ContactInfo(
            ceo: pick(respFooter?.contact.ceo, cubitFooter?.contact.ceo),
            telephone: pick(respFooter?.contact.telephone, cubitFooter?.contact.telephone),
            email: pick(respFooter?.contact.email, cubitFooter?.contact.email),
            website: pick(respFooter?.contact.website, cubitFooter?.contact.website),
          ),
          bank: my_jobs.Bank(
            bankName: pick(respFooter?.bank.bankName, cubitFooter?.bank.bankName),
            iban: pick(respFooter?.bank.iban, cubitFooter?.bank.iban),
            bic: pick(respFooter?.bank.bic, cubitFooter?.bank.bic),
          ),
        ),
        customerDetails: customerDetails != null
            ? my_jobs.CustomerDetails(
                customerId: customerDetails.customerId,
                type: customerDetails.type,
                type2: customerDetails.type2,
                organization: customerDetails.organization,
                customerNo: customerDetails.customerNo,
                email: customerDetails.email,
                telephone: customerDetails.telephone,
                telephonePrefix: customerDetails.telephonePrefix,
                salutation: customerDetails.salutation,
                firstName: customerDetails.firstName,
                lastName: customerDetails.lastName,
                position: customerDetails.position,
                vatNo: customerDetails.vatNo,
                reverseCharge: customerDetails.reverseCharge,
                billingAddress: my_jobs.BillingAddress(
                  street: '${customerDetails.billingAddress.street ?? ''} ${customerDetails.billingAddress.no ?? ''}'
                      .trim(),
                  zip: customerDetails.billingAddress.zip,
                  city: customerDetails.billingAddress.city,
                  state: customerDetails.billingAddress.state,
                  country: customerDetails.billingAddress.country,
                ),
                shippingAddress: my_jobs.ShippingAddress(
                  street: '${customerDetails.shippingAddress.street ?? ''} ${customerDetails.shippingAddress.no ?? ''}'
                      .trim(),
                  zip: customerDetails.shippingAddress.zip,
                  city: customerDetails.shippingAddress.city,
                  country: customerDetails.shippingAddress.country,
                ),
              )
            : null,
        salutationHTMLmarkup: finalSalutation,
        termsAndConditionsHTMLmarkup: finalTerms,
        loggedUserId: agentUser,
      ),
    );
  }

  // ─── Label image capture (from JobDeviceLabelScreen) ──────────────────────

  double _getDotsPerMm(PrinterConfigModel? printer) {
    final model = printer?.printerModel?.toUpperCase() ?? '';
    if (model.startsWith('TD-4')) return 11.811;
    if (model.contains('TD-2350')) return 11.82;
    if (model.startsWith('TD-2')) return 8.0;
    if (printer?.printerBrand.toLowerCase() == 'xprinter') return 8.0;
    return 8.0;
  }

  Future<Uint8List?> _captureLabelAsImage(PrinterConfigModel printer) async {
    try {
      final labelWidthMm = printer.labelSize?.width ?? 50;
      final labelHeightMm = printer.labelSize?.height ?? 26;
      final dotsPerMm = _getDotsPerMm(printer);
      final widthPx = (labelWidthMm * dotsPerMm).round();
      final heightPx = (labelHeightMm * dotsPerMm).round();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()));

      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()), bgPaint);

      final bool isBrother = printer.printerBrand.toLowerCase() == 'brother';
      final double offsetX = isBrother ? 50.0 : 0.0;
      final double offsetY = isBrother ? 50.0 : 0.0;
      if (offsetX > 0 || offsetY > 0) canvas.translate(offsetX, offsetY);

      final drawableWidth = widthPx - offsetX;
      final drawableHeight = heightPx - offsetY;
      final padding = drawableWidth * 0.02;
      final contentWidth = drawableWidth - (padding * 2);
      final barcodeWidth = contentWidth * 0.65;
      final barcodeHeight = drawableHeight * 0.24;
      final qrSize = contentWidth * 0.22;

      final barcodeData = _getBarcodeData();
      if (_labelSettings.showBarcode) {
        _drawBarcode(canvas, barcodeData, padding, padding, barcodeWidth, barcodeHeight);
      }

      final double baseFontSize = (drawableHeight * 0.075).clamp(18.0, 26.0);
      final double lineSpacing = baseFontSize + 3.0;
      double currentY = padding;

      if (_labelSettings.showBarcode) {
        currentY = padding + barcodeHeight + 4;
        if (_labelSettings.showJobNo) {
          final tp = TextPainter(
            text: TextSpan(
              text: _getJobNumber(),
              style: TextStyle(color: Colors.black, fontSize: baseFontSize, fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout(maxWidth: barcodeWidth);
          tp.paint(canvas, Offset(padding + (barcodeWidth - tp.width) / 2, currentY));
          currentY += lineSpacing;
        }
      } else if (_labelSettings.showJobNo) {
        final tp = TextPainter(
          text: TextSpan(
            text: _getJobNumber(),
            style: TextStyle(color: Colors.black, fontSize: baseFontSize, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: contentWidth);
        tp.paint(canvas, Offset(padding, padding));
        currentY = padding + lineSpacing;
      }

      if (_labelSettings.showJobQR || _labelSettings.showTrackingPortalQR) {
        final qrPainter = QrPainter(
          data: _labelSettings.showJobQR
              ? _getQRCodeData()
              : 'https://tracking.portal/${widget.jobResponse.data?.sId ?? ''}',
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
        );
        final qrX = drawableWidth - padding - qrSize;
        canvas.save();
        canvas.translate(qrX, padding);
        canvas.scale(qrSize / 200);
        qrPainter.paint(canvas, const Size(200, 200));
        canvas.restore();
        final qrBottomY = padding + qrSize;
        if (qrBottomY > currentY) currentY = qrBottomY;
      }

      currentY += 8;
      final List<String> textLines = [];
      if (_labelSettings.showCustomerName || _labelSettings.showModelBrand) {
        final line = [
          if (_labelSettings.showCustomerName) _getCustomerName(),
          if (_labelSettings.showModelBrand) _getDeviceName(),
        ].where((e) => e.isNotEmpty).join(' | ');
        if (line.isNotEmpty) textLines.add(line);
      }
      if (_labelSettings.showModelBrand) {
        textLines.add('IMEI: ${_getDeviceIMEI()}');
      }
      if (_labelSettings.showSymptom || _labelSettings.showPhysicalLocation) {
        final line = [
          if (_labelSettings.showSymptom) _getDefect(),
          if (_labelSettings.showPhysicalLocation) 'BOX: ${_getPhysicalLocation()}',
        ].where((e) => e.isNotEmpty).join(' | ');
        if (line.isNotEmpty) textLines.add(line);
      }

      for (int i = 0; i < textLines.length; i++) {
        final lp = TextPainter(
          text: TextSpan(
            text: textLines[i],
            style: TextStyle(color: Colors.black, fontSize: baseFontSize, fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        );
        lp.layout(maxWidth: contentWidth);
        lp.paint(canvas, Offset(padding, currentY + (i * lineSpacing)));
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(widthPx, heightPx);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Error generating label image: $e');
      return null;
    }
  }

  void _drawBarcode(Canvas canvas, String data, double x, double y, double width, double height) {
    final barcodeGen = Barcode.code128();
    final elements = barcodeGen.make(data, width: width, height: height, drawText: false);
    final blackPaint = Paint()..color = Colors.black;
    for (final element in elements) {
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(Rect.fromLTWH(x + element.left, y + element.top, element.width, element.height), blackPaint);
      }
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobDetailSuccess) {
          setState(() {
            _completeJobData = state.job;
            _isLoadingCompleteData = false;
          });
        } else if (state is JobError) {
          setState(() => _isLoadingCompleteData = false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
          leading: CustomNavButton(
            onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName(RouteNames.home)),
            icon: CupertinoIcons.back,
          ),
          title: Text(
            'Receipt Preview',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          centerTitle: true,
          actions: [
            // Print button — opens bottom sheet chooser
            GestureDetector(
              onTap: _showPrintOptionsSheet,
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(CupertinoIcons.printer_fill, color: AppColors.primary, size: 20.sp),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─ Section header: Job Receipt ──────────────────────────────
              // _SectionHeader(
              //   icon: Icons.receipt_long_rounded,
              //   label: 'Job Receipt',
              //   color: AppColors.primary,
              // ),
              SizedBox(height: 10.h),

              // ─ Receipt card ─────────────────────────────────────────────
              _buildReceiptCard(),

              SizedBox(height: 24.h),

              // ─ Section header: Device Label ─────────────────────────────
              _SectionHeader(
                icon: Icons.label_important_rounded,
                label: 'Device Label',
                color: const Color(0xFF6C63FF),
              ),
              SizedBox(height: 10.h),

              // ─ Device label card ─────────────────────────────────────────
              _buildDeviceLabelCard(),

              SizedBox(height: 36.h),
            ],
          ),
        ),

        // Floating Print Button at the bottom
      ),
    );
  }

  Widget _buildReceiptCard() {
    final jobModel = _convertToSingleJobModel();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 650.h),
            child: RepaintBoundary(
              key: _receiptKey,
              child: JobReceiptWidgetNew(isPreview: true, jobData: jobModel),
            ),
          ),
          if (_isLoadingCompleteData)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 12.h),
                      Text(
                        'Loading tracking number...',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceLabelCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barcode + QR row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_labelSettings.showBarcode || _labelSettings.showJobNo)
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_labelSettings.showBarcode)
                          SizedBox(
                            height: 60.h,
                            child: BarcodeWidget(barcode: Barcode.code128(), data: _getBarcodeData(), drawText: false),
                          ),
                        if (_labelSettings.showBarcode && _labelSettings.showJobNo) SizedBox(height: 8.h),
                        if (_labelSettings.showJobNo)
                          Text(
                            _getJobNumber(),
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                      ],
                    ),
                  ),
                if ((_labelSettings.showBarcode || _labelSettings.showJobNo) &&
                    (_labelSettings.showJobQR || _labelSettings.showTrackingPortalQR))
                  SizedBox(width: 16.w),
                if (_labelSettings.showJobQR || _labelSettings.showTrackingPortalQR)
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80.h,
                          child: QrImageView(
                            data: _labelSettings.showJobQR
                                ? _getQRCodeData()
                                : 'https://tracking.portal/${widget.jobResponse.data?.sId ?? ''}',
                            version: QrVersions.auto,
                            size: 90.w,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (_labelSettings.showJobNo ||
                _labelSettings.showCustomerName ||
                _labelSettings.showModelBrand ||
                _labelSettings.showSymptom ||
                _labelSettings.showPhysicalLocation) ...[
              SizedBox(height: 16.h),
              // Info text lines
              Text(
                [
                  if (_labelSettings.showJobNo) _getJobNumber(),
                  if (_labelSettings.showCustomerName) _getCustomerName(),
                  if (_labelSettings.showModelBrand)
                    [
                      if (_getJobNumber() != _getDeviceName()) _getDeviceName(),
                      if (_getDeviceIMEI().isNotEmpty) 'IMEI: ${_getDeviceIMEI()}',
                      if (_getDeviceSerialNumber().isNotEmpty) 'S/N: ${_getDeviceSerialNumber()}',
                    ].join(' '),
                ].where((e) => e.trim().isNotEmpty).join(' | '),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3),
                textAlign: TextAlign.left,
              ),

              if (_labelSettings.showSymptom || _labelSettings.showPhysicalLocation) ...[
                if (_labelSettings.showJobNo || _labelSettings.showCustomerName || _labelSettings.showModelBrand)
                  SizedBox(height: 4.h),
                Text(
                  [
                    if (_labelSettings.showSymptom) _getDefect(),
                    if (_labelSettings.showPhysicalLocation) 'BOX: ${_getPhysicalLocation()}',
                  ].where((e) => e.isNotEmpty).join(' | '),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3),
                  textAlign: TextAlign.left,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Print Options Bottom Sheet
// ──────────────────────────────────────────────────────────────────────────────

class _PrintOptionsSheet extends StatelessWidget {
  final VoidCallback onPrintLabel;
  final VoidCallback onPrintReceipt;

  const _PrintOptionsSheet({required this.onPrintLabel, required this.onPrintReceipt});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 20.h),
          Text(
            'Print options',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _PrintOptionTile(
                  widget: Image.asset('assets/icon/label.png', width: 44, height: 44, color: Colors.black),
                  label: 'Device label',
                  onTap: onPrintLabel,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _PrintOptionTile(
                  widget: Icon(SolarIconsOutline.documentText, size: 44),
                  label: 'Job Receipt',
                  onTap: onPrintReceipt,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _PrintOptionTile extends StatelessWidget {
  final String label;
  final Widget widget;
  final VoidCallback onTap;

  const _PrintOptionTile({required this.label, required this.widget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          children: [
            widget,
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section Header
// ──────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Container(
        //   width: 32.w,
        //   height: 32.h,
        //   decoration: BoxDecoration(
        //     color: color.withValues(alpha: 0.12),
        //     borderRadius: BorderRadius.circular(8.r),
        //   ),
        //   child: Icon(icon, color: color, size: 18.sp),
        // ),
        // SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Printer picker (label printers)
// ──────────────────────────────────────────────────────────────────────────────

class _PrinterPickerSheet extends StatelessWidget {
  final String title;
  final List<PrinterConfigModel> printers;

  const _PrinterPickerSheet({required this.title, required this.printers});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(
        title,
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
      ),
      actions: printers.map((printer) {
        return CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(printer),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.printer, size: 20),
              SizedBox(width: 8.w),
              Text('${printer.printerBrand} ${printer.printerModel ?? ''}'.trim(), style: TextStyle(fontSize: 16.sp)),
            ],
          ),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        isDestructiveAction: true,
        child: const Text('Cancel'),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Existing helper dialogs (kept for receipt print flow)
// ──────────────────────────────────────────────────────────────────────────────

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
          separatorBuilder: (_, i) => const Divider(),
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

class _DiscoveredPrintersDialog extends StatelessWidget {
  final List<Map<String, String>> printers;

  const _DiscoveredPrintersDialog({required this.printers});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Discovered Printers'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: printers.length,
          itemBuilder: (context, index) {
            final printer = printers[index];
            return ListTile(
              leading: const Icon(Icons.print, color: Colors.blue),
              title: Text(printer['name'] ?? 'Unknown Printer'),
              subtitle: Text('IP: ${printer['ip']}\nPort: ${printer['port']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).pop(printer),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }
}

class _PrinterConfigurationDialog extends StatefulWidget {
  final Map<String, String> printerInfo;

  const _PrinterConfigurationDialog({required this.printerInfo});

  @override
  State<_PrinterConfigurationDialog> createState() => _PrinterConfigurationDialogState();
}

class _PrinterConfigurationDialogState extends State<_PrinterConfigurationDialog> {
  String _printerType = 'thermal';
  String _printerBrand = 'Brother';
  String? _printerModel;
  int _paperWidth = 80;
  LabelSize? _labelSize;
  bool _isDefault = true;
  List<LabelSize> _availableLabelSizes = [];

  final List<String> _printerBrands = ['Brother', 'Epson', 'Zebra', 'Dymo', 'Other'];
  final List<int> _paperWidths = [58, 80];

  @override
  void initState() {
    super.initState();
    _updateLabelSizes();
  }

  void _updateLabelSizes() {
    switch (_printerBrand) {
      case 'Brother':
        _availableLabelSizes = LabelSize.getBrotherSizes();
        break;
      case 'Dymo':
        _availableLabelSizes = LabelSize.getDymoSizes();
        break;
      default:
        _availableLabelSizes = LabelSize.getXprinterSizes();
    }
    if (_availableLabelSizes.isNotEmpty) {
      _labelSize = _availableLabelSizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure Printer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP Address: ${widget.printerInfo['ip']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _printerType,
              decoration: const InputDecoration(labelText: 'Printer Type'),
              items: const [
                DropdownMenuItem(value: 'thermal', child: Text('Thermal Receipt')),
                DropdownMenuItem(value: 'label', child: Text('Label Printer')),
                DropdownMenuItem(value: 'a4', child: Text('A4 Printer')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _printerType = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _printerBrand,
              decoration: const InputDecoration(labelText: 'Printer Brand'),
              items: _printerBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _printerBrand = value;
                    _updateLabelSizes();
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Printer Model (Optional)', hintText: 'e.g., QL-820NWB'),
              onChanged: (value) => _printerModel = value.isEmpty ? null : value,
            ),
            const SizedBox(height: 12),
            if (_printerType == 'thermal') ...[
              DropdownButtonFormField<int>(
                initialValue: _paperWidth,
                decoration: const InputDecoration(labelText: 'Paper Width'),
                items: _paperWidths.map((w) => DropdownMenuItem(value: w, child: Text('${w}mm'))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _paperWidth = value);
                },
              ),
              const SizedBox(height: 12),
            ],
            if (_printerType == 'label') ...[
              DropdownButtonFormField<LabelSize>(
                initialValue: _labelSize,
                decoration: const InputDecoration(labelText: 'Label Size'),
                items: _availableLabelSizes
                    .map((size) => DropdownMenuItem(value: size, child: Text(size.toString())))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _labelSize = value);
                },
              ),
              const SizedBox(height: 12),
            ],
            CheckboxListTile(
              value: _isDefault,
              title: const Text('Set as default printer'),
              contentPadding: EdgeInsets.zero,
              onChanged: (value) => setState(() => _isDefault = value ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final config = PrinterConfigModel(
              printerType: _printerType,
              printerBrand: _printerBrand,
              printerModel: _printerModel,
              ipAddress: widget.printerInfo['ip']!,
              protocol: 'TCP',
              port: int.parse(widget.printerInfo['port']!),
              paperWidth: _printerType == 'thermal' ? _paperWidth : null,
              labelSize: _printerType == 'label' ? _labelSize : null,
              isDefault: _isDefault,
            );
            Navigator.of(context).pop(config);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
