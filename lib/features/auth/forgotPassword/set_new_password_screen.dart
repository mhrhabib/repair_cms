import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/auth/forgotPassword/cubit/forgot_password_cubit.dart';
import 'package:repair_cms/features/home/home_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<SetNewPasswordScreen> createState() => SetNewPasswordScreenState();
}

class SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
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

  void _resetPassword() {
    if (_formKey.currentState!.validate() && _isPasswordValid) {
      final cubit = context.read<ForgotPasswordCubit>();
      cubit.resetPassword(widget.email, _passwordController.text);
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

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
        if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        } else if (state is ForgotPasswordInitial && _passwordController.text.isNotEmpty) {
          // Password reset successful, navigate back to login
          context.pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Password reset successfully!'), backgroundColor: Colors.green));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(iconTheme: IconThemeData(color: AppColors.primary, weight: 800, fill: 0.4)),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.9,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          style: AppTypography.sfProText15.copyWith(color: AppColors.fontMainColor),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                      Container(
                        height: 1,

                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.diviverColor)),
                        ),
                      ),

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
                                  hintText: 'Min. 8 Characters',
                                  hintStyle: AppTypography.sfProHintTextStyle17.copyWith(color: AppColors.diviverColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                  errorStyle: TextStyle(color: Colors.red, fontSize: 14),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                validator: _passwordValidator,
                                onFieldSubmitted: (_) => _resetPassword(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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

                      SizedBox(height: 32.h),

                      SizedBox(height: 32.h),

                      CustomButton(text: 'Set new password', onPressed: _resetPassword),
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
