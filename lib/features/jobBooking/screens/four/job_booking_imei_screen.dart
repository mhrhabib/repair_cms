import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import '../five/job_booking_device_security_screen.dart';

class JobBookingImeiScreen extends StatefulWidget {
  const JobBookingImeiScreen({super.key});

  @override
  State<JobBookingImeiScreen> createState() => _JobBookingImeiScreenState();
}

class _JobBookingImeiScreenState extends State<JobBookingImeiScreen> {
  final TextEditingController _imeiController = TextEditingController();
  final FocusNode _imeiFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Pre-fill IMEI if already exists in cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        final existingImei = bookingState.device.imei;
        if (existingImei.isNotEmpty) {
          _imeiController.text = existingImei;
        }
      }
    });
  }

  void _updateImeiInCubit() {
    final imei = _imeiController.text.trim();
    context.read<JobBookingCubit>().updateDeviceInfo(imei: imei);
  }

  bool _isImeiValid() {
    final imei = _imeiController.text.trim();
    // Basic validation - you can add more specific IMEI validation if needed
    return imei.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 12.h,
              width: MediaQuery.of(context).size.width * .071 * 4,
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
                          child: Text('4', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Question text
                    Text(
                      'Enter Device IMEI / Serial No.',
                      style: AppTypography.fontSize22,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 8.h),

                    // Optional text
                    Text(
                      '(Optional)',
                      style: AppTypography.fontSize16.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 32.h),

                    // IMEI TextField
                    TextField(
                      controller: _imeiController,
                      focusNode: _imeiFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter IMEI or Serial Number...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        suffixIcon: _imeiController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey, size: 20.sp),
                                onPressed: () {
                                  _imeiController.clear();
                                  _updateImeiInCubit();
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {}); // Rebuild to update button state
                        _updateImeiInCubit();
                      },
                      onSubmitted: (value) {
                        _updateImeiInCubit();
                        if (_isImeiValid()) {
                          _navigateToNextScreen();
                        }
                      },
                      textInputAction: TextInputAction.done,
                    ),

                    SizedBox(height: 16.h),

                    // Helper text
                    // Container(
                    //   padding: EdgeInsets.all(12.w),
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.shade50,
                    //     borderRadius: BorderRadius.circular(8.r),
                    //     border: Border.all(color: Colors.blue.shade100),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18.sp),
                    //       SizedBox(width: 8.w),
                    //       Expanded(
                    //         child: Text(
                    //           'IMEI is optional but recommended for better device tracking',
                    //           style: AppTypography.fontSize12.copyWith(color: Colors.blue.shade800),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Show current IMEI from cubit
                    BlocBuilder<JobBookingCubit, JobBookingState>(
                      builder: (context, state) {
                        if (state is JobBookingData && state.device.imei.isNotEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.green.shade100),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'IMEI Saved',
                                          style: AppTypography.fontSize12.copyWith(color: Colors.green.shade800),
                                        ),
                                        Text(
                                          state.device.imei,
                                          style: AppTypography.fontSize12.copyWith(color: Colors.green.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _imeiController.clear();
                                      context.read<JobBookingCubit>().updateDeviceInfo(imei: '');
                                    },
                                    child: Icon(Icons.clear, color: Colors.green.shade600, size: 16.sp),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),

                    const Spacer(),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 8.h : 8.h,
          left: 24.w,
          right: 24.w,
        ),
        child: BlocBuilder<JobBookingCubit, JobBookingState>(
          builder: (context, state) {
            //  final hasImei = state is JobBookingData && state.device.imei.isNotEmpty;

            return BottomButtonsGroup(
              onPressed: () {
                _navigateToNextScreen();
              },
              // Optional: You can make it always enabled since IMEI is optional
              // Or keep it enabled only when IMEI is entered
              // For now, I'll make it always enabled since IMEI is optional
            );
          },
        ),
      ),
    );
  }

  void _navigateToNextScreen() {
    // Save the IMEI before navigating
    _updateImeiInCubit();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => JobBookingDeviceSecurityScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    final imei = _imeiController.text.trim();
    if (imei.isNotEmpty) {
      SnackbarDemo(message: 'IMEI saved: $imei').showCustomSnackbar(context);
    }
  }

  @override
  void dispose() {
    _imeiController.dispose();
    _imeiFocusNode.dispose();
    super.dispose();
  }
}
