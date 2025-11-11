import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/password&security/widgets/change_password_bottom_sheet.dart';
import 'package:solar_icons/solar_icons.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final bool _isTwoFactorEnabled = true;
  bool _isTrustedEmailEnabled = true;

  // Track original values to detect changes
  final String _originalCurrentPassword = '';
  final String _originalNewPassword = '';
  final String _originalConfirmPassword = '';
  final bool _originalTwoFactorEnabled = true;
  final bool _originalTrustedEmailEnabled = true;

  // Focus nodes to detect keyboard visibility
  final FocusNode _currentPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Password visibility toggles
  bool _obscureCurrentPassword = true;

  @override
  void initState() {
    super.initState();
    // Add listeners to text fields to detect changes
    _currentPasswordController.addListener(_checkForChanges);
    _newPasswordController.addListener(_checkForChanges);
    _confirmPasswordController.addListener(_checkForChanges);

    // Add listeners to focus nodes
    _currentPasswordFocusNode.addListener(_checkForChanges);
    _newPasswordFocusNode.addListener(_checkForChanges);
    _confirmPasswordFocusNode.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {}); // Trigger rebuild to update button visibility
  }

  bool get _hasChanges {
    return _currentPasswordController.text != _originalCurrentPassword ||
        _newPasswordController.text != _originalNewPassword ||
        _confirmPasswordController.text != _originalConfirmPassword ||
        _isTwoFactorEnabled != _originalTwoFactorEnabled ||
        _isTrustedEmailEnabled != _originalTrustedEmailEnabled;
  }

  bool get _isPasswordValid {
    if (_newPasswordController.text.isEmpty) {
      return true; // Don't validate empty password
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
    if (!_hasChanges) return false;

    // If changing password, validate requirements
    if (_newPasswordController.text.isNotEmpty) {
      return _currentPasswordController.text.isNotEmpty &&
          _isPasswordValid &&
          _doPasswordsMatch;
    }

    return true; // For toggle changes only
  }

  void _saveChanges() {
    if (!_canSave) return;

    // Implement save logic here
    debugPrint('Saving security changes...');
    debugPrint('Current Password: ${_currentPasswordController.text}');
    debugPrint('New Password: ${_newPasswordController.text}');
    debugPrint('Two-Factor Auth: $_isTwoFactorEnabled');
    debugPrint('Trusted Email: $_isTrustedEmailEnabled');

    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Security settings saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    // Clear password fields after saving
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    // Unfocus all text fields to hide keyboard
    FocusScope.of(context).unfocus();
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
    return BlocConsumer<ProfileCubit, ProfileStates>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (state is PasswordChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackgroundColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
                size: 20,
              ),
            ),
            title: const Text(
              'Password & Security',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              height: 500.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Password Section Header
                    const SizedBox(height: 16),

                    // Current Password Field
                    _buildPasswordField(
                      label: 'Password',
                      controller: _currentPasswordController,
                      focusNode: _currentPasswordFocusNode,
                      obscureText: _obscureCurrentPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Security Settings Section Header
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => ChangePasswordBottomSheet.show(context),
                        child: Text(
                          'Change Password',
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Two-Factor Authentication Toggle
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Two-factor authentication (2FA)',
                        style: GoogleFonts.roboto(
                          color: AppColors.fontMainColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Trusted Email Toggle
                    _buildToggleField(
                      label: 'Trusted E-Mail',
                      value: _isTrustedEmailEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isTrustedEmailEnabled = value;
                        });
                      },
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Save Button (same pattern as Personal Details)
          bottomNavigationBar: _hasChanges
              ? SafeArea(
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 2,
                        left: 12.w,
                        right: 12.w,
                        top: 2,
                      ),
                      child: CustomButton(
                        text: 'Save',
                        onPressed: _canSave ? _saveChanges : null,
                        isLoading: state is ProfileLoading,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
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
            color: Colors.black54,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: "*********************",
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
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
          style: AppTypography.fontSize16Normal,
        ),
      ],
    );
  }

  Widget _buildToggleField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            color: AppColors.fontMainColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
