import 'dart:convert';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/services/file_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/features/home/home_screen.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/set_up_di.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart'
    as job_booking;
import 'package:repair_cms/features/jobBooking/widgets/thermal_receipt_widget.dart';
import 'package:repair_cms/features/jobBooking/services/escpos_generator_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_service_factory.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart'
    as my_jobs;

class JobThermalReceiptPreviewScreen extends StatefulWidget {
  final job_booking.CreateJobResponse jobResponse;
  final String printOption;
  final bool fromBooking;

  const JobThermalReceiptPreviewScreen({
    super.key,
    required this.jobResponse,
    required this.printOption,
    this.fromBooking = false,
  });

  @override
  State<JobThermalReceiptPreviewScreen> createState() =>
      _JobThermalReceiptPreviewScreenState();
}

class _JobThermalReceiptPreviewScreenState
    extends State<JobThermalReceiptPreviewScreen> {
  final _settingsService = PrinterSettingsService();
  my_jobs.SingleJobModel? _completeJobData;
  bool _isLoadingCompleteData = false;

  Talker get _talker => SetUpDI.getIt<Talker>();

  @override
  void initState() {
    super.initState();
    _fetchCompleteJobData();
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
    if (widget.fromBooking) {
      // Go to Job List (index 1 of HomeScreen)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
        (route) => false,
      );
    } else {
      // Just go back to wherever we came from (likely Job Details)
      Navigator.of(context).pop();
    }
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
          content: const Text(
            'Please configure a thermal printer in Settings > Printer Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
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
                title: Text(
                  '${printer.printerBrand} ${printer.printerModel ?? "Thermal Printer"}',
                ),
                subtitle: Text('${printer.ipAddress}:${printer.port}'),
                onTap: () => Navigator.of(context).pop(printer),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedPrinter != null && mounted) {
      _printThermalReceipt(selectedPrinter);
    }
  }

  Future<void> _printThermalReceipt(PrinterConfigModel printer) async {
    final startTime = DateTime.now();
    _talker.info('🖨️ [JobThermalReceipt] Print request started (ESC/POS)');
    _talker.debug(
      'Printer: ${printer.printerBrand} ${printer.printerModel ?? "Thermal Printer"}',
    );
    _talker.debug('IP: ${printer.ipAddress}:${printer.port ?? 9100}');
    _talker.debug('Paper Width: ${printer.paperWidth ?? 80}mm');

    debugPrint(
      '🖨️ [ESC/POS] Printing thermal receipt to ${printer.printerBrand}',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating receipt...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Convert job data to Map for ESC/POS generator
      _talker.debug('📝 Converting job data to Map...');
      final jobDataMap = _convertJobDataToMap();

      // Generate ESC/POS bytes (no image capture!)
      _talker.debug('🔧 Generating ESC/POS commands...');
      final escposBytes = EscPosGeneratorService.generateThermalReceipt(
        jobData: jobDataMap,
        paperWidth: printer.paperWidth ?? 80,
        includeQrCode: true,
      );

      debugPrint(
        '✅ [ESC/POS] Generated ${escposBytes.length} bytes of ESC/POS commands',
      );
      _talker.info('✅ ESC/POS bytes generated: ${escposBytes.length} bytes');

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
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Printing...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Print using ESC/POS commands directly
      _talker.debug('📤 Sending ESC/POS bytes to printer...');
      final result = await PrinterServiceFactory.printRawEscPos(
        config: printer,
        escposBytes: escposBytes,
      );

      final duration = DateTime.now().difference(startTime);
      _talker.info('Print operation completed in ${duration.inMilliseconds}ms');

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (result.success) {
          debugPrint('✅ [ESC/POS] Print successful');
          _talker.info(
            '✅ [JobThermalReceipt] Print successful! Duration: ${duration.inMilliseconds}ms',
          );
          SnackbarDemo(
            message: '✅ Receipt printed successfully!',
          ).showCustomSnackbar(context);
        } else {
          debugPrint('❌ [ESC/POS] Print failed: ${result.message}');
          _talker.error(
            '❌ [JobThermalReceipt] Print failed: ${result.message} (code: ${result.code})',
          );
          SnackbarDemo(
            message: '❌ Print failed: ${result.message}',
          ).showCustomSnackbar(context);
        }
      }
    } catch (e, st) {
      debugPrint('❌ [ESC/POS] Error: $e');
      _talker.error('❌ [JobThermalReceipt] Exception: $e');
      _talker.debug('Stack trace: $st');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        SnackbarDemo(message: '❌ Print error: $e').showCustomSnackbar(context);
      }
    }
  }

  /// Convert SingleJobModel to Map for ESC/POS generator
  Map<String, dynamic> _convertJobDataToMap() {
    final jobModel = _completeJobData ?? _convertToSingleJobModel();
    final data = jobModel.data;

    return {
      'sId': data?.sId,
      'jobNo': data?.jobNo,
      'jobTypes': data?.jobTypes,
      'model': data?.model,
      'physicalLocation': data?.physicalLocation,
      'signatureFilePath': data?.signatureFilePath,
      'createdAt': data?.createdAt,
      'jobTrackingNumber': data?.jobTrackingNumber,
      'salutationHTMLmarkup': data?.salutationHTMLmarkup,
      'termsAndConditionsHTMLmarkup': data?.termsAndConditionsHTMLmarkup,
      'discount': data?.discount,
      'subTotal': data?.subTotal,
      'total': data?.total,
      'services': data?.services,
      'assignedItems': data?.assignedItems,
      'device': data?.device
          ?.map(
            (d) => {
              'sId': d.sId,
              'brand': d.brand,
              'model': d.model,
              'condition': d.condition
                  ?.map((c) => {'value': c.value, 'id': c.id})
                  .toList(),
            },
          )
          .toList(),
      'defect': data?.defect
          ?.map(
            (d) => {
              'sId': d.sId,
              'description': d.description,
              'defect': d.defect
                  ?.map((item) => {'value': item.value, 'id': item.id})
                  .toList(),
            },
          )
          .toList(),
      'receiptFooter': data?.receiptFooter != null
          ? {
              'companyLogoURL': data!.receiptFooter!.companyLogoURL,
              'address': {
                'companyName': data.receiptFooter!.address?.companyName,
                'street': data.receiptFooter!.address?.street,
                'num': data.receiptFooter!.address?.num,
                'zip': data.receiptFooter!.address?.zip,
                'city': data.receiptFooter!.address?.city,
                'country': data.receiptFooter!.address?.country,
              },
              'contact': {
                'ceo': data.receiptFooter!.contact?.ceo,
                'telephone': data.receiptFooter!.contact?.telephone,
                'email': data.receiptFooter!.contact?.email,
                'website': data.receiptFooter!.contact?.website,
              },
              'bank': {
                'bankName': data.receiptFooter!.bank?.bankName,
                'iban': data.receiptFooter!.bank?.iban,
                'bic': data.receiptFooter!.bank?.bic,
              },
            }
          : null,
      'customerDetails': data?.customerDetails != null
          ? {
              'customerId': data!.customerDetails!.customerId,
              'type': data.customerDetails!.type,
              'organization': data.customerDetails!.organization,
              'customerNo': data.customerDetails!.customerNo,
              'email': data.customerDetails!.email,
              'telephone': data.customerDetails!.telephone,
              'telephonePrefix': data.customerDetails!.telephonePrefix,
              'salutation': data.customerDetails!.salutation,
              'firstName': data.customerDetails!.firstName,
              'lastName': data.customerDetails!.lastName,
            }
          : null,
    };
  }

  /// Convert CreateJobResponse to SingleJobModel for ThermalReceiptWidget
  my_jobs.SingleJobModel _convertToSingleJobModel() {
    final data = widget.jobResponse.data;

    debugPrint(
      '📋 [ThermalReceiptPreview] Converting job response to SingleJobModel',
    );

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

    final finalCustomerDetails =
        data?.customerDetails ?? customerDetailsFromCubit;
    final finalSalutation = data?.salutationHTMLmarkup ?? salutationFromCubit;
    final finalTerms = data?.termsAndConditionsHTMLmarkup ?? termsFromCubit;

    // Helper: Select first non-null/non-empty value
    T? pick<T>(T? resp, T? cubit, [T? storageFallback]) {
      if (resp != null) {
        if (resp is String && resp.isNotEmpty) return resp;
        if (resp is! String) return resp;
      }
      if (cubit != null) {
        if (cubit is String && cubit.isNotEmpty) return cubit;
        if (cubit is! String) return cubit;
      }
      return storageFallback;
    }

    final respFooter = data?.receiptFooter;
    final cubitFooter = receiptFooterFromCubit;

    // Get agent/user details from storage
    List<my_jobs.LoggedUser>? agentUser;
    final userData = storage.read('userData') ?? storage.read('user_data');
    if (userData != null) {
      final userMap = userData is String ? jsonDecode(userData) : userData;
      agentUser = [
        my_jobs.LoggedUser(
          fullName: userMap['fullName'] ?? userMap['name'] ?? 'N/A',
          email: userMap['email'] ?? '',
        ),
      ];
    }

    final List<Map<String, dynamic>> combinedItems = [];

    if (data?.services != null) {
      for (final service in data!.services!) {
        combinedItems.add({
          'productName': service.name ?? 'Service',
          'name': service.name ?? 'Service',
          'price_incl_vat': service.priceInclVat ?? 0,
        });
      }
    }

    if (data?.assignedItems != null) {
      for (final item in data!.assignedItems!) {
        combinedItems.add({
          'productName': item.productName ?? 'Item',
          'name': item.productName ?? 'Item',
          'price_incl_vat': item.salePriceIncVat ?? 0,
        });
      }
    }

    final calculatedSubTotal = combinedItems.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          (item['price_incl_vat'] is num
              ? (item['price_incl_vat'] as num).toDouble()
              : double.tryParse(item['price_incl_vat'].toString()) ?? 0.0),
    );

    return my_jobs.SingleJobModel(
      success: widget.jobResponse.success,
      data: my_jobs.Data(
        sId: data?.sId,
        jobType: data?.jobType,
        jobTypes: data?.jobType,
        model: data?.model,
        physicalLocation: data?.physicalLocation,
        signatureFilePath:
            (data?.signatureFilePath != null &&
                data!.signatureFilePath!.isNotEmpty)
            ? data.signatureFilePath
            : (jobBookingState is JobBookingData
                  ? jobBookingState.job.signatureFilePath
                  : null),
        jobNo: data?.jobNo ?? data?.model ?? data?.sId ?? 'N/A',
        createdAt: data?.createdAt,
        updatedAt: data?.updatedAt,
        total: calculatedSubTotal,
        subTotal: calculatedSubTotal,
        discount: 0.0,
        jobTrackingNumber:
            _completeJobData?.data?.jobTrackingNumber ??
            data?.jobTrackingNumber ??
            data?.jobNo,
        services: data?.services,
        assignedItems: combinedItems,
        device: data?.device
            ?.map(
              (d) => my_jobs.Device(
                sId: d.sId,
                brand: d.brand,
                model: d.model,
                condition: d.condition
                    ?.map((c) => my_jobs.Condition(value: c.value, id: c.id))
                    .toList(),
              ),
            )
            .toList(),
        defect: data?.defect
            ?.map(
              (d) => my_jobs.Defect(
                sId: d.sId,
                defect: d.defect
                    ?.map(
                      (item) =>
                          my_jobs.DefectItem(value: item.value, id: item.id),
                    )
                    .toList(),
                description: d.description,
              ),
            )
            .toList(),
        receiptFooter: my_jobs.ReceiptFooter(
          companyLogo: pick(respFooter?.companyLogo, cubitFooter?.companyLogo),
          companyLogoURL: FileService.getImageUrl(
            pick(respFooter?.companyLogoURL, cubitFooter?.companyLogoURL),
          ),
          address: my_jobs.Address(
            companyName: pick(
              respFooter?.address.companyName,
              cubitFooter?.address.companyName,
              storage.read('companyName') ?? '',
            ),
            street: pick(
              respFooter?.address.street,
              cubitFooter?.address.street,
            ),
            num: pick(respFooter?.address.num, cubitFooter?.address.num),
            zip: pick(respFooter?.address.zip, cubitFooter?.address.zip),
            city: pick(respFooter?.address.city, cubitFooter?.address.city),
            country: pick(
              respFooter?.address.country,
              cubitFooter?.address.country,
            ),
          ),
          contact: my_jobs.ContactInfo(
            ceo: pick(respFooter?.contact.ceo, cubitFooter?.contact.ceo),
            telephone: pick(
              respFooter?.contact.telephone,
              cubitFooter?.contact.telephone,
            ),
            email: pick(respFooter?.contact.email, cubitFooter?.contact.email),
            website: pick(
              respFooter?.contact.website,
              cubitFooter?.contact.website,
            ),
          ),
          bank: my_jobs.Bank(
            bankName: pick(
              respFooter?.bank.bankName,
              cubitFooter?.bank.bankName,
            ),
            iban: pick(respFooter?.bank.iban, cubitFooter?.bank.iban),
            bic: pick(respFooter?.bank.bic, cubitFooter?.bank.bic),
          ),
        ),
        customerDetails: finalCustomerDetails != null
            ? my_jobs.CustomerDetails(
                customerId: finalCustomerDetails.customerId,
                type: finalCustomerDetails.type,
                type2: finalCustomerDetails.type2,
                organization: finalCustomerDetails.organization,
                customerNo: finalCustomerDetails.customerNo,
                email: finalCustomerDetails.email,
                telephone: finalCustomerDetails.telephone,
                telephonePrefix: finalCustomerDetails.telephonePrefix,
                salutation: finalCustomerDetails.salutation,
                firstName: finalCustomerDetails.firstName,
                lastName: finalCustomerDetails.lastName,
                position: finalCustomerDetails.position,
                billingAddress: my_jobs.BillingAddress(
                  street:
                      '${finalCustomerDetails.billingAddress.street ?? ''} ${finalCustomerDetails.billingAddress.no ?? ''}'
                          .trim(),
                  zip: finalCustomerDetails.billingAddress.zip,
                  city: finalCustomerDetails.billingAddress.city,
                  state: finalCustomerDetails.billingAddress.state,
                  country: finalCustomerDetails.billingAddress.country,
                ),
                shippingAddress: my_jobs.ShippingAddress(
                  street:
                      '${finalCustomerDetails.shippingAddress.street ?? ''} ${finalCustomerDetails.shippingAddress.no ?? ''}'
                          .trim(),
                  zip: finalCustomerDetails.shippingAddress.zip,
                  city: finalCustomerDetails.shippingAddress.city,
                  country: finalCustomerDetails.shippingAddress.country,
                ),
              )
            : null,
        salutationHTMLmarkup: finalSalutation,
        termsAndConditionsHTMLmarkup: finalTerms,
        loggedUserId: agentUser,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobDetailSuccess) {
          debugPrint(
            '✅ [ThermalReceiptPreview] Got tracking: ${state.job.data?.jobTrackingNumber}',
          );
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
        backgroundColor: AppColors.kBg,
        extendBodyBehindAppBar: true,
        appBar: CupertinoNavigationBar(
          backgroundColor: AppColors.kBg.withValues(alpha: 0.1),
          border: null,
          leading: CustomNavButton(
            onPressed: () => _goHome(),
            icon: CupertinoIcons.back,
          ),
          middle: Text(
            'Thermal Receipt Preview',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: CustomNavButton(
            onPressed: _showPrinterSelection,
            icon: Icons.print,
            size: 20.sp,
            iconColor: const Color(0xFF3A4A67),
          ),
        ),
        body: _isLoadingCompleteData
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading receipt data...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 50.h,
                  bottom: 16.h,
                ),
                child: Center(
                  child: Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(vertical: 16.h),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ThermalReceiptWidget(
                      jobData: _completeJobData ?? _convertToSingleJobModel(),
                      logoEnabled: false, // Logo removed as per requirements
                      qrCodeEnabled: true,
                      enableTelephoneNumber: true,
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
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
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
