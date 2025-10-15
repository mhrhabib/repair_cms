import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/models_model.dart';

abstract class ModelsRepository {
  Future<List<ModelsModel>> getModelsList({required String brandId});
  Future<ModelsModel> createModel({required String name, required String userId, required String brandId});
}

class ModelsRepositoryImpl implements ModelsRepository {
  @override
  Future<List<ModelsModel>> getModelsList({required String brandId}) async {
    try {
      debugPrint('🚀 [ModelsRepository] Fetching models list');
      debugPrint('   📍 URL: ${ApiEndpoints.modelsListUrl.replaceAll('<brandId>', brandId)}');
      debugPrint('   🏷️ Brand ID: $brandId');

      Response response = await BaseClient.get(url: ApiEndpoints.modelsListUrl.replaceAll('<brandId>', brandId));

      debugPrint('✅ [ModelsRepository] Models response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final models = (response.data as List).map((modelJson) => ModelsModel.fromJson(modelJson)).toList();
          debugPrint('   📦 Parsed ${models.length} models');
          return models;
        } else if (response.data is Map) {
          // Handle case where API returns wrapped in a map
          final data = response.data as Map;
          if (data.containsKey('models') && data['models'] is List) {
            final models = (data['models'] as List).map((modelJson) => ModelsModel.fromJson(modelJson)).toList();
            debugPrint('   📦 Parsed ${models.length} models from "models" key');
            return models;
          } else if (data.containsKey('data') && data['data'] is List) {
            final models = (data['data'] as List).map((modelJson) => ModelsModel.fromJson(modelJson)).toList();
            debugPrint('   📦 Parsed ${models.length} models from "data" key');
            return models;
          }
        }

        debugPrint('   ⚠️ Unexpected response format: ${response.data}');
        throw ModelsException(message: 'Unexpected response format from server');
      } else {
        throw ModelsException(
          message: 'Failed to load models: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [ModelsRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw ModelsException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [ModelsRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw ModelsException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<ModelsModel> createModel({required String name, required String userId, required String brandId}) async {
    try {
      print('🚀 [ModelsRepository] Creating new model: $name');

      final payload = {"name": name, "userId": userId, "brandId": brandId};

      Response response = await BaseClient.post(url: ApiEndpoints.createModel, payload: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newModel = ModelsModel.fromJson(response.data);
        print('✅ [ModelsRepository] Model created successfully: ${newModel.name}');
        return newModel;
      } else {
        throw ModelsException(
          message: 'Failed to create model: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('🌐 [ModelsRepository] DioException while creating model:');
      print('   💥 Error: ${e.message}');
      throw ModelsException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      print('💥 [ModelsRepository] Unexpected error while creating model:');
      print('   💥 Error: $e');
      throw ModelsException(message: 'Unexpected error: $e');
    }
  }
}

class ModelsException implements Exception {
  final String message;
  final int? statusCode;

  ModelsException({required this.message, this.statusCode});

  @override
  String toString() => 'ModelsException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
