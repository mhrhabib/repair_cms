import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';
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
                      showCustomToast(state.message, isError: false);
                      _navigateToPasswordScreen(state.email);
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
                          const SizedBox(height: 30),
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

                          SizedBox(height: screenHeight * 0.18),

                          // Progress Indicator
                          ThreeDotsPointerWidget(
                            primaryColor: AppColors.primary,
                            secondaryColor: AppColors.secondary,
                            activeIndex: 1,
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

        // Bottom Button
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 8),
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
      ),
    );
  }
}
