import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/services/biometric_storage_service.dart';
import 'package:repair_cms/features/auth/signin/models/login_response_model.dart';
import 'package:repair_cms/features/auth/widgets/three_dots_pointer_widget.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';

class PasswordInputScreen extends StatefulWidget {
  const PasswordInputScreen({super.key, required this.email});

  final String email;

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordValid = false;
  bool _obscureText = true;

  bool _hasStoredCredentials = false;
  final String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _isPasswordValid = password.isNotEmpty && password.length >= 6;
    });
  }

  void _navigateToHome(User user) {
    context.pushReplacement(RouteNames.home);
  }

  Future<void> _saveBiometricCredentials() async {
    try {
      await BiometricStorageService.saveBiometricCredentials(email: widget.email, password: _passwordController.text);
      showCustomToast('$_biometricType authentication enabled', isError: false);
    } catch (e) {
      showCustomToast('Failed to save $_biometricType credentials', isError: true);
    }
  }

  Future<void> _toggleBiometricAuthentication() async {
    if (_hasStoredCredentials) {
      // Disable biometric
      await BiometricStorageService.disableBiometric();
      setState(() {
        _hasStoredCredentials = false;
      });
      showCustomToast('$_biometricType authentication disabled');
    } else {
      // Enable biometric - Show confirmation dialog
      bool? shouldEnable = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Enable $_biometricType?'),
          content: Text('Do you want to enable $_biometricType authentication for quick login?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Enable')),
          ],
        ),
      );

      if (shouldEnable == true) {
        await _saveBiometricCredentials();
        setState(() {
          _hasStoredCredentials = true;
        });
      }
    }
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

  void _onForgotPassword() {
    context.push(RouteNames.passwordForgotten);
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(iconTheme: IconThemeData(color: AppColors.primary, weight: 800, fill: 0.4)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: isLargeScreen ? 600 : screenWidth * 0.9,
              child: BlocConsumer<SignInCubit, SignInStates>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    showCustomToast(state.message, isError: false);

                    // Navigate based on user role or other conditions
                    if (state.user != null) {
                      _navigateToHome(state.user!);
                    }
                  } else if (state is SignInError) {
                    showCustomToast(state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            'Enter Your Password',
                            style: AppTypography.sfProHeadLineTextStyle28,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        //SizedBox(height: screenHeight * 0.08),

                        // Email display
                        // Center(
                        //   child: Text(widget.email, style: AppTypography.sfProText15.copyWith(color: Colors.grey)),
                        // ),
                        SizedBox(height: 20),

                        // Password Input Field
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.diviverColor)),
                          ),
                          child: Row(
                            children: [
                              Text('Password', style: AppTypography.sfProHintTextStyle17),
                              Expanded(
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  style: AppTypography.sfProHintTextStyle17,
                                  textInputAction: TextInputAction.done,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: AppTypography.sfProHintTextStyle17,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_isPasswordValid)
                                          GestureDetector(
                                            onTap: _togglePasswordVisibility,
                                            child: Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              child: Icon(
                                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                                color: Colors.grey[600],
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: _passwordValidator,
                                  onFieldSubmitted: (_) {
                                    if (_formKey.currentState!.validate() && _isPasswordValid) {
                                      context.read<SignInCubit>().login(widget.email, _passwordController.text);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Biometric Authentication Toggle
                        GestureDetector(
                          onTap: _toggleBiometricAuthentication,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _hasStoredCredentials ? AppColors.greenColor : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[400]!, width: 1),
                                ),
                                child: _hasStoredCredentials ? Icon(Icons.check, color: Colors.white, size: 18) : null,
                              ),
                              const SizedBox(width: 12),
                              Text('Enable $_biometricType for quick login', style: AppTypography.sfProText15),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),

                        //
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.diviverColor)),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Forgot Password
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: _onForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: AppTypography.sfProText15.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Progress Indicator
                        const SizedBox(height: 20),

                        // Sign In Button
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ThreeDotsPointerWidget(
              primaryColor: AppColors.primary,
              secondaryColor: AppColors.secondary,
              activeIndex: 1,
            ),
            SizedBox(height: screenHeight * 0.02),
            BlocBuilder<SignInCubit, SignInStates>(
              builder: (context, state) {
                return CustomButton(
                  trailingIcon: Icon(Icons.login, size: 24.sp),
                  text: 'Log In',
                  onPressed: state is SignInLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate() && _isPasswordValid) {
                            context.read<SignInCubit>().login(widget.email, _passwordController.text);
                          }
                        },
                  child: state is SignInLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
                          ),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
