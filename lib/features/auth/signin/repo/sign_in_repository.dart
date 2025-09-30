// repositories/signin_repository.dart
import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';

import '../models/find_user_response_model.dart';
import '../models/login_response_model.dart';

class SignInRepository {
  Future<FindUserResponseModel> findUserByEmail(String email) async {
    try {
      dio.Response response = await BaseClient.post(
        url: ApiEndpoints.findUserByEmail + email,
        payload: {"email": email},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FindUserResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to find user: ${response.statusCode}');
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

  Future<LoginResponseModel> login(String email, String password) async {
    try {
      dio.Response response = await BaseClient.post(
        url: ApiEndpoints.login,
        payload: {"email": email, "password": password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
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
