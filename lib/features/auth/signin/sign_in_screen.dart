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
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: isLargeScreen ? 400 : screenWidth * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Sign Into your Account',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.08),

                  // Email Label
                  const SizedBox(height: 8),

                  // Email Input Field
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.diviverColor)),
                    ),
                    child: Row(
                      children: [
                        Text('Email', style: AppTypography.sfProHintTextStyle17),
                        Expanded(
                          child: TextField(
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
                                      child: Icon(Icons.check_circle, color: Color(0xFF48BB78), size: 30.w),
                                    )
                                  : null,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (_isEmailValid) {}
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.12),

                  // Progress Indicator
                  ThreeDotsPointerWidget(
                    primaryColor: AppColors.primary,
                    secondaryColor: AppColors.secondary,
                    activeIndex: 1,
                  ),

                  const SizedBox(height: 32),

                  // Confirm Email Button
                  CustomButton(text: 'Confirm Email', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
