import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
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
      print('🚀 [BrandRepository] Fetching brands list');
      print('   📍 URL: ${ApiEndpoints.brandsListUrl.replaceAll('<id>', userId)}');
      print('   👤 User ID: $userId');

      dio.Response response = await BaseClient.get(url: ApiEndpoints.brandsListUrl.replaceAll('<id>', userId));

      print('✅ [BrandRepository] Brands response received:');
      print('   📊 Status Code: ${response.statusCode}');
      print('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final brands = (response.data as List).map((brandJson) => BrandModel.fromJson(brandJson)).toList();
          print('   📦 Parsed ${brands.length} brands');
          return brands;
        } else if (response.data is Map) {
          final data = response.data as Map;
          if (data.containsKey('brands') && data['brands'] is List) {
            final brands = (data['brands'] as List).map((brandJson) => BrandModel.fromJson(brandJson)).toList();
            print('   📦 Parsed ${brands.length} brands from "brands" key');
            return brands;
          } else if (data.containsKey('data') && data['data'] is List) {
            final brands = (data['data'] as List).map((brandJson) => BrandModel.fromJson(brandJson)).toList();
            print('   📦 Parsed ${brands.length} brands from "data" key');
            return brands;
          }
        }

        print('   ⚠️ Unexpected response format: ${response.data}');
        throw BrandException(message: 'Unexpected response format from server');
      } else {
        throw BrandException(message: 'Failed to load brands: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      print('🌐 [BrandRepository] DioException:');
      print('   💥 Error: ${e.message}');
      print('   📍 Type: ${e.type}');
      print('   🔧 Response: ${e.response?.data}');
      throw BrandException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      print('💥 [BrandRepository] Unexpected error:');
      print('   💥 Error: $e');
      print('   📋 Stack: $stackTrace');
      throw BrandException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<BrandModel> addBrand({required String userId, required String name}) async {
    try {
      print('🚀 [BrandRepository] Adding new brand');
      print('   📍 URL: ${ApiEndpoints.addbrandsListUrl}');
      print('   👤 User ID: $userId');
      print('   📝 Brand Name: $name');

      final payload = {"userId": userId, "name": name};

      dio.Response response = await BaseClient.post(url: ApiEndpoints.addbrandsListUrl, payload: payload);

      print('✅ [BrandRepository] Add brand response received:');
      print('   📊 Status Code: ${response.statusCode}');
      print('   📊 Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response formats
        if (response.data is Map) {
          final data = response.data as Map;

          // Check for nested brand data
          if (data.containsKey('brand')) {
            return BrandModel.fromJson(data['brand']);
          } else if (data.containsKey('data')) {
            return BrandModel.fromJson(data['data']);
          } else {
            // Assume the response itself is the brand
            //return BrandModel.fromJson(data);
          }
        }

        throw BrandException(message: 'Unexpected response format from server');
      } else {
        throw BrandException(message: 'Failed to add brand: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      print('🌐 [BrandRepository] DioException:');
      print('   💥 Error: ${e.message}');
      print('   📍 Type: ${e.type}');
      print('   🔧 Response: ${e.response?.data}');
      throw BrandException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      print('💥 [BrandRepository] Unexpected error:');
      print('   💥 Error: $e');
      print('   📋 Stack: $stackTrace');
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
