// repositories/profile_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:mime/mime.dart';
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

  Future<dynamic> updateUserAvatar(String userId, String imagePath) async {
    try {
      final url = ApiEndpoints.uploadProfileAvatar.replaceFirst('<userId>', userId);

      debugPrint('🚀 [ProfileRepository] Starting avatar upload...');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   📁 Image path: $imagePath');
      debugPrint('   🌐 URL: $url');

      // Validate file
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }

      final fileSize = await file.length();
      debugPrint('   📏 File size: ${fileSize ~/ 1024}KB');

      // Read and encode file
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';

      debugPrint('   🖼️ MIME type: $mimeType');
      debugPrint(
        '   🔤 Base64 starts with: ${base64Image.substring(0, 20)}...',
      ); // This should show /9j/ which is CORRECT
      debugPrint('   📊 Base64 length: ${base64Image.length}');

      final base64String = 'data:$mimeType;base64,$base64Image';

      // Create payload
      final Map<String, dynamic> payload = {"file": base64String};

      debugPrint('📤 [ProfileRepository] Sending request...');

      // Debug the full request
      debugPrint('   📦 Payload keys: ${payload.keys}');
      debugPrint('   📦 Payload file length: ${base64String.length}');
      debugPrint('   ⏱️ Timeout: 30 seconds');

      dio.Response response = await BaseClient.post(url: url, payload: payload);

      debugPrint('✅ [ProfileRepository] Response received');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📄 Response Type: ${response.data.runtimeType}');
      debugPrint('   📄 Response Data: ${response.data}');

      if (response.statusCode == 201) {
        final imagePath = response.data;
        debugPrint('   🎉 Avatar uploaded successfully!');
        debugPrint('   📁 Server returned path: $imagePath');
        return imagePath;
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.data}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ [ProfileRepository] DIO ERROR DETAILS:');
      debugPrint('   🚨 Error Type: ${e.type}');
      debugPrint('   📝 Error Message: ${e.message}');
      debugPrint('   🔗 Request URL: ${e.requestOptions.uri}');
      debugPrint('   📦 Request Method: ${e.requestOptions.method}');
      debugPrint('   ⏱️ Request Timeout: ${e.requestOptions.sendTimeout}');

      if (e.response != null) {
        debugPrint('   📊 Response Status: ${e.response?.statusCode}');
        debugPrint('   📄 Response Data: ${e.response?.data}');
        debugPrint('   📋 Response Headers: ${e.response?.headers}');
      }

      if (e.error != null) {
        debugPrint('   💥 Underlying Error: ${e.error}');
        debugPrint('   📜 Error Stack: ${e.stackTrace}');
      }

      // More specific error handling
      String errorMessage;
      switch (e.type) {
        case dio.DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout. Please check your internet connection.';
          break;
        case dio.DioExceptionType.sendTimeout:
          errorMessage = 'Upload timeout. The server is taking too long to respond.';
          break;
        case dio.DioExceptionType.receiveTimeout:
          errorMessage = 'Server response timeout.';
          break;
        case dio.DioExceptionType.badCertificate:
          errorMessage = 'SSL certificate error. Please try again.';
          break;
        case dio.DioExceptionType.badResponse:
          errorMessage = 'Server error: ${e.response?.statusCode}';
          break;
        case dio.DioExceptionType.cancel:
          errorMessage = 'Request was cancelled.';
          break;
        case dio.DioExceptionType.connectionError:
          errorMessage = 'Cannot connect to server. Please check your internet connection.';
          break;
        case dio.DioExceptionType.unknown:
          errorMessage = 'Network error: ${e.message ?? "Unknown error"}';
          if (e.error is SocketException) {
            errorMessage = 'No internet connection. Please check your network.';
          }
          break;
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] UNEXPECTED ERROR:');
      debugPrint('   📝 Error: $e');
      debugPrint('   📜 Stack Trace: $stackTrace');
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      debugPrint('🚀 [ProfileRepository] Getting image URL for path: $imagePath');

      dio.Response response = await BaseClient.get(url: ApiEndpoints.getAnImage, payload: {'imagePath': imagePath});

      debugPrint('✅ [ProfileRepository] Image URL response received');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   🧾 Raw Data 1: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('   🧾 Raw Data: $data');
        // Handle different possible structures
        if (data is String && data.isNotEmpty) {
          return data;
        } else if (data is Map && data['data'] is String) {
          return data['data'];
        } else if (data is Map && data['url'] is String) {
          return data['url'];
        } else {
          throw Exception('Invalid or empty image URL in response: $data');
        }
      } else {
        throw Exception('Failed to get image URL: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('🌐 [ProfileRepository] DioException: ${e.message}');
      throw Exception('Network error while getting image URL: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] Unexpected error: $e\n$stackTrace');
      throw Exception('Unexpected error while getting image URL: $e');
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
