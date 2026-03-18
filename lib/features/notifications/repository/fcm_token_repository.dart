import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/notifications/models/fcm_token_model.dart';

abstract class FcmTokenRepository {
  Future<FcmTokenModel> registerToken({required String token});
  Future<List<FcmTokenModel>> getTokens();
  Future<void> deleteToken({required String tokenId});
}

class FcmTokenRepositoryImpl implements FcmTokenRepository {
  @override
  Future<FcmTokenModel> registerToken({required String token}) async {
    try {
      debugPrint('🚀 [FcmTokenRepository] Registering FCM token');
      debugPrint('   📍 URL: ${ApiEndpoints.fcmToken}');

      var payload = {
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      };

      dio.Response response = await BaseClient.post(
        url: ApiEndpoints.fcmToken,
        payload: payload,
      );
      debugPrint(payload.toString());

      debugPrint('✅ [FcmTokenRepository] Register response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        // Handle response wrapped in data key or direct object
        if (responseData is Map && responseData.containsKey('data')) {
          return FcmTokenModel.fromJson(responseData['data']);
        }
        return FcmTokenModel.fromJson(responseData);
      } else {
        throw FcmTokenException(
          message: 'Failed to register token: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [FcmTokenRepository] DioException: ${e.message}');
      throw FcmTokenException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('💥 [FcmTokenRepository] Unexpected error: $e');
      throw FcmTokenException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<FcmTokenModel>> getTokens() async {
    try {
      debugPrint('🚀 [FcmTokenRepository] Listing FCM tokens');
      dio.Response response = await BaseClient.get(url: ApiEndpoints.fcmToken);

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        if (responseData is List) {
          return responseData
              .map((json) => FcmTokenModel.fromJson(json))
              .toList();
        } else if (responseData is Map && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((json) => FcmTokenModel.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw FcmTokenException(
          message: 'Failed to get tokens: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('💥 [FcmTokenRepository] Error getting tokens: $e');
      throw FcmTokenException(message: 'Error getting tokens: $e');
    }
  }

  @override
  Future<void> deleteToken({required String tokenId}) async {
    try {
      debugPrint('🚀 [FcmTokenRepository] Deleting FCM token: $tokenId');
      dio.Response response = await BaseClient.delete(
        url: '${ApiEndpoints.fcmToken}/$tokenId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw FcmTokenException(
          message: 'Failed to delete token: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('💥 [FcmTokenRepository] Error deleting token: $e');
      throw FcmTokenException(message: 'Error deleting token: $e');
    }
  }
}

class FcmTokenException implements Exception {
  final String message;
  final int? statusCode;

  FcmTokenException({required this.message, this.statusCode});

  @override
  String toString() =>
      'FcmTokenException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
