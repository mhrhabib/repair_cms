import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  String _selectedRole = '';

  // Track original values to detect changes
  String _originalName = '';
  String _originalEmail = '';
  String _originalPosition = '';
  String _originalRole = '';

  // Focus nodes to detect keyboard visibility
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();

  // Track if controllers are initialized
  bool _controllersInitialized = false;

  // For image picking
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploadingAvatar = false;

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

  void _initializeControllers(UserData user) {
    if (_controllersInitialized) return;

    _nameController.text = user.fullName!;
    _emailController.text = user.email!;
    _positionController.text = user.position!;
    _selectedRole = user.userType!;

    // Set original values
    _originalName = user.fullName!;
    _originalEmail = user.email!;
    _originalPosition = user.position!;
    _originalRole = user.userType!;

    _controllersInitialized = true;
  }

  void _checkForChanges() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  bool get _hasChanges {
    return _nameController.text != _originalName ||
        _emailController.text != _originalEmail ||
        _positionController.text != _originalPosition ||
        _selectedRole != _originalRole ||
        _selectedImage != null;
  }

  void _saveChanges() {
    final profileCubit = context.read<ProfileCubit>();
    final signInCubit = context.read<SignInCubit>();

    final userId = signInCubit.userId;

    // First upload avatar if selected
    if (_selectedImage != null) {
      _uploadAvatar(userId, profileCubit);
    } else {
      // Only update profile data if no new avatar
      _updateProfileData(userId, profileCubit);
    }

    // Unfocus all text fields to hide keyboard
    FocusScope.of(context).unfocus();
  }

  void _updateProfileData(String userId, ProfileCubit profileCubit) {
    final updateData = {
      'fullName': _nameController.text,
      'email': _emailController.text,
      'position': _positionController.text,
      'userType': _selectedRole,
    };

    profileCubit.updateUserProfile(userId, updateData);
  }

  void _uploadAvatar(String userId, ProfileCubit profileCubit) {
    setState(() {
      _isUploadingAvatar = true;
    });

    profileCubit
        .updateUserAvatar(userId, _selectedImage!.path)
        .then((_) {
          setState(() {
            _isUploadingAvatar = false;
          });

          // After avatar upload, update profile data
          _updateProfileData(userId, profileCubit);

          // Clear selected image after upload
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedImage = null;
            });
          });
        })
        .catchError((error) {
          setState(() {
            _isUploadingAvatar = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload avatar: $error'), backgroundColor: Colors.red));
        });
  }

  void _updateProfileField(String field, dynamic value) {
    final profileCubit = context.read<ProfileCubit>();
    final signInCubit = context.read<SignInCubit>();

    final userId = signInCubit.userId.isNotEmpty ? signInCubit.userId : '64106cddcfcedd360d7096cc';

    profileCubit.updateProfileField(userId, field, value);
  }

  // Image Picker Methods
  Future<void> _showImageSourceBottomSheet() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Profile Picture',
                      style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Options
              _buildBottomSheetOption(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select photo from your device',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),

              _buildBottomSheetOption(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Use your camera to take a photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),

              // Remove photo option (only show if user has an existing avatar)
              BlocBuilder<ProfileCubit, ProfileStates>(
                builder: (context, state) {
                  if (state is ProfileLoaded && state.user.avatar != null && state.user.avatar!.isNotEmpty) {
                    return _buildBottomSheetOption(
                      icon: Icons.delete,
                      title: 'Remove Photo',
                      subtitle: 'Remove current profile picture',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfilePicture(state.user.id!);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _removeProfilePicture(String userId) {
    final profileCubit = context.read<ProfileCubit>();

    // You might need to implement a remove avatar endpoint in your repository
    // For now, we'll set a flag to clear the avatar
    profileCubit
        .updateProfileField(userId, 'avatar', '')
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile picture removed'), backgroundColor: Colors.green));
        })
        .catchError((error) {
          _showErrorSnackBar('Failed to remove profile picture: $error');
        });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
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
    return BlocConsumer<ProfileCubit, ProfileStates>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
          );
        }

        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Update original values after successful save
          _originalName = _nameController.text;
          _originalEmail = _emailController.text;
          _originalPosition = _positionController.text;
          _originalRole = _selectedRole;

          if (mounted) {
            setState(() {});
          }
        }
      },
      builder: (context, state) {
        // Load user data when the screen is first built
        if (state is ProfileInitial) {
          final signInCubit = context.read<SignInCubit>();
          final profileCubit = context.read<ProfileCubit>();

          // Try to load from storage first, then from API if needed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            profileCubit.loadUserFromStorage().then((_) {
              // If no user in storage, fetch from API
              final userId = signInCubit.userId.isNotEmpty ? signInCubit.userId : '64106cddcfcedd360d7096cc';
              profileCubit.getUserProfile(userId);
            });
          });
        }

        // Initialize controllers when user data is loaded
        if (state is ProfileLoaded) {
          debugPrint('User data loaded: ${state.user.toJson()}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeControllers(state.user);
          });
        }

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
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
            ),
            title: const Text(
              'Personal Details',
              style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: _buildBottomButton(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProfileStates state) {
    if (state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final signInCubit = context.read<SignInCubit>();
                final userId = signInCubit.userId.isNotEmpty ? signInCubit.userId : '64106cddcfcedd360d7096cc';
                context.read<ProfileCubit>().getUserProfile(userId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final user = state is ProfileLoaded ? state.user : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
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
                    child: Stack(
                      children: [
                        // Profile Image
                        CircleAvatar(radius: 80, backgroundImage: _getProfileImage(user?.avatar)),

                        // Uploading overlay
                        if (_isUploadingAvatar)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Camera Button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceBottomSheet,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),

                  // Selected Image Indicator
                  if (_selectedImage != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),

              // Selected Image Preview Text
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                Text(
                  'New photo selected',
                  style: GoogleFonts.roboto(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role',
                    style: GoogleFonts.roboto(color: Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: user!.userType!,

                    enabled: false,
                    decoration: InputDecoration(
                      filled: true,

                      fillColor: Colors.grey.shade50,
                      suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
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
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getProfileImage(String? avatarUrl) {
    // Show selected image first
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    }

    // Fallback to user's avatar or default
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const NetworkImage(
        'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      );
    }

    // Check if the avatar URL is a complete URL or just a path
    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    } else {
      // If it's just a path, construct the full URL
      final fullUrl = 'https://my.repaircms.com/$avatarUrl';
      return NetworkImage(fullUrl);
    }
  }

  Widget _buildBottomButton(BuildContext context, ProfileStates state) {
    if ((state is ProfileLoading && !_isUploadingAvatar) || !_hasChanges) {
      return const SizedBox.shrink();
    }

    return SafeArea(
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
            text: _isUploadingAvatar ? 'Uploading...' : 'Save',
            onPressed: (state is ProfileLoading || _isUploadingAvatar) ? null : _saveChanges,
            isLoading: state is ProfileLoading || _isUploadingAvatar,
          ),
        ),
      ),
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
          enabled: true,
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
}
