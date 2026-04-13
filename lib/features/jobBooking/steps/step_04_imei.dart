import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 4 – IMEI / Serial Number (optional field, always can proceed)
class StepImeiWidget extends StatefulWidget {
  const StepImeiWidget({super.key, required this.onCanProceedChanged});

  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepImeiWidget> createState() => StepImeiWidgetState();
}

class StepImeiWidgetState extends State<StepImeiWidget> {
  final TextEditingController _imeiController = TextEditingController();
  final FocusNode _imeiFocusNode = FocusNode();

  bool validate() {
    final imei = _imeiController.text.trim();
    if (imei.isNotEmpty) {
      context.read<JobBookingCubit>().updateDeviceInfo(imei: imei);
      return true;
    }
    showCustomToast('Please enter IMEI or Serial Number', isError: true);
    return false;
  }

  @override
  void initState() {
    super.initState();
    // IMEI is optional – always allow proceeding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(true);
      _imeiFocusNode.requestFocus();
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData && bookingState.device.imei.isNotEmpty) {
        _imeiController.text = bookingState.device.imei;
      }
    });
  }

  void _updateImeiInCubit() {
    context.read<JobBookingCubit>().updateDeviceInfo(imei: _imeiController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 24.h),
          TitleWidget(stepNumber: 4, title: 'Enter Device IMEI / Serial No.', subTitle: '(Optional)'),
          SizedBox(height: 32.h),
          TextField(
            controller: _imeiController,
            focusNode: _imeiFocusNode,
            style: GoogleFonts.roboto(fontSize: 22.sp, fontWeight: FontWeight.w400, color: AppColors.fontMainColor),
            cursorColor: AppColors.warningColor,
            decoration: InputDecoration(
              hintText: 'Answer here',
              hintStyle: GoogleFonts.roboto(
                fontSize: 22.sp,
                color: const Color(0xFFB2B5BE),
                fontWeight: FontWeight.w400,
              ),
              border: UnderlineInputBorder(
                // borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: UnderlineInputBorder(
                // borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: UnderlineInputBorder(
                // borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              suffixIcon: _imeiController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey, size: 20.sp),
                      onPressed: () {
                        _imeiController.clear();
                        _updateImeiInCubit();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
              _updateImeiInCubit();
            },
            onSubmitted: (_) => _updateImeiInCubit(),
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _imeiController.dispose();
    _imeiFocusNode.dispose();
    super.dispose();
  }
}
