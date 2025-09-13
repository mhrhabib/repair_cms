import 'package:go_router/go_router.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/auth/widgets/three_dots_pointer_widget.dart';

class PasswordInputScreen extends StatefulWidget {
  const PasswordInputScreen({super.key});

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordValid = false;
  bool _obscureText = true;

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

  void _navigateToNextScreen() {
    if (_formKey.currentState!.validate() && _isPasswordValid) {
      // Navigate to next screen or perform login action
      context.push(RouteNames.home);
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
    // Implement forgot password functionality
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
              width: isLargeScreen ? 400 : screenWidth * 0.9,
              child: Form(
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
                                    if (_isPasswordValid)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: Icon(Icons.help_outline, color: Colors.grey[600], size: 24),
                                      ),
                                  ],
                                ),
                                errorStyle: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              keyboardType: TextInputType.visiblePassword,

                              validator: _passwordValidator,
                              onFieldSubmitted: (_) => _navigateToNextScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Face ID and Forgot Password Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Toggle your state here
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: true
                                  ? AppColors.greenColor
                                  : Colors.transparent, // Replace 'true' with your state variable
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[400]!, width: 1),
                            ),
                            child:
                                true // Replace 'true' with your state variable
                                ? Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Enable Face ID for authentication', style: AppTypography.sfProText15),
                      ],
                    ),

                    SizedBox(height: 20.h),

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

                    // Sign In Button
                    CustomButton(
                      trailingIcon: Icon(Icons.login, size: 24.sp),
                      text: 'Log In',
                      onPressed: _navigateToNextScreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
