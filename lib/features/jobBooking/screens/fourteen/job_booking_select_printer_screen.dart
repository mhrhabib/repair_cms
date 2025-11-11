import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/job_create_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingSelectPrinterScreen extends StatefulWidget {
  const JobBookingSelectPrinterScreen({super.key});

  @override
  State<JobBookingSelectPrinterScreen> createState() =>
      _JobBookingSelectPrinterScreenState();
}

class _JobBookingSelectPrinterScreenState
    extends State<JobBookingSelectPrinterScreen> {
  String _selectedPrinterType = 'A4 Receipt'; // Default value

  void _selectPrinterType(String printerTypeId) {
    setState(() {
      _selectedPrinterType = printerTypeId;
    });
  }

  void _createJobAndNavigate() {
    if (_selectedPrinterType.isNotEmpty) {
      // Update print option in JobBookingCubit
      context.read<JobBookingCubit>().updatePrintOption(_selectedPrinterType);

      // Get the complete job request
      final jobRequest = context.read<JobBookingCubit>().getCreateJobRequest();

      // Create the job using JobCreateCubit
      context.read<JobCreateCubit>().createJob(request: jobRequest);
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Job created successfully!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Navigate to success screen or back to home
              Navigator.popUntil(context, (route) => route.isFirst);
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 1,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
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
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24.sp,
                            ),
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
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '14',
                              style: AppTypography.fontSize24.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        'Select Printer Type',
                        style: AppTypography.fontSize22,
                        textAlign: TextAlign.center,
                      ),

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
                                    width: _selectedPrinterType == 'A4 Receipt'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.print,
                                          size: 32.sp,
                                          color: Colors.grey.shade700,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'A4\nReceipt',
                                          style: AppTypography.fontSize14
                                              .copyWith(
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
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12.sp,
                                          ),
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
                              onTap: () =>
                                  _selectPrinterType('Thermal Receipt'),
                              child: Container(
                                height: 120.h,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color:
                                        _selectedPrinterType ==
                                            'Thermal Receipt'
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width:
                                        _selectedPrinterType ==
                                            'Thermal Receipt'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          size: 32.sp,
                                          color: Colors.grey.shade700,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Thermal\nReceipt',
                                          style: AppTypography.fontSize14
                                              .copyWith(
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    if (_selectedPrinterType ==
                                        'Thermal Receipt')
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20.w,
                                          height: 20.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12.sp,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                                  style: AppTypography.fontSize14.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
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
                            _selectedPrinterType.isNotEmpty &&
                                context.read<JobCreateCubit>().state
                                    is! JobCreateLoading
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
