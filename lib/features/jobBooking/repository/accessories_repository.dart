import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/accessories_model.dart';

abstract class AccessoriesRepository {
  Future<List<Data>> getAccessoriesList({required String userId});
  Future<Data> createAccessory({required String value, required String label, required String userId});
}

class AccessoriesRepositoryImpl implements AccessoriesRepository {
  @override
  Future<List<Data>> getAccessoriesList({required String userId}) async {
    try {
      debugPrint('🚀 [AccessoriesRepository] Fetching accessories list');
      debugPrint('   📍 URL: ${ApiEndpoints.accessoriesListUrl.replaceAll('<id>', userId)}');
      debugPrint('   👤 User ID: $userId');

      Response response = await BaseClient.get(url: ApiEndpoints.accessoriesListUrl.replaceAll('<id>', userId));

      debugPrint('✅ [AccessoriesRepository] Accessories response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final accessoriesModel = AccessoriesModel.fromJson(response.data);

        if (accessoriesModel.success == true && accessoriesModel.data != null) {
          debugPrint('   📦 Parsed ${accessoriesModel.data!.length} accessories');
          return accessoriesModel.data!;
        } else {
          debugPrint('   ⚠️ No accessories found or success false');
          return [];
        }
      } else {
        throw AccessoriesException(
          message: 'Failed to load accessories: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [AccessoriesRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw AccessoriesException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [AccessoriesRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw AccessoriesException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<Data> createAccessory({required String value, required String label, required String userId}) async {
    try {
      debugPrint('🚀 [AccessoriesRepository] Creating new accessory: $label');

      final payload = {"value": value, "label": label, "userId": userId};

      Response response = await BaseClient.post(url: ApiEndpoints.createAccessories, payload: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccessory = Data.fromJson(response.data);
        debugPrint('✅ [AccessoriesRepository] Accessory created successfully: ${newAccessory.label}');
        return newAccessory;
      } else {
        throw AccessoriesException(
          message: 'Failed to create accessory: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [AccessoriesRepository] DioException while creating accessory:');
      debugPrint('   💥 Error: ${e.message}');
      throw AccessoriesException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [AccessoriesRepository] Unexpected error while creating accessory:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw AccessoriesException(message: 'Unexpected error: $e');
    }
  }
}

class AccessoriesException implements Exception {
  final String message;
  final int? statusCode;

  AccessoriesException({required this.message, this.statusCode});

  @override
  String toString() => 'AccessoriesException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
