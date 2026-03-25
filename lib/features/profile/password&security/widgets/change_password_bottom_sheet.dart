import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static void show(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<ProfileCubit>(context),
        child: const ChangePasswordBottomSheet(),
      ),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _currentPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_checkForChanges);
    _newPasswordController.addListener(_checkForChanges);
    _confirmPasswordController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {});
  }

  bool get _isPasswordValid {
    if (_newPasswordController.text.isEmpty) {
      return true;
    }
    return _newPasswordController.text.length >= 8;
  }

  bool get _doPasswordsMatch {
    if (_newPasswordController.text.isEmpty &&
        _confirmPasswordController.text.isEmpty) {
      return true;
    }
    return _newPasswordController.text == _confirmPasswordController.text;
  }

  bool get _canSave {
    return _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _isPasswordValid &&
        _doPasswordsMatch;
  }

  void _changePassword() async {
    if (!_canSave || _isLoading) return;

    if (!mounted) {
      debugPrint(
        '⚠️ [ChangePasswordBottomSheet] Widget not mounted, aborting password change',
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final profileCubit = context.read<ProfileCubit>();
      final signInCubit = context.read<SignInCubit>();
      final userId = signInCubit.userId == ''
          ? storage.read('userId')
          : signInCubit.userId;

      debugPrint(
        '🔄 [ChangePasswordBottomSheet] Changing password for user: $userId',
      );
      await profileCubit.changePassword(
        userId,
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      // Success is handled in the BlocListener in parent screen
      if (mounted) {
        debugPrint(
          '✅ [ChangePasswordBottomSheet] Password change initiated successfully',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error is handled in the BlocListener in parent screen
      debugPrint('❌ [ChangePasswordBottomSheet] Error changing password: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.kBg,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    CustomNavButton(
                      icon: Icons.close,
                      iconColor: AppColors.fontSecondaryColor,
                      size: 24.sp,
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Change Password',
                      style: GoogleFonts.roboto(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.fontMainColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Password Field
                      _buildPasswordField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        focusNode: _currentPasswordFocusNode,
                        obscureText: _obscureCurrentPassword,
                        onToggleVisibility: () {
                          if (!mounted) return;
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),

                      SizedBox(height: 20.h),

                      // New Password Field
                      _buildPasswordField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        focusNode: _newPasswordFocusNode,
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          if (!mounted) return;
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      if (_newPasswordController.text.isNotEmpty &&
                          !_isPasswordValid) ...[
                        SizedBox(height: 8.h),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            children: [
                              Icon(
                                SolarIconsBold.infoCircle,
                                color: Colors.red,
                                size: 16.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Password must be at least 8 characters',
                                style: GoogleFonts.roboto(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 20.h),

                      // Confirm Password Field
                      _buildPasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          if (!mounted) return;
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      if (_confirmPasswordController.text.isNotEmpty &&
                          !_doPasswordsMatch) ...[
                        SizedBox(height: 8.h),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            children: [
                              Icon(
                                SolarIconsBold.infoCircle,
                                color: Colors.red,
                                size: 16.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Passwords do not match',
                                style: GoogleFonts.roboto(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Password Requirements
                      _buildPasswordRequirements(),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // Action Buttons Footer
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _clearFields,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: _canSave && !_isLoading
                              ? _changePassword
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSave && !_isLoading
                                ? AppColors.primary
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Change Password',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.fontMainColor,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "Enter your ${label.toLowerCase()}",
            hintStyle: GoogleFonts.roboto(
              color: Colors.grey.shade400,
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? SolarIconsOutline.eyeClosed
                    : SolarIconsOutline.eye,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          style: GoogleFonts.roboto(
            fontSize: 16.sp,
            color: AppColors.fontMainColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: GoogleFonts.roboto(
              color: AppColors.primary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          _buildRequirementItem(
            'At least 8 characters long',
            _newPasswordController.text.length >= 8,
          ),
          _buildRequirementItem('Passwords match', _doPasswordsMatch),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: GoogleFonts.roboto(
              color: isMet ? Colors.green : Colors.grey.shade600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
