// screens/password_forgotten_screen.dart

import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/auth/widgets/three_dots_pointer_widget.dart';
import 'cubit/forgot_password_cubit.dart';

class PasswordForgottenScreen extends StatefulWidget {
  const PasswordForgottenScreen({super.key, required this.email});
  final String email;

  @override
  State<PasswordForgottenScreen> createState() =>
      PasswordForgottenScreenState();
}

class PasswordForgottenScreenState extends State<PasswordForgottenScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _emailController.addListener(_validateEmail);
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _validateEmail(); // Validate initial email
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email) && email.isNotEmpty;
    });
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate() && _isEmailValid) {
      final cubit = context.read<ForgotPasswordCubit>();
      cubit.sendResetEmail(_emailController.text.trim());
    }
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
    final isLargeScreen = screenWidth > 600;

    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordEmailSent) {
          showCustomToast(state.message, isError: false);
          // Navigate to verify code screen
          context.push(
            RouteNames.verifyCode,
            extra: _emailController.text.trim(),
          );
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
                          'Password Forgotten',
                          style: AppTypography.sfProHeadLineTextStyle28,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 80.h),

                      // Email Label
                      const SizedBox(height: 8),

                      // Email Input Field
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.deviderColor),
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
                                decoration: InputDecoration(
                                  hintText: 'your@business.com',
                                  hintStyle: AppTypography.sfProHintTextStyle17,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  suffixIcon: _isEmailValid
                                      ? Container(
                                          margin: EdgeInsets.only(
                                            right: RadiusConstants.md,
                                          ),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppColors.greenColor,
                                            size: 30.w,
                                          ),
                                        )
                                      : null,
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                validator: _emailValidator,
                                onFieldSubmitted: (_) => _handleSendOtp(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 120.h),

                      // Progress Indicator
                      ThreeDotsPointerWidget(
                        primaryColor: AppColors.primary,
                        secondaryColor: AppColors.secondary,
                        activeIndex: 1,
                      ),

                      const SizedBox(height: 32),

                      // Request New Password Button
                      BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                        builder: (context, state) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: CustomButton(
                              text: 'Request New Password',
                              onPressed: state is ForgotPasswordLoading
                                  ? null
                                  : _handleSendOtp,
                              child: state is ForgotPasswordLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.whiteColor,
                                            ),
                                      ),
                                    )
                                  : null,
                            ),
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
