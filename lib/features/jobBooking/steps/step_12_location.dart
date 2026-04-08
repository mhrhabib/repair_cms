import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 12 – Physical Location (Storage during service)
class StepLocationWidget extends StatefulWidget {
  const StepLocationWidget({super.key, required this.onCanProceedChanged});

  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepLocationWidget> createState() => StepLocationWidgetState();
}

class StepLocationWidgetState extends State<StepLocationWidget> {
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.addListener(_updateCanProceed);
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<JobBookingCubit>().state;
      if (state is JobBookingData && state.job.physicalLocation != null) {
        _locationController.text = state.job.physicalLocation!;
      }
      widget.onCanProceedChanged(_locationController.text.trim().isNotEmpty);
    });
  }

  void _updateCanProceed() {
    if (mounted) {
      widget.onCanProceedChanged(_locationController.text.trim().isNotEmpty);
    }
  }

  /// Exposed for wizard navigation
  bool validate() {
    if (_locationController.text.trim().isNotEmpty) {
      context.read<JobBookingCubit>().updatePhysicalLocation(
        _locationController.text.trim(),
      );
      return true;
    }
    showCustomToast('Please specify a storage location', isError: true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TitleWidget(
                  stepNumber: 12,
                  title: 'Physical Location',
                  subTitle: '(Storage during service)',
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _locationController,
                  cursorColor: AppColors.warningColor,
                  style: GoogleFonts.roboto(fontSize: 22.sp),
                  decoration: InputDecoration(
                    hintText: 'Answer here',
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 22.sp,
                      color: Color(0xFFB2B5BE),
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightFontColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightFontColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightFontColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Specify where the device will be stored during repair service (e.g., Shelf 12D, Room A, Locker 5)',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
        const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
      ],
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
