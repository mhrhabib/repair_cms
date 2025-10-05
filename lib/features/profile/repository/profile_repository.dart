// repositories/profile_repository.dart
import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';

class ProfileRepository {
  Future<ProfileResponseModel> getProfile() async {
    try {
      final url = ApiEndpoints.getProfile;

      // Print which endpoint is being called
      debugPrint('🎯 Profile Repository: Fetching profile from $url');

      dio.Response response = await BaseClient.get(url: url);

      if (response.statusCode == 200) {
        debugPrint('✅ Profile data fetched successfully');
        return ProfileResponseModel.fromJson(response.data);
      } else {
        debugPrint('❌ Profile fetch failed with status: ${response.statusCode}');
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ DioException in ProfileRepository: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in ProfileRepository: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserData> updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    try {
      final url = ApiEndpoints.updateProfileById.replaceFirst('<id>', userId);

      debugPrint('🎯 Updating profile for user: $userId');
      debugPrint('📦 Update data: $updateData');

      dio.Response response = await BaseClient.patch(url: url, payload: updateData);

      if (response.statusCode == 200) {
        debugPrint('✅ Profile updated successfully');
        return UserData.fromJson(response.data);
      } else {
        debugPrint('❌ Profile update failed with status: ${response.statusCode}');
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ DioException in updateUserProfile: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in updateUserProfile: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> updateUserAvatar(String userId, String imagePath) async {
    try {
      final url = ApiEndpoints.updateProfileAvatar.replaceFirst('<id>', userId);

      debugPrint('🎯 Updating avatar for user: $userId');

      var formData = dio.FormData.fromMap({
        'avatar': await dio.MultipartFile.fromFile(
          imagePath,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      dio.Response response = await BaseClient.post(url: url, payload: formData);

      if (response.statusCode == 200) {
        debugPrint('✅ Avatar updated successfully');
        return true;
      } else {
        debugPrint('❌ Avatar update failed with status: ${response.statusCode}');
        throw Exception('Failed to update avatar: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ DioException in updateUserAvatar: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in updateUserAvatar: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final url = ApiEndpoints.updateProfilePassword.replaceFirst('<id>', userId);

      debugPrint('🎯 Changing password for user: $userId');

      final payload = {"password": currentPassword, "updatedPassword": newPassword};

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Password changed successfully');
        return true;
      } else {
        debugPrint('❌ Password change failed with status: ${response.statusCode}');
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ DioException in changePassword: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in changePassword: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> updateUserEmail(String userId, String email, String password) async {
    try {
      final url = ApiEndpoints.updateProfileEmail.replaceFirst('<id>', userId);

      debugPrint('🎯 Updating email for user: $userId');
      debugPrint('📧 New email: $email');

      final payload = {"password": password, "email": email};

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Email updated successfully');
        return true;
      } else {
        debugPrint('❌ Email update failed with status: ${response.statusCode}');
        throw Exception('Failed to update email: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ DioException in updateUserEmail: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in updateUserEmail: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Method to update specific fields like language preference
  Future<UserData> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      final url = ApiEndpoints.updateProfileById.replaceFirst('<id>', userId);

      debugPrint('🎯 Updating preferences for user: $userId');
      debugPrint('📦 Preferences data: $preferences');

      dio.Response response = await BaseClient.patch(url: url, payload: preferences);

      if (response.statusCode == 200) {
        debugPrint('✅ Preferences updated successfully');
        return UserData.fromJson(response.data);
      } else {
        debugPrint('❌ Preferences update failed with status: ${response.statusCode}');
        throw Exception('Failed to update preferences: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ DioException in updateUserPreferences: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in updateUserPreferences: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
