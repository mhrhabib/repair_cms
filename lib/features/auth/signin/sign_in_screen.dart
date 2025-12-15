// ignore_for_file: use_build_context_synchronously

import 'package:local_auth/local_auth.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/services/biometric_storage_service.dart';
import 'package:repair_cms/features/auth/widgets/three_dots_pointer_widget.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/auth/signin/repo/sign_in_repository.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEmailValid = false;
  bool _showBiometricOption = false;
  bool _hasCheckedBiometric = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);

    // Open keyboard automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
      _checkBiometricOnStart();
    });

    _emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _checkBiometricOnStart() async {
    try {
      final isBiometricEnabled = await BiometricStorageService.isBiometricEnabled();
      final hasCredentials = await BiometricStorageService.hasBiometricCredentials();

      setState(() {
        _showBiometricOption = isBiometricEnabled && hasCredentials;
        _hasCheckedBiometric = true;
      });

      // SHOW DIALOG AUTOMATICALLY if biometric is enabled
      if (isBiometricEnabled && hasCredentials) {
        // Add a small delay to ensure the screen is fully built
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('Error checking biometric status: $e');
      setState(() {
        _hasCheckedBiometric = true;
      });
    }
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email) && email.isNotEmpty;
    });
  }

  void _navigateToPasswordScreen(String email) {
    context.push(RouteNames.passwordInput, extra: email);
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    //Show loading until biometric check is complete
    if (!_hasCheckedBiometric) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return BlocProvider(
      create: (context) => SignInCubit(repository: SignInRepository()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: isLargeScreen ? 600 : screenWidth * 0.9,
                child: BlocConsumer<SignInCubit, SignInStates>(
                  listener: (context, state) {
                    if (state is SignInSuccess) {
                      SnackbarDemo(message: state.message).showCustomSnackbar(context);
                      _navigateToPasswordScreen(state.email);
                    } else if (state is SignInError) {
                      SnackbarDemo(message: state.message).showCustomSnackbar(context);
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
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              'Sign Into your Account',
                              style: AppTypography.sfProHeadLineTextStyle28,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Responsive spacing: smaller when keyboard is visible
                          // Use keyboard visibility only so auto-focus doesn't force small gap when idle
                          SizedBox(
                            height: (MediaQuery.of(context).viewInsets.bottom > 0)
                                ? screenHeight *
                                      0.02 // small gap when keyboard shown
                                : screenHeight * 0.12, // reasonable large gap when idle
                          ),

                          // Email Input
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.diviverColor)),
                            ),
                            child: Row(
                              children: [
                                Text('Email', style: AppTypography.sfProHintTextStyle17),
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    style: AppTypography.sfProHintTextStyle17,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      hintText: 'your@business.com',
                                      hintStyle: AppTypography.sfProHintTextStyle17,

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      suffixIcon: _isEmailValid
                                          ? Container(
                                              margin: EdgeInsets.only(right: RadiusConstants.md),
                                              child: Icon(Icons.check_circle, color: AppColors.greenColor, size: 30.w),
                                            )
                                          : null,
                                      errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    validator: _emailValidator,
                                    onFieldSubmitted: (_) {
                                      if (_formKey.currentState!.validate() && _isEmailValid) {
                                        context.read<SignInCubit>().findUserByEmail(_emailController.text.trim());
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Responsive spacing based on keyboard visibility
                          SizedBox(
                            height: (MediaQuery.of(context).viewInsets.bottom > 0)
                                ? screenHeight * 0.05
                                : screenHeight * 0.18,
                          ),

                          // Progress Indicator
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Bottom Button
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
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<SignInCubit, SignInStates>(
                      builder: (context, state) {
                        return CustomButton(
                          text: 'Confirm Email',
                          onPressed: state is SignInLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate() && _isEmailValid) {
                                    context.read<SignInCubit>().findUserByEmail(_emailController.text.trim());
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
                  ),
                  if (_showBiometricOption) ...[
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        onPressed: _authenticateWithBiometric,
                        icon: Icon(Icons.fingerprint, size: 28, color: Colors.white),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      debugPrint('🟢 Button clicked - starting biometric auth');

      final LocalAuthentication auth = LocalAuthentication();

      // Check availability - exactly like your demo
      final bool isAvailable = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      debugPrint('📱 isAvailable: $isAvailable, isDeviceSupported: $isDeviceSupported');

      if (!isAvailable || !isDeviceSupported) {
        SnackbarDemo(message: 'Biometric not available').showCustomSnackbar(context);
        return;
      }

      debugPrint('🚀 Calling authenticate - system prompt should appear now...');

      // Call authenticate - THIS should show the system bottom sheet
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to continue',
        // options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      debugPrint('✅ Authentication completed: $didAuthenticate');

      if (didAuthenticate) {
        debugPrint('🎉 Authentication successful!');

        // Get saved credentials
        final credentials = await BiometricStorageService.getBiometricCredentials();

        if (credentials['email'] != null && credentials['password'] != null) {
          _emailController.text = credentials['email']!;
          setState(() {
            _isEmailValid = true;
          });

          SnackbarDemo(message: 'Login successful!').showCustomSnackbar(context);

          if (mounted) {
            context.push(RouteNames.home, extra: credentials['email']!);
          }
        } else {
          SnackbarDemo(message: 'Credentials not found').showCustomSnackbar(context);
        }
      } else {
        debugPrint('❌ Authentication failed or canceled');
        SnackbarDemo(message: 'Authentication canceled').showCustomSnackbar(context);
      }
    } catch (e) {
      debugPrint('💥 Error: $e');
      SnackbarDemo(message: 'Error: $e').showCustomSnackbar(context);
    }
  }
}
