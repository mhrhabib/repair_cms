import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/auth/forgotPassword/models/reponse_models.dart';

class ForgotPasswordRepository {
  Future<SendOtpResponseModel> sendOtp(String email) async {
    try {
      dio.Response response = await BaseClient.post(url: ApiEndpoints.sentOtp, payload: {"email": email});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SendOtpResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        throw Exception(errorData['message'] ?? errorData['error'] ?? 'Failed to send OTP');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<VerifyOtpResponseModel> verifyOtp(String email, String otp) async {
    try {
      dio.Response response = await BaseClient.post(url: ApiEndpoints.verifyOtp, payload: {"email": email, "otp": otp});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return VerifyOtpResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to verify OTP: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        throw Exception(errorData['message'] ?? errorData['error'] ?? 'Failed to verify OTP');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<ResetPasswordResponseModel> resetPassword(String email, String newPassword) async {
    try {
      dio.Response response = await BaseClient.put(
        url: ApiEndpoints.updatePassword + email,
        payload: {"password": newPassword},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResetPasswordResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to reset password: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        throw Exception(errorData['message'] ?? errorData['error'] ?? 'Failed to reset password');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
