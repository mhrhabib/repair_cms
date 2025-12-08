// repositories/profile_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:mime/mime.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';

class ProfileRepository {
  Future<ProfileResponseModel> getProfile() async {
    try {
      final url = ApiEndpoints.getProfile;

      // Print which endpoint is being called

      dio.Response response = await BaseClient.get(url: url);

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

        return ProfileResponseModel.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserData> updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    try {
      final url = ApiEndpoints.updateProfileById.replaceFirst('<id>', userId);

      dio.Response response = await BaseClient.patch(url: url, payload: updateData);

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

        return UserData.fromJson(responseData);
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<dynamic> updateUserAvatar(String userId, String imagePath) async {
    try {
      final url = ApiEndpoints.uploadProfileAvatar.replaceFirst('<userId>', userId);

      // Validate file
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }

      final fileSize = await file.length();

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
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

        // Return the parsed data as a Map with file path and URL
        return responseData;
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.data}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {}

      if (e.error != null) {}

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
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      dio.Response response = await BaseClient.get(url: ApiEndpoints.getAnImage, payload: {'imagePath': imagePath});

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final data = response.data is String ? jsonDecode(response.data) : response.data;

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
      throw Exception('Network error while getting image URL: ${e.message}');
    } catch (e, stackTrace) {
      throw Exception('Unexpected error while getting image URL: $e');
    }
  }

  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final url = ApiEndpoints.updateProfilePassword.replaceFirst('<id>', userId);

      final payload = {"password": currentPassword, "updatedPassword": newPassword};

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> updateUserEmail(String userId, String email, String password) async {
    try {
      final url = ApiEndpoints.updateProfileEmail.replaceFirst('<id>', userId);

      final payload = {"password": password, "email": email};

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update email: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Method to update specific fields like language preference
  Future<UserData> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      final url = ApiEndpoints.updateProfileById.replaceFirst('<id>', userId);

      dio.Response response = await BaseClient.patch(url: url, payload: preferences);

      if (response.statusCode == 200) {
        return UserData.fromJson(response.data);
      } else {
        throw Exception('Failed to update preferences: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
