import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/services/biometric_storage_service.dart';
import 'package:repair_cms/features/auth/forgotPassword/cubit/forgot_password_cubit.dart';
import 'package:repair_cms/features/auth/signin/sign_in_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });
  final String email;
  final String otp;

  @override
  State<SetNewPasswordScreen> createState() => SetNewPasswordScreenState();
}

class SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordValid = false;
  bool _obscureText = true;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _loadBiometricPreference();
  }

  void _loadBiometricPreference() async {
    final isEnabled = await BiometricStorageService.isBiometricEnabled();
    setState(() {
      _isBiometricEnabled = isEnabled;
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _isPasswordValid = password.isNotEmpty && password.length >= 6;
    });
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate() && _isPasswordValid) {
      final cubit = context.read<ForgotPasswordCubit>();

      // Save biometric credentials if enabled
      if (_isBiometricEnabled) {
        await _saveBiometricCredentials();
      }

      cubit.resetPassword(widget.email, _passwordController.text, widget.otp);
    }
  }

  Future<void> _saveBiometricCredentials() async {
    try {
      final storage = GetStorage();
      final userId = storage.read('userId')?.toString();
      await BiometricStorageService.saveBiometricCredentials(
        email: widget.email,
        password: _passwordController.text,
        userId: userId,
      );
      showCustomToast('Biometric authentication enabled');
    } catch (e) {
      showCustomToast('Failed to save biometric credentials', isError: true);
    }
  }

  void _toggleBiometricPreference() async {
    setState(() {
      _isBiometricEnabled = !_isBiometricEnabled;
    });

    // Save the preference immediately
    if (_isBiometricEnabled) {
      showCustomToast('Biometric authentication enabled');
    } else {
      await BiometricStorageService.disableBiometric();
      showCustomToast('Biometric authentication disabled');
    }
  }

  void _navigateToLoginScreen() {
    // Navigate to login screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          showCustomToast('Password reset successfully!', isError: false);
          _navigateToLoginScreen();
        } else if (state is ForgotPasswordError) {
          showCustomToast(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColors.primary,
            weight: 800,
            fill: 0.4,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: SizedBox(
                width: isLargeScreen ? 600 : screenWidth * 0.9,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Text(
                          'Enter New Password',
                          style: AppTypography.sfProHeadLineTextStyle28,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          'You are almost there!',
                          style: AppTypography.sfProText15.copyWith(
                            color: AppColors.fontMainColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 80.h),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.deviderColor),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Password Input Field
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.deviderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Password',
                              style: AppTypography.sfProHintTextStyle17,
                            ),
                            Expanded(
                              child:
                                  BlocBuilder<
                                    ForgotPasswordCubit,
                                    ForgotPasswordState
                                  >(
                                    builder: (context, state) {
                                      final isLoading =
                                          state is ForgotPasswordLoading;

                                      return TextFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        style:
                                            AppTypography.sfProHintTextStyle17,
                                        textInputAction: TextInputAction.done,
                                        obscureText: _obscureText,
                                        enabled: !isLoading,
                                        decoration: InputDecoration(
                                          hintText: 'Min. 6 Characters',
                                          hintStyle: AppTypography
                                              .sfProHintTextStyle17
                                              .copyWith(
                                                color: AppColors.deviderColor,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_isPasswordValid)
                                                GestureDetector(
                                                  onTap:
                                                      _togglePasswordVisibility,
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 8,
                                                        ),
                                                    child: Icon(
                                                      _obscureText
                                                          ? Icons.visibility
                                                          : Icons
                                                                .visibility_off,
                                                      color: Colors.grey[600],
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          errorStyle: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        validator: _passwordValidator,
                                        onFieldSubmitted: (_) =>
                                            _resetPassword(),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Biometric Toggle
                      GestureDetector(
                        onTap: _toggleBiometricPreference,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _isBiometricEnabled
                                    ? AppColors.greenColor
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isBiometricEnabled
                                      ? AppColors.greenColor
                                      : Colors.grey[400]!,
                                  width: 1,
                                ),
                              ),
                              child: _isBiometricEnabled
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Enable Face ID/Fingerprint for quick login',
                              style: AppTypography.sfProText15.copyWith(
                                color: _isBiometricEnabled
                                    ? AppColors.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Your credentials will be securely stored for faster login',
                        style: AppTypography.fontSize14.copyWith(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.deviderColor),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Set New Password Button
                      BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                        builder: (context, state) {
                          final isLoading = state is ForgotPasswordLoading;

                          return CustomButton(
                            text: 'Set New Password',
                            onPressed: isLoading ? null : _resetPassword,
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.whiteColor,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
