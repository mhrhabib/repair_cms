import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/models/service_response_model.dart';

abstract class ServiceRepository {
  Future<ServiceResponseModel> getServicesList({
    String manufacturer = '1',
    String model = '1',
    bool ase = false,
    String name = '-1',
    String keyword = '',
  });
}

class ServiceRepositoryImpl implements ServiceRepository {
  @override
  Future<ServiceResponseModel> getServicesList({
    String manufacturer = '1',
    String model = '1',
    bool ase = false,
    String name = '-1',
    String keyword = '',
  }) async {
    try {
      debugPrint('🚀 [ServiceRepository] Starting API call with parameters:');
      debugPrint('   📍 URL: ${ApiEndpoints.servicesListUrl}');
      debugPrint(
        '   🔧 manufacturer: $manufacturer (${manufacturer.runtimeType})',
      );
      debugPrint('   🔧 model: $model (${model.runtimeType})');
      debugPrint('   🔧 ase: $ase (${ase.runtimeType})');
      debugPrint('   🔧 name: $name (${name.runtimeType})');
      debugPrint('   🔧 keyword: $keyword (${keyword.runtimeType})');

      dio.Response response = await BaseClient.get(
        url: '${ApiEndpoints.servicesListUrl}/user/${storage.read('userId')}',
        payload: {
          'manufacturer': manufacturer,
          'model': model,
          'ase': ase.toString(),
          'name': name,
          'keyword': keyword,
          'express_service': 'true',
        },
      );

      debugPrint('✅ [ServiceRepository] API Response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      // Debug the response data structure
      if (response.data is Map) {
        final data = response.data as Map;
        debugPrint('   📊 Response Keys: ${data.keys}');

        // Check critical fields
        if (data.containsKey('success')) {
          debugPrint(
            '   ✅ success: ${data['success']} (${data['success'].runtimeType})',
          );
        }
        if (data.containsKey('totalServices')) {
          debugPrint(
            '   ✅ totalServices: ${data['totalServices']} (${data['totalServices'].runtimeType})',
          );
        }
        if (data.containsKey('services')) {
          debugPrint(
            '   ✅ services: ${data['services']} (${data['services'].runtimeType})',
          );
          if (data['services'] is List) {
            debugPrint(
              '   📋 services list length: ${(data['services'] as List).length}',
            );
            if ((data['services'] as List).isNotEmpty) {
              final firstService = (data['services'] as List).first;
              if (firstService is Map) {
                debugPrint('   🔍 First service keys: ${(firstService).keys}');
              }
            }
          }
        }
      } else {
        debugPrint('   ⚠️ Response data is not a Map: ${response.data}');
      }

      if (response.statusCode == 200) {
        debugPrint(
          '🔄 [ServiceRepository] Parsing response with ServiceResponseModel.fromJson',
        );
        try {
          final result = ServiceResponseModel.fromJson(response.data);
          debugPrint('✅ [ServiceRepository] Successfully parsed response');
          return result;
        } catch (parseError, parseStack) {
          debugPrint(
            '❌ [ServiceRepository] Error in ServiceResponseModel.fromJson:',
          );
          debugPrint('   💥 Parse Error: $parseError');
          debugPrint('   📋 Parse Stack: $parseStack');
          rethrow;
        }
      } else {
        throw ServiceException(
          message: 'Failed to load services: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [ServiceRepository] DioException occurred:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      debugPrint('   📊 Status: ${e.response?.statusCode}');
      throw ServiceException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [ServiceRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      debugPrint('   🎯 Error Type: ${e.runtimeType}');
      throw ServiceException(message: 'Unexpected error: $e');
    }
  }
}

class ServiceException implements Exception {
  final String message;
  final int? statusCode;

  ServiceException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ServiceException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
