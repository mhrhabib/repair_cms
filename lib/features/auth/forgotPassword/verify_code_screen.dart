import 'dart:async';

import 'package:pinput/pinput.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/auth/forgotPassword/cubit/forgot_password_cubit.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 120;

  @override
  void initState() {
    _startTimer(initial: true);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer({required bool initial}) {
    if (!initial) {
      _secondsRemaining = 120;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        _otpController.clear();
        timer.cancel();
      } else {
        _secondsRemaining--;
      }
      setState(() {});
    });
  }

  void _resendOtp() {
    final cubit = context.read<ForgotPasswordCubit>();
    cubit.sendResetEmail(widget.email);
    _startTimer(initial: false);
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        } else if (state is ForgotPasswordOtpVerified) {
          // Navigate to reset password screen
          context.push(RouteNames.setNewPassword, extra: widget.email);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();
        final currentOtp = state is ForgotPasswordOtpState ? state.otp : '';
        final isLoading = state is ForgotPasswordLoading;

        return Scaffold(
          appBar: AppBar(iconTheme: IconThemeData(color: AppColors.primary, weight: 800, fill: 0.4)),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Text('Check Your Email!', textAlign: TextAlign.center, style: AppTypography.sfProHeadLineTextStyle28),
                SizedBox(height: 8.h),
                Text(
                  'Please fill in the code which has been sent to your email',
                  textAlign: TextAlign.center,
                  style: AppTypography.sfProText15,
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: AppTypography.sfProText15.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                SizedBox(height: 60.h),
                Text(
                  'Verification Code',
                  style: AppTypography.sfProHeadLineTextStyle28.copyWith(color: AppColors.primary, fontSize: 22.sp),
                ),
                SizedBox(height: 16.h),
                Pinput(
                  controller: _otpController,
                  enabled: (_timer?.isActive ?? false) && !isLoading,
                  length: 4,
                  defaultPinTheme: PinTheme(
                    width: 80.w,
                    height: 62.h,
                    textStyle: AppTypography.sfProHeadLineTextStyle28.copyWith(
                      color: AppColors.fontMainColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 42.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.secondary, width: 1.w),
                    ),
                  ),
                  showCursor: true,
                  onChanged: (value) {
                    cubit.updateOtp(value);
                    if (value.length == 4) {
                      cubit.verifyOtp(widget.email, value);
                    }
                  },
                  onCompleted: (pin) {
                    cubit.verifyOtp(widget.email, pin);
                  },
                ),
                SizedBox(height: 24.h),

                // Timer and Resend Section
                if (_timer?.isActive ?? false)
                  Text(
                    'Code expires in ${_formatTime(_secondsRemaining)}',
                    style: AppTypography.sfProText15.copyWith(color: AppColors.secondary),
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Didn\'t receive the code? Please check your spam folder',
                        textAlign: TextAlign.center,
                        style: AppTypography.sfProText15.copyWith(color: AppColors.secondary),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: _resendOtp,
                        child: Text(
                          'Resend verification code',
                          style: AppTypography.sfProText15.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 32.h),
                if (isLoading)
                  CircularProgressIndicator(color: AppColors.primary)
                else if (currentOtp.length == 4 && (_timer?.isActive ?? false))
                  Text('Verifying...', style: AppTypography.sfProText15.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        );
      },
    );
  }
}
