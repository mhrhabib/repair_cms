import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/brand_model.dart';

abstract class BrandRepository {
  Future<List<BrandModel>> getBrandsList({required String userId});
  Future<BrandModel> addBrand({required String userId, required String name});
}

class BrandRepositoryImpl implements BrandRepository {
  @override
  Future<List<BrandModel>> getBrandsList({required String userId}) async {
    try {
      debugPrint('🚀 [BrandRepository] Fetching brands list');
      debugPrint('   📍 URL: ${ApiEndpoints.brandsListUrl.replaceAll('<id>', userId)}');
      debugPrint('   👤 User ID: $userId');

      dio.Response response = await BaseClient.get(url: ApiEndpoints.brandsListUrl.replaceAll('<id>', userId));

      debugPrint('✅ [BrandRepository] Brands response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final brands = (response.data as List).map((brandJson) => BrandModel.fromJson(brandJson)).toList();
          debugPrint('   📦 Parsed ${brands.length} brands');
          return brands;
        } else if (response.data is Map) {
          final data = response.data as Map;
          if (data.containsKey('brands') && data['brands'] is List) {
            final brands = (data['brands'] as List).map((brandJson) => BrandModel.fromJson(brandJson)).toList();
            debugPrint('   📦 Parsed ${brands.length} brands from "brands" key');
            return brands;
          } else if (data.containsKey('data') && data['data'] is List) {
            final brands = (data['data'] as List).map((brandJson) => BrandModel.fromJson(brandJson)).toList();
            debugPrint('   📦 Parsed ${brands.length} brands from "data" key');
            return brands;
          }
        }

        debugPrint('   ⚠️ Unexpected response format: ${response.data}');
        throw BrandException(message: 'Unexpected response format from server');
      } else {
        throw BrandException(message: 'Failed to load brands: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      debugPrint('🌐 [BrandRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw BrandException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [BrandRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw BrandException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<BrandModel> addBrand({required String userId, required String name}) async {
    try {
      debugPrint('🚀 [BrandRepository] Adding new brand');
      debugPrint('   📍 URL: ${ApiEndpoints.addbrandsListUrl}');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   📝 Brand Name: $name');

      final payload = {"userId": userId, "name": name};

      dio.Response response = await BaseClient.post(url: ApiEndpoints.addbrandsListUrl, payload: payload);

      debugPrint('✅ [BrandRepository] Add brand response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getBrandsList(userId: userId);
        return BrandModel.fromJson(response.data);
      } else {
        throw BrandException(message: 'Failed to add brand: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      debugPrint('🌐 [BrandRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw BrandException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [BrandRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw BrandException(message: 'Unexpected error: $e');
    }
  }
}

class BrandException implements Exception {
  final String message;
  final int? statusCode;

  BrandException({required this.message, this.statusCode});

  @override
  String toString() => 'BrandException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
