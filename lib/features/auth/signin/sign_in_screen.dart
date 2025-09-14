import 'package:go_router/go_router.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/auth/widgets/three_dots_pointer_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_validateEmail);

    // Open keyboard automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });

    _emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email) && email.isNotEmpty;
    });
  }

  void _navigateToNextScreen() {
    if (_formKey.currentState!.validate() && _isEmailValid) {
      context.push(RouteNames.passwordInput);
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true, // important!
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20), // give space for button
            child: SizedBox(
              width: isLargeScreen ? 600 : screenWidth * 0.9,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    SizedBox(height: 30),
                    Center(
                      child: Text(
                        'Sign Into your Account',
                        style: AppTypography.sfProHeadLineTextStyle28,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.08),

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
                                errorStyle: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: _emailValidator,
                              onFieldSubmitted: (_) => _navigateToNextScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.18),

                    // Progress Indicator
                    ThreeDotsPointerWidget(
                      primaryColor: AppColors.primary,
                      secondaryColor: AppColors.secondary,
                      activeIndex: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // 👇 Stick the button to bottom and move it with keyboard
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16, // moves with keyboard
          left: 16,
          right: 16,
          top: 8,
        ),
        child: CustomButton(text: 'Confirm Email', onPressed: _navigateToNextScreen),
      ),
    );
  }
}
