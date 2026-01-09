import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';
import 'package:repair_cms/features/profile/repository/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(ProfileInitial());

  Future<void> getUserProfile() async {
    debugPrint('🔄 ProfileCubit: Getting user profile...');
    emit(ProfileLoading());
    try {
      final ProfileResponseModel user = await repository.getProfile();
      debugPrint('✅ ProfileCubit: User data loaded successfully');
      debugPrint('👤 User Name: ${user.data?.fullName}');
      debugPrint('📧 User Email: ${user.data?.email}');
      emit(ProfileLoaded(user: user.data!));
    } on ProfileException catch (e) {
      debugPrint('❌ ProfileCubit ProfileException: ${e.message}');
      emit(ProfileError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 ProfileCubit Error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> loadUserFromStorage() async {
    emit(ProfileLoading());
    try {
      final userData = await storage.read('user');
      if (userData != null) {
        final UserData user = UserData.fromJson(userData);
        emit(ProfileLoaded(user: user));
      } else {
        emit(ProfileError(message: 'No user data found in storage'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    emit(ProfileLoading());
    try {
      final UserData updatedUser = await repository.updateUserProfile(
        userId,
        updateData,
      );

      // Update storage with new user data
      await storage.write('user', updatedUser.toJson());

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser));
    } on ProfileException catch (e) {
      debugPrint('❌ ProfileCubit ProfileException: ${e.message}');
      emit(ProfileError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 ProfileCubit Error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateProfileField(
    String userId,
    String field,
    dynamic value,
  ) async {
    emit(ProfileLoading());
    try {
      final UserData updatedUser = await repository.updateUserProfile(userId, {
        field: value,
      });

      // Update storage with new user data
      await storage.write('user', updatedUser.toJson());

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser));
    } on ProfileException catch (e) {
      debugPrint('❌ ProfileCubit ProfileException: ${e.message}');
      emit(ProfileError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 ProfileCubit Error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ProfileError(message: e.toString()));
    }
  }

  String uploadedImageUrl(String imagePath) {
    return imagePath;
  }

  Future<String> updateUserAvatar(String userId, String avatarPath) async {
    emit(ProfileLoading());
    try {
      debugPrint('🔄 ProfileCubit: Updating user avatar...');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   📁 Avatar path: $avatarPath');

      // Step 1: Upload avatar and get response with file path and URL
      final uploadResponse = await repository.updateUserAvatar(
        userId,
        avatarPath,
      );
      debugPrint('   ✅ Avatar uploaded, response: $uploadResponse');

      // Extract file path and URL from response
      final s3FilePath = uploadResponse['file'] as String;
      final signedUrl = uploadResponse['url'] as String;
      debugPrint('   📁 S3 File Path: $s3FilePath');
      debugPrint('   🌐 Signed URL: $signedUrl');

      // Step 2: Update user profile with the S3 file path (not the signed URL which expires)
      final UserData updatedUser = await repository.updateUserProfile(userId, {
        'avatar': s3FilePath,
      });

      // Update storage with new user data
      await storage.write('user', updatedUser.toJson());

      // Emit ProfileUpdated first to trigger UI refresh
      emit(ProfileUpdated(user: updatedUser));

      // Then emit ProfileLoaded with the updated user data
      emit(ProfileLoaded(user: updatedUser));

      debugPrint('✅ ProfileCubit: Avatar update completed successfully');

      return signedUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ ProfileCubit Error in updateUserAvatar: $e');
      debugPrint('📜 Stack Trace: $stackTrace');
      emit(ProfileError(message: e.toString()));
      rethrow;
    }
  }

  Future<void> updateUserAvatarFromBase64(
    String userId,
    String base64Image,
  ) async {
    emit(ProfileLoading());
    try {
      debugPrint('🔄 ProfileCubit: Updating user avatar from base64...');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   📏 Base64 length: ${base64Image.length}');

      // Create temporary file with base64 data
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Decode base64 and write to file
      final bytes = base64Decode(base64Image.split(',').last);
      await tempFile.writeAsBytes(bytes);

      debugPrint('   💾 Temporary file created: ${tempFile.path}');

      // Use the existing method with the temporary file
      await updateUserAvatar(userId, tempFile.path);

      // Clean up temporary file
      await tempFile.delete();
      debugPrint('   🧹 Temporary file cleaned up');
    } catch (e) {
      debugPrint('❌ ProfileCubit Error in updateUserAvatarFromBase64: $e');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      debugPrint('🔄 ProfileCubit: Getting image URL for path: $imagePath');
      final imageUrl = await repository.getImageUrl(imagePath);
      debugPrint('✅ ProfileCubit: Image URL retrieved: $imageUrl');
      return imageUrl;
    } on ProfileException catch (e) {
      debugPrint('❌ ProfileCubit ProfileException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ ProfileCubit Error getting image URL: $e');
      rethrow;
    }
  }

  Future<void> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    emit(ProfileLoading());
    try {
      debugPrint('🔄 ProfileCubit: Changing password...');
      final success = await repository.changePassword(
        userId,
        currentPassword,
        newPassword,
      );
      if (success) {
        debugPrint('✅ ProfileCubit: Password changed successfully');
        emit(PasswordChanged());
        // Reload user profile after password change
        await getUserProfile();
      } else {
        debugPrint('❌ ProfileCubit: Failed to change password');
        emit(ProfileError(message: 'Failed to change password'));
      }
    } on ProfileException catch (e) {
      debugPrint('❌ ProfileCubit ProfileException: ${e.message}');
      emit(ProfileError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 ProfileCubit Error in changePassword: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateUserEmail(
    String userId,
    String email,
    String password,
  ) async {
    emit(ProfileLoading());
    try {
      debugPrint('🔄 ProfileCubit: Updating user email...');
      final success = await repository.updateUserEmail(userId, email, password);
      if (success) {
        debugPrint('✅ ProfileCubit: Email updated successfully');
        emit(EmailUpdated(email: email));
        // Reload user profile after email change
        await getUserProfile();
      } else {
        debugPrint('❌ ProfileCubit: Failed to update email');
        emit(ProfileError(message: 'Failed to update email'));
      }
    } on ProfileException catch (e) {
      debugPrint('❌ ProfileCubit ProfileException: ${e.message}');
      emit(ProfileError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 ProfileCubit Error in updateUserEmail: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    emit(ProfileLoading());
    try {
      debugPrint('🔄 ProfileCubit: Updating user preferences...');
      final UserData updatedUser = await repository.updateUserPreferences(
        userId,
        preferences,
      );

      // Update storage with new user data
      await storage.write('user', updatedUser.toJson());

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser));

      debugPrint('✅ ProfileCubit: Preferences updated successfully');
    } on ProfileException catch (e) {
      debugPrint('❌ ProfileCubit ProfileException: ${e.message}');
      emit(ProfileError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 ProfileCubit Error in updateUserPreferences: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ProfileError(message: e.toString()));
    }
  }

  void clearProfile() {
    debugPrint('🔄 ProfileCubit: Clearing profile data');
    emit(ProfileInitial());
  }

  // Helper method to validate image before upload
  Future<bool> validateImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final exists = await file.exists();
      if (!exists) {
        debugPrint('❌ Image file does not exist: $imagePath');
        return false;
      }

      final stat = await file.stat();
      final fileSize = stat.size;

      // Check file size (e.g., max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        debugPrint('❌ Image file too large: ${fileSize ~/ 1024}KB');
        return false;
      }

      debugPrint('✅ Image validation passed: ${fileSize ~/ 1024}KB');
      return true;
    } catch (e) {
      debugPrint('❌ Image validation error: $e');
      return false;
    }
  }
}
