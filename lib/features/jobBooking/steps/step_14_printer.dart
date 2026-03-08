import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/job_create_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 14 – Select Printer Type (Final Step)
/// This step updates the job to "booked" and prepares for receipt navigation.
class StepPrinterWidget extends StatefulWidget {
  const StepPrinterWidget({
    super.key,
    required this.onCanProceedChanged,
    required this.jobId,
    required this.onJobBooked,
  });

  final void Function(bool canProceed) onCanProceedChanged;
  final String jobId;
  final void Function(String printerType) onJobBooked;

  @override
  State<StepPrinterWidget> createState() => StepPrinterWidgetState();
}

class StepPrinterWidgetState extends State<StepPrinterWidget> {
  String _selectedPrinterType = 'A4 Receipt'; // Default value
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Always can proceed since default is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(true);
    });
  }

  void _selectPrinterType(String type) {
    setState(() => _selectedPrinterType = type);
  }

  /// Exposed for wizard navigation - The FINAL action
  Future<bool> validate() async {
    if (_isLoading) return false;
    setState(() => _isLoading = true);

    final jobBookingCubit = context.read<JobBookingCubit>();
    jobBookingCubit.updatePrintOption(_selectedPrinterType);

    final userId = storage.read('userId') ?? '';
    final userName = storage.read('fullName') ?? 'User';
    final state = jobBookingCubit.state;

    if (state is JobBookingData) {
      // Update status to 'booked'
      jobBookingCubit.updateJobStatusToBooked(
        userId: userId,
        userName: userName,
        email: state.contact.email,
      );

      try {
        final jobRequest = jobBookingCubit.getCreateJobRequest();
        context.read<JobCreateCubit>().updateJob(
          request: jobRequest,
          jobId: widget.jobId,
        );
        return false; // Wait for BlocListener in build()
      } catch (e) {
        showCustomToast('Error updating job: $e', isError: true);
        setState(() => _isLoading = false);
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<JobCreateCubit, JobCreateState>(
          listener: (context, state) {
            if (state is JobCreateCreated) {
              // Finalize and notify wizard
              setState(() => _isLoading = false);
              widget.onJobBooked(_selectedPrinterType);
            } else if (state is JobCreateError) {
              showCustomToast(
                'Failed to update job: ${state.message}',
                isError: true,
              );
              setState(() => _isLoading = false);
            }
          },
        ),
      ],
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    TitleWidget(
                      stepNumber: 14,
                      title: 'Select Printer Type',
                      subTitle: 'Confirm receipt and label printing',
                    ),
                    SizedBox(height: 48.h),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPrinterOption(
                          icon: Icons.print,
                          label: 'A4\nReceipt',
                          type: 'A4 Receipt',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildPrinterOption(
                          icon: Icons.receipt_long,
                          label: 'Thermal\nReceipt',
                          type: 'Thermal Receipt',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox(),
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildPrinterOption({
    required IconData icon,
    required String label,
    required String type,
  }) {
    final isSelected = _selectedPrinterType == type;
    return GestureDetector(
      onTap: () => _selectPrinterType(type),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32.sp, color: Colors.grey.shade700),
                SizedBox(height: 8.h),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.fontSize14.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
