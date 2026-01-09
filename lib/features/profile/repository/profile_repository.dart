// repositories/profile_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';

class ProfileException implements Exception {
  final String message;
  final int? statusCode;

  ProfileException({required this.message, this.statusCode});

  @override
  String toString() => 'ProfileException: $message';
}

class ProfileRepository {
  Future<ProfileResponseModel> getProfile() async {
    debugPrint('🚀 [ProfileRepository] Fetching user profile');
    try {
      final url = ApiEndpoints.getProfile;
      debugPrint('🌐 [ProfileRepository] API endpoint: $url');

      dio.Response response = await BaseClient.get(url: url);
      debugPrint(
        '📊 [ProfileRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        debugPrint('✅ [ProfileRepository] Profile fetched successfully');

        return ProfileResponseModel.fromJson(responseData);
      } else {
        debugPrint(
          '❌ [ProfileRepository] Failed with status: ${response.statusCode}',
        );
        throw ProfileException(
          message: 'Failed to fetch user: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [ProfileRepository] DioException: ${e.type}');
      debugPrint('📍 [ProfileRepository] Error details: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '📊 [ProfileRepository] Response status: ${e.response?.statusCode}',
        );
        throw ProfileException(
          message: 'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ProfileException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] Unexpected error: $e');
      debugPrint('📋 [ProfileRepository] Stack trace: $stackTrace');
      throw ProfileException(message: 'Unexpected error: $e');
    }
  }

  Future<UserData> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    debugPrint('🚀 [ProfileRepository] Updating user profile');
    debugPrint('👤 [ProfileRepository] User ID: $userId');
    debugPrint('📝 [ProfileRepository] Update data: $updateData');
    try {
      final url = ApiEndpoints.updateProfileById.replaceFirst('<id>', userId);
      debugPrint('🌐 [ProfileRepository] API endpoint: $url');

      dio.Response response = await BaseClient.patch(
        url: url,
        payload: updateData,
      );
      debugPrint(
        '📊 [ProfileRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        debugPrint('✅ [ProfileRepository] Profile updated successfully');

        return UserData.fromJson(responseData);
      } else {
        debugPrint(
          '❌ [ProfileRepository] Failed with status: ${response.statusCode}',
        );
        throw ProfileException(
          message: 'Failed to update user: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [ProfileRepository] DioException: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '📊 [ProfileRepository] Response status: ${e.response?.statusCode}',
        );
        throw ProfileException(
          message:
              e.response?.data['message'] ??
              'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ProfileException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] Unexpected error: $e');
      debugPrint('📋 [ProfileRepository] Stack trace: $stackTrace');
      throw ProfileException(message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> updateUserAvatar(String userId, String imagePath) async {
    try {
      final url = ApiEndpoints.uploadProfileAvatar.replaceFirst(
        '<userId>',
        userId,
      );

      // Validate file
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }

      // final fileSize = await file.length();

      // Read and encode file
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';

      final base64String = 'data:$mimeType;base64,$base64Image';

      // Create payload
      final Map<String, dynamic> payload = {"file": base64String};

      // Debug the full request

      dio.Response response = await BaseClient.post(url: url, payload: payload);

      if (response.statusCode == 201) {
        // Parse JSON string to Map if needed
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // Return the parsed data as a Map with file path and URL
        return responseData;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.data}',
        );
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {}

      if (e.error != null) {}

      // More specific error handling
      String errorMessage;
      switch (e.type) {
        case dio.DioExceptionType.connectionTimeout:
          errorMessage =
              'Connection timeout. Please check your internet connection.';
          break;
        case dio.DioExceptionType.sendTimeout:
          errorMessage =
              'Upload timeout. The server is taking too long to respond.';
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
          errorMessage =
              'Cannot connect to server. Please check your internet connection.';
          break;
        case dio.DioExceptionType.unknown:
          errorMessage = 'Network error: ${e.message ?? "Unknown error"}';
          if (e.error is SocketException) {
            errorMessage = 'No internet connection. Please check your network.';
          }
          break;
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    debugPrint('🚀 [ProfileRepository] Getting image URL');
    debugPrint('📁 [ProfileRepository] Image path: $imagePath');
    try {
      dio.Response response = await BaseClient.get(
        url: ApiEndpoints.getAnImage,
        payload: {'imagePath': imagePath},
      );
      debugPrint(
        '📊 [ProfileRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // Handle different possible structures
        if (data is String && data.isNotEmpty) {
          debugPrint('✅ [ProfileRepository] Image URL retrieved (String)');
          return data;
        } else if (data is Map && data['data'] is String) {
          debugPrint('✅ [ProfileRepository] Image URL retrieved (Map[data])');
          return data['data'];
        } else if (data is Map && data['url'] is String) {
          debugPrint('✅ [ProfileRepository] Image URL retrieved (Map[url])');
          return data['url'];
        } else {
          debugPrint('❌ [ProfileRepository] Invalid response structure: $data');
          throw ProfileException(
            message: 'Invalid or empty image URL in response: $data',
          );
        }
      } else {
        debugPrint(
          '❌ [ProfileRepository] Failed with status: ${response.statusCode}',
        );
        throw ProfileException(
          message: 'Failed to get image URL: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [ProfileRepository] DioException: ${e.type}');
      throw ProfileException(
        message: 'Network error while getting image URL: ${e.message}',
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] Unexpected error: $e');
      debugPrint('📋 [ProfileRepository] Stack trace: $stackTrace');
      throw ProfileException(
        message: 'Unexpected error while getting image URL: $e',
      );
    }
  }

  Future<bool> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    debugPrint('🚀 [ProfileRepository] Changing password');
    debugPrint('👤 [ProfileRepository] User ID: $userId');
    try {
      final url = ApiEndpoints.updateProfilePassword.replaceFirst(
        '<id>',
        userId,
      );
      debugPrint('🌐 [ProfileRepository] API endpoint: $url');

      final payload = {
        "password": currentPassword,
        "updatedPassword": newPassword,
      };

      dio.Response response = await BaseClient.patch(
        url: url,
        payload: payload,
      );
      debugPrint(
        '📊 [ProfileRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [ProfileRepository] Password changed successfully');
        return true;
      } else {
        debugPrint(
          '❌ [ProfileRepository] Failed with status: ${response.statusCode}',
        );
        throw ProfileException(
          message: 'Failed to change password: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [ProfileRepository] DioException: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '📊 [ProfileRepository] Response status: ${e.response?.statusCode}',
        );
        throw ProfileException(
          message:
              e.response?.data['message'] ??
              'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ProfileException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] Unexpected error: $e');
      debugPrint('📋 [ProfileRepository] Stack trace: $stackTrace');
      throw ProfileException(message: 'Unexpected error: $e');
    }
  }

  Future<bool> updateUserEmail(
    String userId,
    String email,
    String password,
  ) async {
    debugPrint('🚀 [ProfileRepository] Updating user email');
    debugPrint('👤 [ProfileRepository] User ID: $userId');
    debugPrint('📧 [ProfileRepository] New email: $email');
    try {
      final url = ApiEndpoints.updateProfileEmail.replaceFirst('<id>', userId);
      debugPrint('🌐 [ProfileRepository] API endpoint: $url');

      final payload = {"password": password, "email": email};

      dio.Response response = await BaseClient.patch(
        url: url,
        payload: payload,
      );
      debugPrint(
        '📊 [ProfileRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [ProfileRepository] Email updated successfully');
        return true;
      } else {
        debugPrint(
          '❌ [ProfileRepository] Failed with status: ${response.statusCode}',
        );
        throw ProfileException(
          message: 'Failed to update email: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [ProfileRepository] DioException: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '📊 [ProfileRepository] Response status: ${e.response?.statusCode}',
        );
        throw ProfileException(
          message:
              e.response?.data['message'] ??
              'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ProfileException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] Unexpected error: $e');
      debugPrint('📋 [ProfileRepository] Stack trace: $stackTrace');
      throw ProfileException(message: 'Unexpected error: $e');
    }
  }

  // Method to update specific fields like language preference
  Future<UserData> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    debugPrint('🚀 [ProfileRepository] Updating user preferences');
    debugPrint('👤 [ProfileRepository] User ID: $userId');
    debugPrint('📝 [ProfileRepository] Preferences: $preferences');
    try {
      final url = ApiEndpoints.updateProfileById.replaceFirst('<id>', userId);
      debugPrint('🌐 [ProfileRepository] API endpoint: $url');

      dio.Response response = await BaseClient.patch(
        url: url,
        payload: preferences,
      );
      debugPrint(
        '📊 [ProfileRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [ProfileRepository] Preferences updated successfully');
        return UserData.fromJson(response.data);
      } else {
        debugPrint(
          '❌ [ProfileRepository] Failed with status: ${response.statusCode}',
        );
        throw ProfileException(
          message: 'Failed to update preferences: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('💥 [ProfileRepository] DioException: ${e.type}');
      if (e.response != null) {
        debugPrint(
          '📊 [ProfileRepository] Response status: ${e.response?.statusCode}',
        );
        throw ProfileException(
          message:
              e.response?.data['message'] ??
              'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ProfileException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 [ProfileRepository] Unexpected error: $e');
      debugPrint('📋 [ProfileRepository] Stack trace: $stackTrace');
      throw ProfileException(message: 'Unexpected error: $e');
    }
  }
}
