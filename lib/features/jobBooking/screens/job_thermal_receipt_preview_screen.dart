import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart'
    as job_booking;
import 'package:repair_cms/features/jobBooking/widgets/thermal_receipt_widget.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart'
    as my_jobs;

class JobThermalReceiptPreviewScreen extends StatefulWidget {
  final job_booking.CreateJobResponse jobResponse;
  final String printOption;

  const JobThermalReceiptPreviewScreen({
    super.key,
    required this.jobResponse,
    required this.printOption,
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
    debugPrint(
      '🖨️ Printing thermal receipt to ${printer.printerBrand} ${printer.printerModel ?? "Thermal Printer"}',
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
                Text('Printing...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // TODO: Implement actual thermal printing
      if (mounted) {
        Navigator.of(context).pop();
        SnackbarDemo(
          message: 'Print functionality will be implemented here',
        ).showCustomSnackbar(context);
      }

      debugPrint(
        '🖨️ Thermal printer - Paper width: ${printer.paperWidth ?? 80}mm',
      );
    } catch (e) {
      debugPrint('❌ Print error: $e');
      if (mounted) {
        Navigator.of(context).pop();
        SnackbarDemo(message: 'Print failed: $e').showCustomSnackbar(context);
      }
    }
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

    // Use data from response where available, fallback to cubit data
    final finalReceiptFooter = data?.receiptFooter ?? receiptFooterFromCubit;
    final finalCustomerDetails =
        data?.customerDetails ?? customerDetailsFromCubit;
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
        data?.assignedItems?.fold<double>(
          0.0,
          (sum, item) => sum + (item.salePriceIncVat ?? 0),
        ) ??
        0.0;

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
        jobTrackingNumber:
            _completeJobData?.data?.jobTrackingNumber ??
            data?.jobTrackingNumber ??
            data?.jobNo,
        assignedItems: assignedItemsList,
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
        receiptFooter: finalReceiptFooter != null
            ? my_jobs.ReceiptFooter(
                companyLogo: finalReceiptFooter.companyLogo,
                companyLogoURL:
                    finalReceiptFooter.companyLogoURL.isNotEmpty &&
                        !finalReceiptFooter.companyLogoURL.startsWith('http')
                    ? 'https://api.repaircms.com/file-upload/download/new?imagePath=${finalReceiptFooter.companyLogoURL}'
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
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _goHome(),
          ),
          title: Text(
            'Thermal Receipt Preview',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _showPrinterSelection,
              tooltip: 'Print',
            ),
          ],
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
                    child: ThermalReceiptWidget(
                      jobData: _completeJobData ?? _convertToSingleJobModel(),
                      logoEnabled: true,
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
