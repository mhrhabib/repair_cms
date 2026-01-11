import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/set_up_di.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart' as job_booking;
import 'package:repair_cms/features/jobBooking/widgets/thermal_receipt_widget.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_service_factory.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart' as my_jobs;

class JobThermalReceiptPreviewScreen extends StatefulWidget {
  final job_booking.CreateJobResponse jobResponse;
  final String printOption;

  const JobThermalReceiptPreviewScreen({super.key, required this.jobResponse, required this.printOption});

  @override
  State<JobThermalReceiptPreviewScreen> createState() => _JobThermalReceiptPreviewScreenState();
}

class _JobThermalReceiptPreviewScreenState extends State<JobThermalReceiptPreviewScreen> {
  final _settingsService = PrinterSettingsService();
  final GlobalKey _receiptKey = GlobalKey();
  my_jobs.SingleJobModel? _completeJobData;
  bool _isLoadingCompleteData = false;
  bool _isImagesPrecached = false;

  Talker get _talker => SetUpDI.getIt<Talker>();

  @override
  void initState() {
    super.initState();
    _fetchCompleteJobData();
    _precacheImages();
  }

  /// Precache logo and signature images to ensure they're ready for printing
  Future<void> _precacheImages() async {
    try {
      final data = widget.jobResponse.data;
      final receiptFooter = data?.receiptFooter;

      // Precache company logo
      final logoUrl = receiptFooter?.companyLogoURL;
      if (logoUrl != null && logoUrl.isNotEmpty) {
        final fullLogoUrl = logoUrl.startsWith('http')
            ? logoUrl
            : '${ApiEndpoints.baseUrl}/file-upload/download/new?imagePath=$logoUrl';

        debugPrint('🖼️ [ThermalReceipt] Precaching logo: $fullLogoUrl');
        _talker.debug('Precaching logo image...');

        await precacheImage(NetworkImage(fullLogoUrl), context);
        debugPrint('✅ [ThermalReceipt] Logo precached');
      }

      // Precache signature image
      if (data?.signatureFilePath != null && data!.signatureFilePath!.isNotEmpty) {
        final signatureUrl = data.signatureFilePath!.startsWith('http')
            ? data.signatureFilePath!
            : '${ApiEndpoints.baseUrl}/file-upload/download/new?imagePath=${data.signatureFilePath}';

        debugPrint('🖼️ [ThermalReceipt] Precaching signature: $signatureUrl');
        _talker.debug('Precaching signature image...');

        await precacheImage(NetworkImage(signatureUrl), context);
        debugPrint('✅ [ThermalReceipt] Signature precached');
      }

      setState(() => _isImagesPrecached = true);
      _talker.info('✅ All images precached successfully');
    } catch (e) {
      debugPrint('⚠️ [ThermalReceipt] Error precaching images: $e');
      _talker.warning('Failed to precache some images: $e');
      // Don't block the UI, set as precached anyway
      setState(() => _isImagesPrecached = true);
    }
  }

  Future<void> _fetchCompleteJobData() async {
    final jobId = widget.jobResponse.data?.sId;
    if (jobId == null || jobId.isEmpty) {
      debugPrint('⚠️ [ThermalReceiptPreview] No job ID available');
      return;
    }

    setState(() => _isLoadingCompleteData = true);

    debugPrint('🔄 [ThermalReceiptPreview] Fetching complete job data: $jobId');
    context.read<JobCubit>().getJobById(jobId);
  }

  void _goHome() {
    Navigator.of(context).pop();
  }

  Future<void> _showPrinterSelection() async {
    debugPrint('🖨️ Opening thermal printer selection');

    final allPrinters = _settingsService.getAllPrinters();
    final thermalPrinters = allPrinters['thermal'] ?? [];

    if (thermalPrinters.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Thermal Printers'),
          content: const Text('Please configure a thermal printer in Settings > Printer Settings.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
      return;
    }

    final selectedPrinter = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Thermal Printer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: thermalPrinters.length,
            itemBuilder: (context, index) {
              final printer = thermalPrinters[index];
              return ListTile(
                leading: const Icon(Icons.print),
                title: Text('${printer.printerBrand} ${printer.printerModel ?? "Thermal Printer"}'),
                subtitle: Text('${printer.ipAddress}:${printer.port}'),
                onTap: () => Navigator.of(context).pop(printer),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
      ),
    );

    if (selectedPrinter != null && mounted) {
      _printThermalReceipt(selectedPrinter);
    }
  }

  Future<void> _printThermalReceipt(PrinterConfigModel printer) async {
    // Wait for images to be precached before printing
    if (!_isImagesPrecached) {
      debugPrint('⏳ [ThermalPrint] Waiting for images to precache...');
      _talker.info('Waiting for images to load...');

      // Wait up to 5 seconds for precaching
      int attempts = 0;
      while (!_isImagesPrecached && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (!_isImagesPrecached) {
        _talker.warning('⚠️ Proceeding without full image precache');
      }
    }

    final startTime = DateTime.now();
    _talker.info('🖨️ [JobThermalReceipt] Print request started');
    _talker.debug('Printer: ${printer.printerBrand} ${printer.printerModel ?? "Thermal Printer"}');
    _talker.debug('IP: ${printer.ipAddress}:${printer.port ?? 9100}');
    _talker.debug('Paper Width: ${printer.paperWidth ?? 80}mm');

    debugPrint('🖨️ Printing thermal receipt to ${printer.printerBrand} ${printer.printerModel ?? "Thermal Printer"}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Capturing receipt...')],
            ),
          ),
        ),
      ),
    );

    try {
      // Wait longer for widget to fully render (especially QR/barcode generation)
      _talker.debug('⏳ Waiting for widget render...');

      // Wait for frame to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // Force frames to complete and ensure widget is painted
      for (int i = 0; i < 3; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 200));
        _talker.debug('Frame $i completed');
      }

      _talker.debug('✅ Widget should be fully rendered');

      // Capture the receipt widget as image
      _talker.debug('📷 Starting image capture...');
      final Uint8List? imageBytes = await _captureReceiptAsImage();

      if (imageBytes == null) {
        _talker.error('❌ Image capture returned null');
        throw Exception('Failed to capture receipt image');
      }

      debugPrint('📷 [ThermalPrint] Captured image: ${imageBytes.length} bytes');
      _talker.info('✅ Image captured: ${imageBytes.length} bytes');

      if (mounted) {
        // Update loading message
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Printing...')],
                ),
              ),
            ),
          ),
        );
      }

      // Print using image-based method with fallback
      _talker.debug('📤 Sending to PrinterServiceFactory...');
      final result = await PrinterServiceFactory.printThermalReceiptImage(config: printer, imageBytes: imageBytes);

      final duration = DateTime.now().difference(startTime);
      _talker.info('Print operation completed in ${duration.inMilliseconds}ms');

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (result.success) {
          debugPrint('✅ [ThermalPrint] Print successful');
          _talker.info('✅ [JobThermalReceipt] Print successful! Duration: ${duration.inMilliseconds}ms');
          SnackbarDemo(message: '✅ Receipt printed successfully!').showCustomSnackbar(context);
        } else {
          debugPrint('❌ [ThermalPrint] Print failed: ${result.message}');
          _talker.error('❌ [JobThermalReceipt] Print failed: ${result.message} (code: ${result.code})');
          SnackbarDemo(message: '❌ Print failed: ${result.message}').showCustomSnackbar(context);
        }
      }
    } catch (e, st) {
      debugPrint('❌ [ThermalPrint] Error: $e');
      _talker.error('❌ [JobThermalReceipt] Exception: $e');
      _talker.debug('Stack trace: $st');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        SnackbarDemo(message: '❌ Print error: $e').showCustomSnackbar(context);
      }
    }
  }

  /// Capture the thermal receipt widget as an image
  Future<Uint8List?> _captureReceiptAsImage() async {
    try {
      _talker.debug('🔍 Finding RepaintBoundary...');
      final boundary = _receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('❌ [ImageCapture] Render boundary not found');
        _talker.error('❌ RepaintBoundary not found - widget may not be rendered');
        return null;
      }
      _talker.debug('✅ RepaintBoundary found');

      // Capture at high resolution for better print quality (2x pixel ratio)
      _talker.debug('📸 Capturing image at 2x pixel ratio...');
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      _talker.debug('✅ Image captured: ${image.width}x${image.height}');

      _talker.debug('🔄 Converting to PNG bytes...');
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('❌ [ImageCapture] Failed to convert image to bytes');
        _talker.error('❌ Failed to convert image to ByteData');
        return null;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Analyze captured image for debugging
      final rawByteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rawByteData != null) {
        int blackPixels = 0;
        int whitePixels = 0;
        int otherPixels = 0;

        // Sample first 1000 pixels
        for (int i = 0; i < rawByteData.lengthInBytes && i < 4000; i += 4) {
          final r = rawByteData.getUint8(i);
          final g = rawByteData.getUint8(i + 1);
          final b = rawByteData.getUint8(i + 2);
          final a = rawByteData.getUint8(i + 3);
          final gray = ((r * 0.299) + (g * 0.587) + (b * 0.114)).round();

          if (a < 128) continue; // Skip transparent

          if (gray < 128) {
            blackPixels++;
          } else if (gray > 200) {
            whitePixels++;
          } else {
            otherPixels++;
          }
        }

        _talker.info('🎨 Image analysis (first 1000px): Black=$blackPixels, White=$whitePixels, Other=$otherPixels');

        if (blackPixels == 0) {
          _talker.warning('⚠️ WARNING: No black pixels detected! Image may be blank or transparent');
        }
      }

      debugPrint('✅ [ImageCapture] Captured ${image.width}x${image.height} image (${pngBytes.length} bytes)');
      _talker.info('✅ PNG encoded: ${pngBytes.length} bytes (${image.width}x${image.height})');

      return pngBytes;
    } catch (e, st) {
      debugPrint('❌ [ImageCapture] Error: $e');
      _talker.error('❌ Image capture error: $e');
      _talker.debug('Stack trace: $st');
      return null;
    }
  }

  /// Convert CreateJobResponse to SingleJobModel for ThermalReceiptWidget
  my_jobs.SingleJobModel _convertToSingleJobModel() {
    final data = widget.jobResponse.data;

    debugPrint('📋 [ThermalReceiptPreview] Converting job response to SingleJobModel');

    // Get data from JobBookingCubit state for receipt footer and customer details
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

    // Use data from response where available, fallback to cubit data
    final finalReceiptFooter = data?.receiptFooter ?? receiptFooterFromCubit;
    final finalCustomerDetails = data?.customerDetails ?? customerDetailsFromCubit;
    final finalSalutation = data?.salutationHTMLmarkup ?? salutationFromCubit;
    final finalTerms = data?.termsAndConditionsHTMLmarkup ?? termsFromCubit;

    // Convert assignedItems to dynamic list that widget expects
    final assignedItemsList = data?.assignedItems?.map((item) {
      return {
        'productName': item.productName ?? '',
        'name': item.productName ?? '',
        'price_incl_vat': item.salePriceIncVat ?? 0,
      };
    }).toList();

    // Calculate totals from assigned items
    final calculatedSubTotal =
        data?.assignedItems?.fold<double>(0.0, (sum, item) => sum + (item.salePriceIncVat ?? 0)) ?? 0.0;

    return my_jobs.SingleJobModel(
      success: widget.jobResponse.success,
      data: my_jobs.Data(
        sId: data?.sId,
        jobType: data?.jobType,
        jobTypes: data?.jobType,
        model: data?.model,
        physicalLocation: data?.physicalLocation,
        signatureFilePath: data?.signatureFilePath,
        jobNo: data?.jobNo ?? data?.model ?? data?.sId ?? 'N/A',
        createdAt: data?.createdAt,
        updatedAt: data?.updatedAt,
        total: calculatedSubTotal,
        subTotal: calculatedSubTotal,
        discount: 0.0,
        jobTrackingNumber: _completeJobData?.data?.jobTrackingNumber ?? data?.jobTrackingNumber ?? data?.jobNo,
        assignedItems: assignedItemsList,
        device: data?.device
            ?.map(
              (d) => my_jobs.Device(
                sId: d.sId,
                brand: d.brand,
                model: d.model,
                condition: d.condition?.map((c) => my_jobs.Condition(value: c.value, id: c.id)).toList(),
              ),
            )
            .toList(),
        defect: data?.defect
            ?.map(
              (d) => my_jobs.Defect(
                sId: d.sId,
                defect: d.defect?.map((item) => my_jobs.DefectItem(value: item.value, id: item.id)).toList(),
                description: d.description,
              ),
            )
            .toList(),
        receiptFooter: finalReceiptFooter != null
            ? my_jobs.ReceiptFooter(
                companyLogo: finalReceiptFooter.companyLogo,
                companyLogoURL:
                    finalReceiptFooter.companyLogoURL.isNotEmpty &&
                        !finalReceiptFooter.companyLogoURL.startsWith('http')
                    ? '${ApiEndpoints.baseUrl}/file-upload/download/new?imagePath=${finalReceiptFooter.companyLogoURL}'
                    : finalReceiptFooter.companyLogoURL,
                address: my_jobs.Address(
                  companyName: finalReceiptFooter.address.companyName,
                  street: finalReceiptFooter.address.street,
                  num: finalReceiptFooter.address.num,
                  zip: finalReceiptFooter.address.zip,
                  city: finalReceiptFooter.address.city,
                  country: finalReceiptFooter.address.country,
                ),
                contact: my_jobs.ContactInfo(
                  ceo: finalReceiptFooter.contact.ceo,
                  telephone: finalReceiptFooter.contact.telephone,
                  email: finalReceiptFooter.contact.email,
                  website: finalReceiptFooter.contact.website,
                ),
                bank: my_jobs.Bank(
                  bankName: finalReceiptFooter.bank.bankName,
                  iban: finalReceiptFooter.bank.iban,
                  bic: finalReceiptFooter.bank.bic,
                ),
              )
            : null,
        customerDetails: finalCustomerDetails != null
            ? my_jobs.CustomerDetails(
                customerId: finalCustomerDetails.customerId,
                type: finalCustomerDetails.type,
                organization: finalCustomerDetails.organization,
                customerNo: finalCustomerDetails.customerNo,
                email: finalCustomerDetails.email,
                telephone: finalCustomerDetails.telephone,
                telephonePrefix: finalCustomerDetails.telephonePrefix,
                salutation: finalCustomerDetails.salutation,
                firstName: finalCustomerDetails.firstName,
                lastName: finalCustomerDetails.lastName,
              )
            : null,
        salutationHTMLmarkup: finalSalutation,
        termsAndConditionsHTMLmarkup: finalTerms,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobDetailSuccess) {
          debugPrint('✅ [ThermalReceiptPreview] Got tracking: ${state.job.data?.jobTrackingNumber}');
          setState(() {
            _completeJobData = state.job;
            _isLoadingCompleteData = false;
          });
        } else if (state is JobError) {
          debugPrint('❌ [ThermalReceiptPreview] Error: ${state.message}');
          setState(() => _isLoadingCompleteData = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _goHome()),
          title: Text(
            'Thermal Receipt Preview',
            style: TextStyle(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.print), onPressed: _showPrinterSelection, tooltip: 'Print')],
        ),
        body: _isLoadingCompleteData
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading receipt data...')],
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RepaintBoundary(
                      key: _receiptKey,
                      child: ThermalReceiptWidget(
                        jobData: _completeJobData ?? _convertToSingleJobModel(),
                        logoEnabled: true,
                        qrCodeEnabled: true,
                        enableTelephoneNumber: true,
                      ),
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goHome,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(color: AppColors.primary, fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showPrinterSelection,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Print',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
