// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:local_auth/local_auth.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/services/biometric_storage_service.dart';
import 'package:repair_cms/features/auth/widgets/three_dots_pointer_widget.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';

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
  String? _emailError;
  bool _showValidationErrors = false;
  String _biometricType = 'Biometric';
  bool _biometricLoginInProgress = false;

  @override
  void initState() {
    super.initState();
    // Update basic validity while typing, but do not show errors until Confirm is pressed
    _emailController.addListener(() {
      final email = _emailController.text;
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[A-Za-z]{2,}$');
      setState(() {
        _isEmailValid = emailRegex.hasMatch(email) && email.isNotEmpty;
        // Clear displayed error while user is editing
        _emailError = null;
        _showValidationErrors = false;
      });
    });

    // Open keyboard automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
      _checkBiometricOnStart();
      _loadBiometricType();
    });

    _emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _checkBiometricOnStart() async {
    try {
      final isBiometricEnabled =
          await BiometricStorageService.isBiometricEnabled();
      final hasCredentials =
          await BiometricStorageService.hasBiometricCredentials();

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

  Future<void> _loadBiometricType() async {
    try {
      final type = await BiometricStorageService.getBiometricType();
      setState(() {
        _biometricType = type;
      });
      debugPrint('Loaded biometric type: $_biometricType');
    } catch (e) {
      debugPrint('Error loading biometric type: $e');
    }
  }

  /// Validate and optionally show error messages. When [showErrors]
  /// is false (default) this only updates `_isEmailValid` and clears
  /// visible errors. When true, it sets `_emailError` and enables
  /// `_showValidationErrors` so the UI will display the message.
  void _validateEmail({bool showErrors = false}) {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[A-Za-z]{2,}$');
    final isValid = emailRegex.hasMatch(email) && email.isNotEmpty;

    if (showErrors) {
      setState(() {
        _isEmailValid = isValid;
        if (email.isEmpty) {
          _emailError = 'Email cannot be empty';
        } else if (!emailRegex.hasMatch(email)) {
          _emailError = 'Please enter a valid email address';
        } else {
          _emailError = null;
        }
        _showValidationErrors = _emailError != null;
      });
    } else {
      // silent validation while typing
      setState(() {
        _isEmailValid = isValid;
        _emailError = null;
        _showValidationErrors = false;
      });
    }
  }

  void _navigateToPasswordScreen(String email) {
    context.push(RouteNames.passwordInput, extra: email);
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[A-Za-z]{2,}$');
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-check biometric status/type when the widget is re-inserted into the tree
    _checkBiometricOnStart();
    _loadBiometricType();
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
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: isLargeScreen ? 600 : screenWidth * 0.9,
                    child: BlocConsumer<SignInCubit, SignInStates>(
                  listener: (context, state) {
                    debugPrint('🔁 SignInScreen listener received state: ${state.runtimeType}');
                    if (state is LoginSuccess) {
                      debugPrint('🔐 LoginSuccess token: ${state.token}');
                    }
                    if (state is SignInSuccess) {
                      //SnackbarDemo(message: state.message).showCustomSnackbar(context);
                      _navigateToPasswordScreen(state.email);
                    } else if (state is LoginSuccess) {
                      // Clear biometric loading flag on successful login
                      if (_biometricLoginInProgress) {
                        setState(() {
                          _biometricLoginInProgress = false;
                        });
                      }

                      // After successful login token is stored by the cubit,
                      // navigate to home using GoRouter so RouteGuard sees token.
                      context.go(RouteNames.home);
                    } else if (state is SignInError) {
                      // Clear biometric loading flag on error as well
                      if (_biometricLoginInProgress) {
                        setState(() {
                          _biometricLoginInProgress = false;
                        });
                      }

                      SnackbarDemo(
                        message: state.message,
                      ).showCustomSnackbar(context);
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
                            height:
                                (MediaQuery.of(context).viewInsets.bottom > 0)
                                ? screenHeight *
                                      0.02 // small gap when keyboard shown
                                : screenHeight *
                                      0.12, // reasonable large gap when idle
                          ),

                          // Email Input
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.deviderColor,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Email',
                                  style: AppTypography.sfProHintTextStyle17,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    style: AppTypography.sfProHintTextStyle17,
                                    autovalidateMode: _showValidationErrors
                                      ? AutovalidateMode.always
                                      : AutovalidateMode.disabled,
                                    decoration: InputDecoration(
                                      hintText: 'your@business.com',
                                      hintStyle:
                                          AppTypography.sfProHintTextStyle17,

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      // suffixIcon: _isEmailValid
                                      //     ? Container(
                                      //         margin: EdgeInsets.only(
                                      //           right: RadiusConstants.md,
                                      //         ),
                                      //         child: Icon(
                                      //           Icons.check_circle,
                                      //           color: AppColors.greenColor,
                                      //           size: 30.w,
                                      //         ),
                                      //       )
                                      //     : null,
                                      // hide default InputDecorator error text because we show a custom widget below
                                      errorStyle: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 0,
                                        height: 0,
                                      ),
                                    ),
                                    // Ensure caret and focus behavior are explicit so cursor is visible
                                    autofocus: true,
                                    showCursor: true,
                                    cursorColor: AppColors.blackColor,
                                    enableInteractiveSelection: true,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    validator: _emailValidator,
                                    onFieldSubmitted: (_) {
                                      // Do not trigger API on keyboard submit. Keep validation silent.
                                      FocusScope.of(context).unfocus();
                                      _validateEmail();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // External error message shown under the email field (outside the input border)
                          if (_emailError != null && _showValidationErrors) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: AlignmentGeometry.center,
                              child: Text(
                                _emailError!,
                                style: AppTypography.sfProHintTextStyle17
                                    .copyWith(color: Colors.red),
                              ),
                            ),
                          ],

                          // Responsive spacing based on keyboard visibility
                          SizedBox(
                            height:
                                (MediaQuery.of(context).viewInsets.bottom > 0)
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
            // Fullscreen loading overlay for biometric login
            if (_biometricLoginInProgress)
              Positioned.fill(
                child: SizedBox(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),

        // Bottom Button
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 8,
          ),
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
                                  // Run validation and show errors only when Confirm is pressed
                                  _validateEmail(showErrors: true);

                                  if (_formKey.currentState!.validate() && _isEmailValid) {
                                    context.read<SignInCubit>().findUserByEmail(
                                      _emailController.text.trim(),
                                    );
                                  }
                                },
                          child: state is SignInLoading
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
                  ),
                    if (_showBiometricOption) ...[
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _authenticateWithBiometric,
                          icon: Icon(
                            // Prefer Face ID icon on iOS when biometric type indicates face
                            (_biometricType.contains('Face') && Platform.isIOS)
                                ? Icons.face_rounded
                                : Icons.fingerprint,
                            size: 28,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                ],
              ),
            ],
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

      debugPrint(
        '📱 isAvailable: $isAvailable, isDeviceSupported: $isDeviceSupported',
      );

      if (!isAvailable || !isDeviceSupported) {
        SnackbarDemo(
          message: 'Biometric not available',
        ).showCustomSnackbar(context);
        return;
      }

      debugPrint(
        '🚀 Calling authenticate - system prompt should appear now...',
      );

      // Call authenticate - THIS should show the system bottom sheet
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to continue',
        // options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      debugPrint('✅ Authentication completed: $didAuthenticate');

      if (didAuthenticate) {
        debugPrint('🎉 Authentication successful!');

        // Get saved credentials
        final credentials =
            await BiometricStorageService.getBiometricCredentials();

        if (credentials['email'] != null && credentials['password'] != null) {
          _emailController.text = credentials['email']!;
          setState(() {
            _isEmailValid = true;
          });

          // Trigger login using stored credentials so the cubit saves token
          // before navigation. Listener handles LoginSuccess -> navigate home.
          if (mounted) {
            setState(() {
              _biometricLoginInProgress = true;
            });

            context.read<SignInCubit>().login(
              credentials['email']!,
              credentials['password']!,
            );
          }
        } else {
          SnackbarDemo(
            message: 'Credentials not found',
          ).showCustomSnackbar(context);
        }
      } else {
        debugPrint('❌ Authentication failed or canceled');
        SnackbarDemo(
          message: 'Authentication canceled',
        ).showCustomSnackbar(context);
      }
    } catch (e) {
      debugPrint('💥 Error: $e');
      SnackbarDemo(message: 'Error: $e').showCustomSnackbar(context);
    }
  }
}
