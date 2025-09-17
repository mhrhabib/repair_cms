import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:solar_icons/solar_icons.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChangePasswordBottomSheet(),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() => _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Track original values to detect changes
  final String _originalOldPassword = '';
  final String _originalNewPassword = '';

  // Focus nodes
  final FocusNode _oldPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();

  // Password visibility toggles
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    // Add listeners to text fields to detect changes
    _oldPasswordController.addListener(_checkForChanges);
    _newPasswordController.addListener(_checkForChanges);

    // Add listeners to focus nodes
    _oldPasswordFocusNode.addListener(_checkForChanges);
    _newPasswordFocusNode.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {}); // Trigger rebuild to update button visibility
  }

  bool get _hasChanges {
    return _oldPasswordController.text != _originalOldPassword || _newPasswordController.text != _originalNewPassword;
  }

  bool get _isPasswordValid {
    if (_newPasswordController.text.isEmpty) return true;
    return _newPasswordController.text.length >= 8;
  }

  bool get _canSave {
    return _hasChanges &&
        _oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _isPasswordValid;
  }

  void _saveChanges() {
    if (!_canSave) return;

    // Implement save logic here
    print('Saving password changes...');
    print('Old Password: ${_oldPasswordController.text}');
    print('New Password: ${_newPasswordController.text}');

    // Show success message
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password changed successfully'), duration: Duration(seconds: 2)));

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _oldPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        height: MediaQuery.of(context).size.height * .96,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, color: Colors.black54, size: 20),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Change Password',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 32), // Balance the close button
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h),

                      // Old Password Field
                      _buildPasswordField(
                        label: 'Old Password',
                        controller: _oldPasswordController,
                        focusNode: _oldPasswordFocusNode,
                        obscureText: _obscureOldPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureOldPassword = !_obscureOldPassword;
                          });
                        },
                      ),

                      SizedBox(height: 24.h),

                      // New Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocusNode,
                            obscureText: _obscureNewPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          if (_newPasswordController.text.isNotEmpty && !_isPasswordValid) ...[
                            SizedBox(height: 8.h),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                children: [
                                  Icon(SolarIconsBold.infoCircle, color: Colors.red, size: 16.w),
                                  const SizedBox(width: 4),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Save Button
          bottomNavigationBar: Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16.w,
                right: 16.w,
                top: 16,
              ),
              child: CustomButton(text: 'Save', onPressed: _canSave ? _saveChanges : null),
            ),
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
          style: GoogleFonts.roboto(color: Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: "*******************",
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? SolarIconsOutline.eyeClosed : SolarIconsOutline.eye,
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
}
