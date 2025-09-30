import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/services/biometric_service.dart';
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
  final BiometricService _biometricService = BiometricService();

  bool _isPasswordValid = false;
  bool _obscureText = true;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _checkBiometricAvailability();
    _loadBiometricPreference();
  }

  void _checkBiometricAvailability() async {
    final canCheckBiometrics = await _biometricService.checkBiometrics();
    final availableBiometrics = await _biometricService.getAvailableBiometrics();

    setState(() {
      _isBiometricAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
      _biometricType = _biometricService.getBiometricTypeName(availableBiometrics);
    });
  }

  void _loadBiometricPreference() async {
    final isEnabled = await storage.read('biometric_enabled') ?? false;
    setState(() {
      _isBiometricEnabled = isEnabled;
    });
  }

  void _saveBiometricPreference(bool value) async {
    await storage.write('biometric_enabled', value);
    setState(() {
      _isBiometricEnabled = value;
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

  void _navigateToDashboard(User user) {
    context.pushReplacement(RouteNames.dashboard);
  }

  Future<void> _authenticateWithBiometrics() async {
    final isAuthenticated = await _biometricService.authenticate();
    if (isAuthenticated) {
      // Try to login with stored credentials
      final storedEmail = await storage.read('last_email');
      final storedPassword = await storage.read('last_password');

      if (storedEmail != null && storedPassword != null) {
        context.read<SignInCubit>().login(storedEmail, storedPassword);
      } else {
        showCustomToast('No stored credentials found', isError: true);
      }
    } else {
      showCustomToast('Authentication failed', isError: true);
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

                    // Store credentials if biometric is enabled
                    if (_isBiometricEnabled) {
                      storage.write('last_email', widget.email);
                      storage.write('last_password', _passwordController.text);
                    }

                    // Navigate based on user role or other conditions
                    if (state.user != null) {
                      if (state.user!.repaircmsAccess) {
                        _navigateToDashboard(state.user!);
                      } else {
                        _navigateToHome(state.user!);
                      }
                    } else {
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
                            'Sign Into your Account',
                            style: AppTypography.sfProHeadLineTextStyle28,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.08),

                        // Password Label
                        const SizedBox(height: 8),

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
                                                _obscureText ? Icons.visibility : Icons.visibility_off,
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
                        if (_isBiometricAvailable) ...[
                          GestureDetector(
                            onTap: () {
                              _saveBiometricPreference(!_isBiometricEnabled);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _isBiometricEnabled ? AppColors.greenColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[400]!, width: 1),
                                  ),
                                  child: _isBiometricEnabled ? Icon(Icons.check, color: Colors.white, size: 18) : null,
                                ),
                                const SizedBox(width: 12),
                                Text('Enable $_biometricType for authentication', style: AppTypography.sfProText15),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],

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
                        ThreeDotsPointerWidget(
                          primaryColor: AppColors.primary,
                          secondaryColor: AppColors.secondary,
                          activeIndex: 2,
                        ),

                        const SizedBox(height: 12),

                        // Biometric Login Button (if available and enabled)
                        if (_isBiometricAvailable && _isBiometricEnabled) ...[
                          CustomButton(
                            trailingIcon: Icon(
                              _biometricType.contains('Face') ? Icons.face : Icons.fingerprint,
                              size: 24.sp,
                            ),
                            text: 'Login with $_biometricType',
                            onPressed: _authenticateWithBiometrics,
                            backgroundColor: AppColors.secondary,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Sign In Button
                        CustomButton(
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
