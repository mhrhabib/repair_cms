import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'dart:convert';
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
      debugPrint('   🔧 manufacturer: $manufacturer (${manufacturer.runtimeType})');
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

      // Handle both String and Map responses
      Map<String, dynamic> jsonData;
      if (response.data is String) {
        debugPrint('   🔄 Response is String, parsing JSON...');
        jsonData = jsonDecode(response.data as String);
      } else if (response.data is Map) {
        jsonData = response.data as Map<String, dynamic>;
      } else {
        throw ServiceException(
          message: 'Unexpected response type: ${response.data.runtimeType}',
          statusCode: response.statusCode,
        );
      }

      // Debug the response data structure
      debugPrint('   📊 Response Keys: ${jsonData.keys}');

      // Check critical fields
      if (jsonData.containsKey('success')) {
        debugPrint('   ✅ success: ${jsonData['success']} (${jsonData['success'].runtimeType})');
      }
      if (jsonData.containsKey('totalServices')) {
        debugPrint('   ✅ totalServices: ${jsonData['totalServices']} (${jsonData['totalServices'].runtimeType})');
      }
      if (jsonData.containsKey('services')) {
        debugPrint('   ✅ services: ${jsonData['services']} (${jsonData['services'].runtimeType})');
        if (jsonData['services'] is List) {
          debugPrint('   📋 services list length: ${(jsonData['services'] as List).length}');
          if ((jsonData['services'] as List).isNotEmpty) {
            final firstService = (jsonData['services'] as List).first;
            if (firstService is Map) {
              debugPrint('   🔍 First service keys: ${(firstService).keys}');
            }
          }
        }
      }

      if (response.statusCode == 200) {
        debugPrint('🔄 [ServiceRepository] Parsing response with ServiceResponseModel.fromJson');
        try {
          final result = ServiceResponseModel.fromJson(jsonData);
          debugPrint('✅ [ServiceRepository] Successfully parsed response');
          return result;
        } catch (parseError, parseStack) {
          debugPrint('❌ [ServiceRepository] Error in ServiceResponseModel.fromJson:');
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
      throw ServiceException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
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
  String toString() => 'ServiceException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
