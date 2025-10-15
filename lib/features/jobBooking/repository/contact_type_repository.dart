import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';

abstract class ContactTypeRepository {
  Future<List<Customersorsuppliers>> getBusinessList({required String userId, String? keyword, int? limit, int? page});
  Future<Customersorsuppliers> createBusiness({required Map<String, dynamic> payload});
}

class ContactTypeRepositoryImpl implements ContactTypeRepository {
  @override
  Future<List<Customersorsuppliers>> getBusinessList({
    required String userId,
    String? keyword,
    int? limit = 20,
    int? page = 1,
  }) async {
    try {
      debugPrint('🚀 [ContactTypeRepository] Fetching business list');

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'limit': limit?.toString(),
        'page': page?.toString(),
        'type2': '["business"]', // Filter for business type
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      final String url = ApiEndpoints.businessListUrl.replaceAll('<id>', userId);
      debugPrint('   📍 URL: $url');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   🔍 Query Params: $queryParams');

      Response response = await BaseClient.get(url: url, payload: queryParams);

      debugPrint('✅ [ContactTypeRepository] Business response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final businessModel = BusinessModel.fromJson(response.data);

        if (businessModel.customersorsuppliers != null) {
          debugPrint('   📦 Parsed ${businessModel.customersorsuppliers!.length} businesses');
          return businessModel.customersorsuppliers!;
        } else {
          debugPrint('   ⚠️ No businesses found');
          return [];
        }
      } else {
        throw ContactTypeException(
          message: 'Failed to load businesses: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [ContactTypeRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw ContactTypeException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [ContactTypeRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw ContactTypeException(message: 'Unexpected error: $e');
    }
  }

  // In your contact_type_repository.dart, update the createBusiness method
  @override
  Future<Customersorsuppliers> createBusiness({required Map<String, dynamic> payload}) async {
    try {
      debugPrint('🚀 [ContactTypeRepository] Creating new business');
      debugPrint('   📦 Payload: $payload');

      Response response = await BaseClient.post(url: ApiEndpoints.createBusiness, payload: payload);

      debugPrint('✅ [ContactTypeRepository] Create business response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdBusiness = Customersorsuppliers.fromJson(response.data);
        debugPrint('   🎉 Business created successfully with ID: ${createdBusiness.sId}');
        return createdBusiness;
      } else {
        throw ContactTypeException(
          message: 'Failed to create business: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [ContactTypeRepository] DioException during business creation:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw ContactTypeException(
        message: 'Network error while creating business: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [ContactTypeRepository] Unexpected error during business creation:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw ContactTypeException(message: 'Unexpected error while creating business: $e');
    }
  }
}

class ContactTypeException implements Exception {
  final String message;
  final int? statusCode;

  ContactTypeException({required this.message, this.statusCode});

  @override
  String toString() => 'ContactTypeException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
