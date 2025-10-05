// repositories/profile_repository.dart
import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';

class ProfileRepository {
  Future<UserData> getUserById(String userId) async {
    try {
      final url = ApiEndpoints.getUserById.replaceFirst('<id>', userId);

      dio.Response response = await BaseClient.get(url: url);

      if (response.statusCode == 200) {
        return UserData.fromJson(response.data);
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
      final url = ApiEndpoints.getUserById.replaceFirst('<id>', userId);

      dio.Response response = await BaseClient.put(url: url, payload: updateData);

      if (response.statusCode == 200) {
        return UserData.fromJson(response.data);
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

  // Add this method to your ProfileRepository class
  Future<bool> updateUserAvatar(String userId, String imagePath) async {
    try {
      final url = '${ApiEndpoints.getUserById.replaceFirst('<id>', userId)}/avatar';

      var formData = dio.FormData.fromMap({
        'avatar': await dio.MultipartFile.fromFile(
          imagePath,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      dio.Response response = await BaseClient.post(url: url, payload: formData);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update avatar: ${response.statusCode}');
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

  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final url = '${ApiEndpoints.getUserById.replaceFirst('<id>', userId)}/password';

      dio.Response response = await BaseClient.put(
        url: url,
        payload: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

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
}
