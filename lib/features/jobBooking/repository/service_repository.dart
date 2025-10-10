import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
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
      print('🚀 [ServiceRepository] Starting API call with parameters:');
      print('   📍 URL: ${ApiEndpoints.servicesListUrl}');
      print('   🔧 manufacturer: $manufacturer (${manufacturer.runtimeType})');
      print('   🔧 model: $model (${model.runtimeType})');
      print('   🔧 ase: $ase (${ase.runtimeType})');
      print('   🔧 name: $name (${name.runtimeType})');
      print('   🔧 keyword: $keyword (${keyword.runtimeType})');

      dio.Response response = await BaseClient.get(
        url: ApiEndpoints.servicesListUrl,
        payload: {
          'manufacturer': manufacturer,
          'model': model,
          'ase': ase.toString(),
          'name': name,
          'keyword': keyword,
        },
      );

      print('✅ [ServiceRepository] API Response received:');
      print('   📊 Status Code: ${response.statusCode}');
      print('   📊 Response Type: ${response.data.runtimeType}');

      // Debug the response data structure
      if (response.data is Map) {
        final data = response.data as Map;
        print('   📊 Response Keys: ${data.keys}');

        // Check critical fields
        if (data.containsKey('success')) {
          print('   ✅ success: ${data['success']} (${data['success'].runtimeType})');
        }
        if (data.containsKey('totalServices')) {
          print('   ✅ totalServices: ${data['totalServices']} (${data['totalServices'].runtimeType})');
        }
        if (data.containsKey('services')) {
          print('   ✅ services: ${data['services']} (${data['services'].runtimeType})');
          if (data['services'] is List) {
            print('   📋 services list length: ${(data['services'] as List).length}');
            if ((data['services'] as List).isNotEmpty) {
              final firstService = (data['services'] as List).first;
              if (firstService is Map) {
                print('   🔍 First service keys: ${(firstService as Map).keys}');
              }
            }
          }
        }
      } else {
        print('   ⚠️ Response data is not a Map: ${response.data}');
      }

      if (response.statusCode == 200) {
        print('🔄 [ServiceRepository] Parsing response with ServiceResponseModel.fromJson');
        try {
          final result = ServiceResponseModel.fromJson(response.data);
          print('✅ [ServiceRepository] Successfully parsed response');
          return result;
        } catch (parseError, parseStack) {
          print('❌ [ServiceRepository] Error in ServiceResponseModel.fromJson:');
          print('   💥 Parse Error: $parseError');
          print('   📋 Parse Stack: $parseStack');
          rethrow;
        }
      } else {
        throw ServiceException(
          message: 'Failed to load services: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('🌐 [ServiceRepository] DioException occurred:');
      print('   💥 Error: ${e.message}');
      print('   📍 Type: ${e.type}');
      print('   🔧 Response: ${e.response?.data}');
      print('   📊 Status: ${e.response?.statusCode}');
      throw ServiceException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      print('💥 [ServiceRepository] Unexpected error:');
      print('   💥 Error: $e');
      print('   📋 Stack: $stackTrace');
      print('   🎯 Error Type: ${e.runtimeType}');
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
