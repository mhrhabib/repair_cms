import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:solar_icons/solar_icons.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Martin Koloniavski');
  final TextEditingController _emailController = TextEditingController(text: 'martin.kolonialovski@gmail.');
  final TextEditingController _positionController = TextEditingController(text: 'Technician');
  String _selectedRole = 'Owner';

  // Track original values to detect changes
  final String _originalName = 'Martin Koloniavski';
  final String _originalEmail = 'martin.kolonialovski@gmail.';
  final String _originalPosition = 'Technician';
  final String _originalRole = 'Owner';

  // Focus nodes to detect keyboard visibility
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add listeners to text fields to detect changes
    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _positionController.addListener(_checkForChanges);

    // Add listeners to focus nodes
    _nameFocusNode.addListener(_checkForChanges);
    _emailFocusNode.addListener(_checkForChanges);
    _positionFocusNode.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {}); // Trigger rebuild to update button visibility
  }

  bool get _hasChanges {
    return _nameController.text != _originalName ||
        _emailController.text != _originalEmail ||
        _positionController.text != _originalPosition ||
        _selectedRole != _originalRole;
  }

  void _saveChanges() {
    // Implement save logic here
    debugPrint('Saving changes...');
    // After saving, you might want to update the original values
    // _originalName = _nameController.text;
    // etc.

    // For now, just show a snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changes saved successfully'), duration: Duration(seconds: 2)));

    // Unfocus all text fields to hide keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _positionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true, // Important for keyboard handling
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20), // Give space for button
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture Section
                Stack(
                  children: [
                    Container(
                      width: 131.w,
                      height: 131.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.teal.shade300, Colors.teal.shade600],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Full Name Field
                _buildInputField(label: 'Full Name', controller: _nameController, focusNode: _nameFocusNode),

                SizedBox(height: 12.h),

                // Email Field with confirmation text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(label: 'Email', controller: _emailController, focusNode: _emailFocusNode),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(SolarIconsBold.infoCircle, color: AppColors.warningColor, size: 20.w),
                          const SizedBox(width: 4),
                          Text(
                            'confirm my email address',
                            style: GoogleFonts.roboto(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Position Field
                _buildInputField(label: 'Position', controller: _positionController, focusNode: _positionFocusNode),

                const SizedBox(height: 20),

                // Role Dropdown
                _buildDropdownField(
                  label: 'Role',
                  value: _selectedRole,
                  items: ['Owner', 'Manager', 'Technician', 'Assistant'],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),

      // 👇 Stick the button to bottom and move it with keyboard (like the sign-in screen)
      bottomNavigationBar: _hasChanges
          ? SafeArea(
              child: Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 2, // Moves with keyboard
                    left: 12.w,
                    right: 12.w,
                    top: 2,
                  ),
                  child: CustomButton(text: 'Save', onPressed: _saveChanges),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(color: Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: AppTypography.fontSize16Normal,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue, size: 24),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
