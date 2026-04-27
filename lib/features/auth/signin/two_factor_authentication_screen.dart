import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/app_typography.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/utils/buttons/custom_button.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_cms/core/routes/route_names.dart';

class TwoFactorAuthenticationScreen extends StatefulWidget {
  final String? email;
  final String? twoFactorEmail;
  final bool bothEnabled;
  final bool appBasedAuthEnabled;
  final bool emailBasedAuthEnabled;

  const TwoFactorAuthenticationScreen({
    super.key,
    this.email,
    this.twoFactorEmail,
    this.bothEnabled = false,
    this.appBasedAuthEnabled = false,
    this.emailBasedAuthEnabled = false,
  });

  @override
  State<TwoFactorAuthenticationScreen> createState() => _TwoFactorAuthenticationScreenState();
}

class _TwoFactorAuthenticationScreenState extends State<TwoFactorAuthenticationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _rememberDevice = false;
  late bool _showSelection;
  String _selectedMethod = 'app'; // Default

  // Timer State
  int _remainingSeconds = 85; // 01:25
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _showSelection = widget.bothEnabled;

    // Set initial selected method based on what's available
    if (widget.appBasedAuthEnabled) {
      _selectedMethod = 'app';
    } else if (widget.emailBasedAuthEnabled) {
      _selectedMethod = 'email';
    }

    if (!_showSelection && _selectedMethod == 'email') {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 85;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 64.h,
      textStyle: AppTypography.sfProHeadLineTextStyle28.copyWith(fontSize: 24.sp, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deviderColor.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: AppColors.primary)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocConsumer<SignInCubit, SignInStates>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              context.go(RouteNames.home);
            } else if (state is SignInError) {
              SnackbarDemo(message: state.message).showCustomSnackbar(context);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      CustomNavButton(
                        onPressed: () {
                          if (_showSelection) {
                            Navigator.pop(context);
                          } else if (widget.bothEnabled) {
                            setState(() {
                              _showSelection = true;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: Icons.arrow_back_ios_new,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _showSelection
                        ? _buildSelectionUI()
                        : _buildInputUI(context, state, defaultPinTheme, focusedPinTheme),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectionUI() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Icon(SolarIconsBold.smartphone, size: 80.sp, color: AppColors.fontMainColor.withValues(alpha: 0.8)),
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          '2-Factor Authentication',
          style: AppTypography.sfProHeadLineTextStyle28.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 30.sp,
            color: const Color(0xFF1A1C1E),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Choose your authentication method',
          style: AppTypography.sfProHeadLineTextStyle22.copyWith(
            color: AppColors.fontMainColor.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
            fontSize: 20.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),
        _buildMethodOption(
          title: 'Trusted Email',
          value: 'email',
          groupValue: _selectedMethod,
          onChanged: (val) => setState(() => _selectedMethod = val!),
        ),
        SizedBox(height: 16.h),
        _buildMethodOption(
          title: 'Authentication App',
          value: 'app',
          groupValue: _selectedMethod,
          onChanged: (val) => setState(() => _selectedMethod = val!),
        ),
        SizedBox(height: 48.h),
        CustomButton(
          text: 'Continue',
          onPressed: () {
            setState(() {
              _showSelection = false;
              if (_selectedMethod == 'email') {
                _startTimer();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildMethodOption({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.deviderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.deviderColor, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: AppTypography.sfProHintTextStyle17.copyWith(
                color: isSelected ? AppColors.primary : AppColors.fontMainColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputUI(BuildContext context, SignInStates state, PinTheme defaultPinTheme, PinTheme focusedPinTheme) {
    final isApp = _selectedMethod == 'app';

    return Column(
      children: [
        SizedBox(height: 20.h),
        Center(
          child: Icon(SolarIconsBold.smartphone, size: 80.sp, color: AppColors.fontMainColor.withValues(alpha: 0.8)),
        ),
        SizedBox(height: 32.h),
        Text(
          '2-Factor Authentication',
          style: AppTypography.sfProHeadLineTextStyle28.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 30.sp,
            color: const Color(0xFF1A1C1E),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          isApp ? 'Authentication App' : 'Verify your email',
          style: AppTypography.sfProHeadLineTextStyle22.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text.rich(
            TextSpan(
              text: isApp
                  ? 'Copy the six-digit authentication code from your '
                  : 'Please fill in the code which has been sent to ',
              style: AppTypography.sfProHintTextStyle17.copyWith(
                color: AppColors.fontMainColor.withValues(alpha: 0.7),
                fontSize: 16.sp,
              ),
              children: [
                TextSpan(
                  text: isApp ? 'Authentication App' : (widget.twoFactorEmail ?? widget.email ?? ''),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 32.h),
        Pinput(
          length: 6,
          controller: _pinController,
          focusNode: _pinFocusNode,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          separatorBuilder: (index) => SizedBox(width: 8.w),
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: (pin) {
            if (widget.email != null) {
              context.read<SignInCubit>().verify2FA(email: widget.email!, code: pin, authType: isApp ? 'app' : 'email');
            }
          },
        ),
        SizedBox(height: 24.h),
        if (!isApp) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, size: 18.sp, color: AppColors.fontMainColor.withValues(alpha: 0.6)),
              SizedBox(width: 4.w),
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.fontMainColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text.rich(
              TextSpan(
                text: 'Did you not get the code? Please check your spam folder or ',
                style: TextStyle(fontSize: 14.sp, color: AppColors.fontMainColor.withValues(alpha: 0.6)),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: _remainingSeconds == 0
                          ? () async {
                              if (widget.email != null) {
                                await context.read<SignInCubit>().resend2FAEmailOtp(widget.email!);
                                _startTimer();
                                if (context.mounted) {
                                  SnackbarDemo(message: 'Code resent successfully').showCustomSnackbar(context);
                                }
                              }
                            }
                          : null,
                      child: Text(
                        'resend verification code',
                        style: TextStyle(
                          color: _remainingSeconds == 0 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        SizedBox(height: 32.h),
        GestureDetector(
          onTap: () => setState(() => _rememberDevice = !_rememberDevice),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.deviderColor),
                  color: _rememberDevice ? AppColors.primary : Colors.transparent,
                ),
                child: _rememberDevice ? Icon(Icons.check, size: 14.sp, color: Colors.white) : null,
              ),
              SizedBox(width: 8.w),
              Text(
                'Remember This Device',
                style: TextStyle(fontSize: 15.sp, color: AppColors.fontMainColor.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        CustomButton(
          text: 'Verify',
          isLoading: state is SignInLoading,
          onPressed: state is SignInLoading
              ? null
              : () {
                  if (_pinController.text.length == 6 && widget.email != null) {
                    context.read<SignInCubit>().verify2FA(
                      email: widget.email!,
                      code: _pinController.text,
                      authType: isApp ? 'app' : 'email',
                    );
                  }
                },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
