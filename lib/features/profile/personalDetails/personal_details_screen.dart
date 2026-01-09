import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/error_screen.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';
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
  String selectedRole = '';

  // Track original values to detect changes
  String _originalName = '';
  String originalEmail = '';
  String _originalPosition = '';
  String originalRole = '';

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

  // Store the actual avatar URL after fetching from API
  String? _avatarUrl;
  bool _isLoadingAvatarUrl = false;

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

    _nameController.text = user.fullName ?? '';
    _emailController.text = user.email ?? '';
    _positionController.text = user.position ?? '';
    selectedRole = user.userType ?? '';

    // Set original values
    _originalName = user.fullName ?? '';
    originalEmail = user.email ?? '';
    _originalPosition = user.position ?? '';
    originalRole = user.userType ?? '';

    _controllersInitialized = true;

    // Fetch the actual avatar URL if user has an avatar path
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      debugPrint('🔍 Fetching avatar URL for path: ${user.avatar}');
      _fetchAvatarUrl(user.avatar!);
    }
  }

  Future<void> _fetchAvatarUrl(String avatarPath) async {
    // Skip if it's already a full S3 signed URL (from recent upload)
    if (avatarPath.startsWith('http')) {
      setState(() {
        _avatarUrl = avatarPath;
      });
      return;
    }

    if (_avatarUrl != null) return; // Already fetched

    if (!mounted) return;

    try {
      setState(() {
        _isLoadingAvatarUrl = true;
      });
    } catch (e) {
      debugPrint('❌ [PersonalDetailsScreen] Error setting loading state: $e');
      return;
    }

    try {
      final profileCubit = context.read<ProfileCubit>();
      final imageUrl = await profileCubit.getImageUrl(avatarPath);

      if (mounted) {
        setState(() {
          _avatarUrl = imageUrl;
          _isLoadingAvatarUrl = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [PersonalDetailsScreen] Failed to fetch avatar URL: $e');
      if (mounted) {
        setState(() {
          _isLoadingAvatarUrl = false;
        });
      }
    }
  }

  void _checkForChanges() {
    if (mounted) {
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      } catch (e) {
        debugPrint('❌ [PersonalDetailsScreen] Error in _checkForChanges: $e');
      }
    }
  }

  // Separate change detection for profile data and avatar
  bool get _hasProfileDataChanges {
    return _nameController.text != _originalName ||
        _positionController.text != _originalPosition;
  }

  bool get _hasAvatarChanges {
    return _selectedImage != null;
  }

  bool get hasChanges {
    return _hasProfileDataChanges || _hasAvatarChanges;
  }

  void _saveChanges() {
    final profileCubit = context.read<ProfileCubit>();
    final signInCubit = context.read<SignInCubit>();

    final userId = signInCubit.userId == ''
        ? storage.read('userId')
        : signInCubit.userId;

    if (userId == null || userId.isEmpty) {
      _showErrorSnackBar('User ID not found');
      return;
    }

    // Handle avatar upload and profile data update separately
    if (_hasAvatarChanges && _hasProfileDataChanges) {
      // Both avatar and profile data changed - upload avatar first, then update profile
      _uploadAvatar(userId, profileCubit).then((_) {
        _updateProfileData(userId, profileCubit);
      });
    } else if (_hasAvatarChanges) {
      // Only avatar changed - upload avatar only
      _uploadAvatar(userId, profileCubit);
    } else if (_hasProfileDataChanges) {
      // Only profile data changed - update profile only
      _updateProfileData(userId, profileCubit);
    } else {
      // No changes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Unfocus all text fields to hide keyboard
    FocusScope.of(context).unfocus();
  }

  Future<void> _uploadAvatar(String userId, ProfileCubit profileCubit) async {
    if (!mounted) return;

    try {
      setState(() {
        _isUploadingAvatar = true;
      });
    } catch (e) {
      debugPrint('❌ [PersonalDetailsScreen] Error setting upload state: $e');
      return;
    }

    try {
      // Validate image before upload
      final isValid = await profileCubit.validateImage(_selectedImage!.path);
      if (!isValid) {
        if (mounted) {
          setState(() {
            _isUploadingAvatar = false;
          });
        }
        _showErrorSnackBar('Invalid image file');
        return;
      }

      debugPrint('🚀 [PersonalDetailsScreen] Uploading avatar');
      // Upload avatar only using the separate method
      final newImageUrl = await profileCubit.updateUserAvatar(
        userId,
        _selectedImage!.path,
      );

      // Clear selected image after successful upload and set the new avatar URL
      if (mounted) {
        setState(() {
          _selectedImage = null;
          // Set the fresh avatar URL from upload response
          _avatarUrl = newImageUrl;
          _isUploadingAvatar = false; // Reset upload state
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar uploaded successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      debugPrint('❌ [PersonalDetailsScreen] Error uploading avatar: $error');
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
      _showErrorSnackBar('Failed to upload avatar: $error');
    }
  }

  void _updateProfileData(String userId, ProfileCubit profileCubit) {
    final updateData = <String, dynamic>{};

    // Only include fields that have changed
    if (_nameController.text != _originalName) {
      updateData['fullName'] = _nameController.text;
    }

    if (_positionController.text != _originalPosition) {
      updateData['position'] = _positionController.text;
    }

    // Only call update if there are actual changes
    if (updateData.isNotEmpty) {
      profileCubit.updateUserProfile(userId, updateData);
    }
  }

  // IMAGE PICKER METHODS - Upload immediately when image is picked
  Future<void> _showImageSourceBottomSheet() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
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
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Profile Picture',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
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

              // Remove photo option
              BlocBuilder<ProfileCubit, ProfileStates>(
                builder: (context, state) {
                  if (state is ProfileLoaded &&
                      state.user.avatar != null &&
                      state.user.avatar!.isNotEmpty) {
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

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        // Upload immediately when image is picked
        _uploadImageImmediately(image);
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
        // Upload immediately when image is picked
        _uploadImageImmediately(image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _uploadImageImmediately(XFile image) {
    if (!mounted) {
      debugPrint(
        '⚠️ [PersonalDetailsScreen] Widget not mounted, aborting upload',
      );
      return;
    }

    final profileCubit = context.read<ProfileCubit>();
    final signInCubit = context.read<SignInCubit>();

    final userId = signInCubit.userId == ''
        ? storage.read('userId')
        : signInCubit.userId;

    if (userId == null || userId.isEmpty) {
      _showErrorSnackBar('User ID not found');
      return;
    }

    try {
      setState(() {
        _selectedImage = image;
        _isUploadingAvatar = true;
      });
    } catch (e) {
      debugPrint('❌ [PersonalDetailsScreen] Error setting upload state: $e');
      return;
    }

    debugPrint('🚀 [PersonalDetailsScreen] Starting immediate upload');
    // Upload avatar immediately
    profileCubit
        .updateUserAvatar(userId, image.path)
        .then((imageUrl) {
          if (!mounted) return;
          try {
            // Use the returned imageUrl to immediately update the UI
            setState(() {
              _isUploadingAvatar = false;
              _selectedImage = null;
              _avatarUrl = imageUrl; // Set the avatar URL immediately
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            debugPrint(
              '❌ [PersonalDetailsScreen] Error updating UI after upload: $e',
            );
          }
        })
        .catchError((error) {
          debugPrint('❌ [PersonalDetailsScreen] Upload failed: $error');
          if (!mounted) return;
          try {
            setState(() {
              _isUploadingAvatar = false;
              _selectedImage = null;
            });
          } catch (e) {
            debugPrint(
              '❌ [PersonalDetailsScreen] Error updating UI after error: $e',
            );
          }
          _showErrorSnackBar('Failed to upload avatar: $error');
        });
  }

  void _removeProfilePicture(String userId) {
    if (!mounted) {
      debugPrint(
        '⚠️ [PersonalDetailsScreen] Widget not mounted, aborting remove',
      );
      return;
    }

    final profileCubit = context.read<ProfileCubit>();

    debugPrint('🗑️ [PersonalDetailsScreen] Removing profile picture');
    // Set avatar to empty string to remove it
    profileCubit
        .updateProfileField(userId, 'avatar', '')
        .then((_) {
          if (!mounted) return;
          try {
            // Clear cached avatar URL immediately
            setState(() {
              _avatarUrl = null;
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture removed'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            debugPrint(
              '❌ [PersonalDetailsScreen] Error updating UI after remove: $e',
            );
          }
        })
        .catchError((error) {
          debugPrint(
            '❌ [PersonalDetailsScreen] Failed to remove picture: $error',
          );
          _showErrorSnackBar('Failed to remove profile picture: $error');
        });
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
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (state is ProfileUpdated) {
          if (!_isUploadingAvatar) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Update original values after successful save
          _originalName = _nameController.text;
          _originalPosition = _positionController.text;

          if (mounted) {
            setState(() {});
          }
        }
      },
      builder: (context, state) {
        // Load user data when the screen is first built
        if (state is ProfileInitial) {
          final profileCubit = context.read<ProfileCubit>();

          // Try to load from storage first, then from API if needed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            profileCubit.loadUserFromStorage().then((_) {
              // If no user in storage, fetch from API
              profileCubit.getUserProfile();
            });
          });
        }

        // Initialize controllers when user data is loaded
        if (state is ProfileLoaded) {
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
                if (!mounted) return;
                try {
                  debugPrint('🔄 [PersonalDetailsScreen] Navigating back');
                  Navigator.pop(context);
                } catch (e) {
                  debugPrint(
                    '❌ [PersonalDetailsScreen] Error navigating back: $e',
                  );
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
                size: 20,
              ),
            ),
            title: const Text(
              'Personal Details',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileError) {
      return Error404Screen(
        errorMessage: state.message,
        onRetry: () {
          context.read<ProfileCubit>().getUserProfile();
        },
        buttonText: 'Reload Profile',
      );
    }

    // Only proceed if we have ProfileLoaded state
    if (state is ProfileLoaded) {
      final user = state.user;

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
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
                          // Profile Image with loading state
                          if (_isLoadingAvatarUrl &&
                              user.avatar != null &&
                              user.avatar!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 80,
                              backgroundImage: _getProfileImage(user.avatar),
                              backgroundColor: Colors.transparent,
                            ),

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
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
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
                        onTap: (_isUploadingAvatar || _isLoadingAvatarUrl)
                            ? null
                            : _showImageSourceBottomSheet,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (_isUploadingAvatar || _isLoadingAvatarUrl)
                                ? Colors.grey
                                : Colors.blue,
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
                          child: Icon(
                            _isUploadingAvatar
                                ? Icons.hourglass_empty
                                : Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Loading Avatar URL Text
                if (_isLoadingAvatarUrl &&
                    user.avatar != null &&
                    user.avatar!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Loading avatar...',
                    style: GoogleFonts.roboto(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                // Uploading Text
                if (_isUploadingAvatar) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Uploading avatar...',
                    style: GoogleFonts.roboto(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Rest of your form fields...
                _buildInputField(
                  label: 'Full Name',
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                ),
                SizedBox(height: 12.h),
                _buildReadOnlyField(label: 'Email', value: user.email ?? ''),
                SizedBox(height: 12.h),
                _buildInputField(
                  label: 'Position',
                  controller: _positionController,
                  focusNode: _positionFocusNode,
                ),
                const SizedBox(height: 20),
                _buildRoleField(value: user.userType ?? ''),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  // Rest of your UI methods remain the same...
  ImageProvider _getProfileImage(String? avatarPath) {
    // Only use _avatarUrl (the signed URL), not the S3 path directly
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return NetworkImage(_avatarUrl!);
    }

    // Show loading indicator while fetching signed URL
    if (_isLoadingAvatarUrl) {
      // Return a placeholder while loading
      return const NetworkImage(
        'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      );
    }

    // Fallback: Default image
    return const NetworkImage(
      'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    );
  }

  Widget _buildBottomButton(BuildContext context, ProfileStates state) {
    // Only show save button for profile data changes, not for avatar changes
    if ((state is ProfileLoading && !_isUploadingAvatar) ||
        !_hasProfileDataChanges) {
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
            text: 'Save Profile Data',
            onPressed:
                (state is ProfileLoading ||
                    _isUploadingAvatar ||
                    _isLoadingAvatarUrl)
                ? null
                : _saveChanges,
            isLoading: state is ProfileLoading,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTypography.fontSize16Normal,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
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
          initialValue: value,
          enabled: false,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTypography.fontSize16Normal,
        ),
      ],
    );
  }

  Widget _buildRoleField({required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: GoogleFonts.roboto(
            color: Colors.black54,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.blue,
            ),
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
          ),
          style: AppTypography.fontSize16Normal,
        ),
      ],
    );
  }
}
