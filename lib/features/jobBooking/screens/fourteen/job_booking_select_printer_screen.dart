import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/fileUpload/job_file_upload_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/job_create_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/features/jobBooking/screens/job_receipt_preview_screen.dart';
import 'package:repair_cms/features/jobBooking/screens/job_device_label_screen.dart';

class JobBookingSelectPrinterScreen extends StatefulWidget {
  final String jobId;
  const JobBookingSelectPrinterScreen({super.key, required this.jobId});

  @override
  State<JobBookingSelectPrinterScreen> createState() => _JobBookingSelectPrinterScreenState();
}

class _JobBookingSelectPrinterScreenState extends State<JobBookingSelectPrinterScreen> {
  String _selectedPrinterType = 'A4 Receipt'; // Default value

  @override
  void initState() {
    super.initState();
    debugPrint(
      '🎯 [SelectPrinter] Screen initialized - receipt footer should already be in JobBookingCubit from step 2',
    );
  }

  void _selectPrinterType(String printerTypeId) {
    setState(() {
      _selectedPrinterType = printerTypeId;
    });
  }

  void _createJobAndNavigate() {
    if (_selectedPrinterType.isNotEmpty) {
      // Update print option in JobBookingCubit
      context.read<JobBookingCubit>().updatePrintOption(_selectedPrinterType);

      // Get user data for job status
      final storage = GetStorage();
      final userId = storage.read('userId') ?? '';
      final userName = storage.read('fullName') ?? 'User';
      final jobBookingState = context.read<JobBookingCubit>().state;

      if (jobBookingState is JobBookingData) {
        // Get contact email for notifications
        final contactEmail = jobBookingState.contact.email;

        debugPrint('✅ [CreateJob] Receipt footer already loaded from step 2');
        debugPrint('📋 [CreateJob] Company Name in footer: ${jobBookingState.job.receiptFooter.address.companyName}');
        debugPrint('📋 [CreateJob] Salutation length: ${jobBookingState.job.salutationHTMLmarkup.length}');
        debugPrint('📋 [CreateJob] Terms length: ${jobBookingState.job.termsAndConditionsHTMLmarkup.length}');

        // Update job status to "booked"
        context.read<JobBookingCubit>().updateJobStatusToBooked(
          userId: userId,
          userName: userName,
          email: contactEmail,
        );
      }

      // Get the complete job request with updated status, receipt footer, and receipt data
      final jobRequest = context.read<JobBookingCubit>().getCreateJobRequest();

      debugPrint('📋 [UpdateJob] ========== JOB UPDATE PAYLOAD ==========');
      debugPrint('📋 [UpdateJob] Job status: ${jobRequest.job.status}');
      debugPrint('📋 [UpdateJob] Job status array: ${jobRequest.job.jobStatus.length} items');
      debugPrint('📋 [UpdateJob] ========== RECEIPT FOOTER DATA ==========');
      debugPrint('📋 [UpdateJob] Logo URL: ${jobRequest.job.receiptFooter.companyLogoURL}');
      debugPrint('📋 [UpdateJob] Company Name: ${jobRequest.job.receiptFooter.address.companyName}');
      debugPrint(
        '📋 [UpdateJob] Street: ${jobRequest.job.receiptFooter.address.street} ${jobRequest.job.receiptFooter.address.num}',
      );
      debugPrint(
        '📋 [UpdateJob] City: ${jobRequest.job.receiptFooter.address.zip} ${jobRequest.job.receiptFooter.address.city}',
      );
      debugPrint('📋 [UpdateJob] Country: ${jobRequest.job.receiptFooter.address.country}');
      debugPrint('📋 [UpdateJob] CEO: ${jobRequest.job.receiptFooter.contact.ceo}');
      debugPrint('📋 [UpdateJob] Telephone: ${jobRequest.job.receiptFooter.contact.telephone}');
      debugPrint('📋 [UpdateJob] Email: ${jobRequest.job.receiptFooter.contact.email}');
      debugPrint('📋 [UpdateJob] Website: ${jobRequest.job.receiptFooter.contact.website}');
      debugPrint('📋 [UpdateJob] Bank Name: ${jobRequest.job.receiptFooter.bank.bankName}');
      debugPrint('📋 [UpdateJob] IBAN: ${jobRequest.job.receiptFooter.bank.iban}');
      debugPrint('📋 [UpdateJob] BIC: ${jobRequest.job.receiptFooter.bank.bic}');
      debugPrint('📋 [UpdateJob] ========== RECEIPT HTML DATA ==========');
      debugPrint('📋 [UpdateJob] Salutation length: ${jobRequest.job.salutationHTMLmarkup.length}');
      debugPrint('📋 [UpdateJob] Terms length: ${jobRequest.job.termsAndConditionsHTMLmarkup.length}');
      debugPrint('📋 [UpdateJob] =====================================');

      // Update the job using JobCreateCubit
      context.read<JobCreateCubit>().updateJob(request: jobRequest, jobId: widget.jobId);
    }
  }

  void _showSuccessAndNavigate() {
    // Navigate to appropriate screen based on printer type selection
    final jobCreateState = context.read<JobCreateCubit>().state;
    if (jobCreateState is JobCreateCreated && jobCreateState.response.data != null) {
      if (_selectedPrinterType == 'Device Label') {
        // Navigate to device label screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                JobDeviceLabelScreen(jobResponse: jobCreateState.response, printOption: _selectedPrinterType),
          ),
        );
      } else {
        // Navigate to receipt preview screen for A4 and Thermal receipts
        debugPrint('📄 [SelectPrinter] Navigating to receipt preview with complete job data');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                JobReceiptPreviewScreen(jobResponse: jobCreateState.response, printOption: _selectedPrinterType),
          ),
        );
      }
    } else {
      // Fallback: show snackbar and go home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<JobCreateCubit, JobCreateState>(
          listener: (context, state) {
            if (state is JobCreateCreated) {
              // Job created successfully
              debugPrint('✅ Job created successfully with ID: ${state.response.data?.sId}');

              // Upload files to server if there are any
              final jobBookingState = context.read<JobBookingCubit>().state;
              if (jobBookingState is JobBookingData &&
                  jobBookingState.job.files != null &&
                  jobBookingState.job.files!.isNotEmpty &&
                  state.response.data?.sId != null) {
                final storage = GetStorage();
                final userId = storage.read('userId') ?? '';
                final jobId = state.response.data!.sId;

                debugPrint('📤 Uploading ${jobBookingState.job.files!.length} files to server...');

                // Prepare file data for upload (array of objects with 'file' key)
                final fileData = jobBookingState.job.files!.map((f) => f.toJson()).toList();

                context.read<JobFileUploadCubit>().uploadFiles(userId: userId, jobId: jobId!, fileData: fileData);
              } else {
                // No files to upload, show success and navigate
                _showSuccessAndNavigate();
              }
            } else if (state is JobCreateError) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create job: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
        BlocListener<JobFileUploadCubit, JobFileUploadState>(
          listener: (context, state) {
            if (state is JobFileUploadSuccess) {
              debugPrint('✅ Files uploaded successfully');
              _showSuccessAndNavigate();
            } else if (state is JobFileUploadError) {
              debugPrint('⚠️ File upload failed: ${state.message}');
              // Job was created but file upload failed - still show success but with warning
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Job created but file upload failed: ${state.message}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              Container(
                height: 12.h,
                width: MediaQuery.of(context).size.width * .071 * 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF71788F),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                          ),
                        ),
                      ),

                      // Step indicator
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 42.w,
                          height: 42.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Center(
                            child: Text('14', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Title
                      Text('Select Printer Type', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                      SizedBox(height: 48.h),

                      // Printer options
                      Row(
                        children: [
                          // A4 Receipt option
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectPrinterType('A4 Receipt'),
                              child: Container(
                                height: 120.h,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: _selectedPrinterType == 'A4 Receipt'
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width: _selectedPrinterType == 'A4 Receipt' ? 2 : 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.print, size: 32.sp, color: Colors.grey.shade700),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'A4\nReceipt',
                                          style: AppTypography.fontSize14.copyWith(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    if (_selectedPrinterType == 'A4 Receipt')
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20.w,
                                          height: 20.h,
                                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                          child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // Thermal Receipt option
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectPrinterType('Thermal Receipt'),
                              child: Container(
                                height: 120.h,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: _selectedPrinterType == 'Thermal Receipt'
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width: _selectedPrinterType == 'Thermal Receipt' ? 2 : 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.receipt_long, size: 32.sp, color: Colors.grey.shade700),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Thermal\nReceipt',
                                          style: AppTypography.fontSize14.copyWith(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    if (_selectedPrinterType == 'Thermal Receipt')
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20.w,
                                          height: 20.h,
                                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                          child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Device Label option (full width)
                      GestureDetector(
                        onTap: () => _selectPrinterType('Device Label'),
                        child: Container(
                          height: 120.h,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: _selectedPrinterType == 'Device Label' ? AppColors.primary : Colors.grey.shade300,
                              width: _selectedPrinterType == 'Device Label' ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.label, size: 32.sp, color: Colors.grey.shade700),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Device Label',
                                    style: AppTypography.fontSize14.copyWith(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              if (_selectedPrinterType == 'Device Label')
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 20.w,
                                    height: 20.h,
                                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Loading state
                      BlocBuilder<JobCreateCubit, JobCreateState>(
                        builder: (context, state) {
                          if (state is JobCreateLoading) {
                            return Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16.h),
                                Text(
                                  'Creating job...',
                                  style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600),
                                ),
                                SizedBox(height: 16.h),
                              ],
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),

                      // Create Job button
                      BottomButtonsGroup(
                        onPressed:
                            _selectedPrinterType.isNotEmpty && context.read<JobCreateCubit>().state is! JobCreateLoading
                            ? _createJobAndNavigate
                            : null,
                        okButtonText: 'Create Job',
                      ),

                      SizedBox(height: 32.h),
                    ],
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
