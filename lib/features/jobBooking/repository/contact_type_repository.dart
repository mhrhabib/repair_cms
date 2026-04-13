import 'package:dio/dio.dart' as dio;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';

abstract class ContactTypeRepository {
  Future<List<Customersorsuppliers>> getProfileList({
    required String userId,
    required String type2, // Added to specify "business" or "personal"
    String? keyword,
    int? limit,
    int? page,
  });

  Future<Customersorsuppliers> createBusiness({required Map<String, dynamic> payload});

  Future<Customersorsuppliers> updateBusiness({required String profileId, required Map<String, dynamic> payload});

  Future<bool> updateShippingAddress({required String profileId, required List<Map<String, dynamic>> payload});

  Future<bool> updateBillingAddress({required String profileId, required List<Map<String, dynamic>> payload});
}

class ContactTypeRepositoryImpl implements ContactTypeRepository {
  @override
  Future<List<Customersorsuppliers>> getProfileList({
    required String userId,
    required String type2, // Added
    String? keyword,
    int? limit = 20,
    int? page = 1,
  }) async {
    try {
      debugPrint('🚀 [ContactTypeRepository] Fetching profile list for type: $type2');

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'limit': limit?.toString(),
        'page': page?.toString(),
        'type2': '["$type2"]', // Use the type2 parameter to filter
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      final String url = ApiEndpoints.businessListUrl.replaceAll('<id>', userId);
      debugPrint('   📍 URL: $url');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   🔍 Query Params: $queryParams');

      dio.Response response = await BaseClient.get(url: url, payload: queryParams);

      debugPrint('✅ [ContactTypeRepository] Profile response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint('   🔄 Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data as String);
        }

        final businessModel = BusinessModel.fromJson(jsonData);

        if (businessModel.customersorsuppliers != null) {
          debugPrint('   📦 Parsed ${businessModel.customersorsuppliers!.length} profiles');
          return businessModel.customersorsuppliers!;
        } else {
          debugPrint('   ⚠️ No profiles found');
          return [];
        }
      } else {
        throw ContactTypeException(
          message: 'Failed to load profiles: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('🌐 [ContactTypeRepository] DioException: ${e.message}');
      throw ContactTypeException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [ContactTypeRepository] Unexpected error: $e\n$stackTrace');
      throw ContactTypeException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<Customersorsuppliers> createBusiness({required Map<String, dynamic> payload}) async {
    try {
      debugPrint('🚀 [ContactTypeRepository] Creating new profile');
      debugPrint('   📦 Payload: $payload');

      dio.Response response = await BaseClient.post(url: ApiEndpoints.createBusiness, payload: payload);

      debugPrint('✅ [ContactTypeRepository] Create profile response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📄 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint('   🔄 Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data as String);
        }

        // Handle different response structures
        Map<String, dynamic> responseData = jsonData;

        // Check if response has 'customer' or 'customerorsupplier' array
        if (responseData.containsKey('customer')) {
          final createdBusiness = Customersorsuppliers.fromJson(responseData['customer']);
          debugPrint('   🎉 Profile created successfully with ID: ${createdBusiness.sId}');
          return createdBusiness;
        } else if (responseData.containsKey('customerorsupplier') &&
            responseData['customerorsupplier'] is List &&
            responseData['customerorsupplier'].isNotEmpty) {
          // Handle array response structure
          final createdBusiness = Customersorsuppliers.fromJson(responseData['customerorsupplier'][0]);
          debugPrint('   🎉 Profile created successfully with ID: ${createdBusiness.sId}');
          return createdBusiness;
        } else {
          debugPrint('   ⚠️ Unexpected response structure: $responseData');
          throw ContactTypeException(
            message: 'Unexpected response structure from server',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ContactTypeException(
          message: 'Failed to create profile: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('🌐 [ContactTypeRepository] DioException during profile creation: ${e.message}');
      throw ContactTypeException(
        message: 'Network error while creating profile: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [ContactTypeRepository] Unexpected error during profile creation: $e\n$stackTrace');
      throw ContactTypeException(message: 'Unexpected error while creating profile: $e');
    }
  }

  @override
  Future<Customersorsuppliers> updateBusiness({
    required String profileId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      debugPrint('🚀 [ContactTypeRepository] Updating profile with ID: $profileId');
      debugPrint('   📦 Payload: $payload');

      // Construct the update URL
      final String url = ApiEndpoints.updateBusiness.replaceAll('<id>', profileId);
      debugPrint('   📍 URL: $url');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      debugPrint('✅ [ContactTypeRepository] Update profile response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📄 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint('   🔄 Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data as String);
        }

        // Handle different response structures
        Map<String, dynamic> responseData = jsonData;

        // Check if response has 'customer' or 'customerorsupplier' array
        if (responseData['success'] == true) {
          final updatedBusiness = Customersorsuppliers.fromJson(responseData);
          debugPrint('   🎉 Profile updated successfully with ID: ${updatedBusiness.sId}');
          return updatedBusiness;
        } else if (responseData.containsKey('customerorsupplier') &&
            responseData['customerorsupplier'] is List &&
            responseData['customerorsupplier'].isNotEmpty) {
          // Handle array response structure
          final updatedBusiness = Customersorsuppliers.fromJson(responseData['customerorsupplier'][0]);
          debugPrint('   🎉 Profile updated successfully with ID: ${updatedBusiness.sId}');
          return updatedBusiness;
        } else {
          debugPrint('   ⚠️ Unexpected response structure: $responseData');
          throw ContactTypeException(
            message: 'Unexpected response structure from server',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ContactTypeException(
          message: 'Failed to update profile: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('🌐 [ContactTypeRepository] DioException during profile update: ${e.message}');
      throw ContactTypeException(
        message: 'Network error while updating profile: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [ContactTypeRepository] Unexpected error during profile update: $e\n$stackTrace');
      throw ContactTypeException(message: 'Unexpected error while updating profile: $e');
    }
  }

  @override
  Future<bool> updateShippingAddress({
    required String profileId,
    required List<Map<String, dynamic>> payload,
  }) async {
    try {
      debugPrint('🚀 [ContactTypeRepository] Updating shipping address for customer: $profileId');
      final String url = ApiEndpoints.updateShippingAddress.replaceAll('<id>', profileId);
      final response = await BaseClient.patch(url: url, payload: payload);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [ContactTypeRepository] Shipping address updated successfully');
        return true;
      }
      throw ContactTypeException(message: 'Failed to update shipping address', statusCode: response.statusCode);
    } catch (e) {
      debugPrint('💥 [ContactTypeRepository] Error updating shipping address: $e');
      throw ContactTypeException(message: 'Update shipping address error: $e');
    }
  }

  @override
  Future<bool> updateBillingAddress({
    required String profileId,
    required List<Map<String, dynamic>> payload,
  }) async {
    try {
      debugPrint('🚀 [ContactTypeRepository] Updating billing address for customer: $profileId');
      final String url = ApiEndpoints.updateBillingAddress.replaceAll('<id>', profileId);
      final response = await BaseClient.patch(url: url, payload: payload);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [ContactTypeRepository] Billing address updated successfully');
        return true;
      }
      throw ContactTypeException(message: 'Failed to update billing address', statusCode: response.statusCode);
    } catch (e) {
      debugPrint('💥 [ContactTypeRepository] Error updating billing address: $e');
      throw ContactTypeException(message: 'Update billing address error: $e');
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
