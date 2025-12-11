// features/jobBooking/repositories/job_item_repository.dart
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/job_item_model.dart';

abstract class JobItemRepository {
  Future<JobItemsModel> getItems({required String userId, String? keyword, int page = 1, int limit = 20});

  Future<JobItemsModel> searchItems({required String userId, required String keyword, int page = 1, int limit = 20});
}

class JobItemRepositoryImpl implements JobItemRepository {
  @override
  Future<JobItemsModel> getItems({required String userId, String? keyword, int page = 1, int limit = 20}) async {
    try {
      debugPrint('🚀 [JobItemRepository] Fetching items list');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   🔍 Keyword: ${keyword ?? "none"}');
      debugPrint('   📄 Page: $page');
      debugPrint('   📏 Limit: $limit');

      final Map<String, dynamic> queryParams = {'page': page.toString(), 'limit': limit.toString()};

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['productName'] = keyword;
      }

      final String url = ApiEndpoints.itemsListUrl.replaceAll('<id>', userId);
      debugPrint('   📍 URL: $url');
      debugPrint('   📋 Query Params: $queryParams');

      Response response = await BaseClient.get(url: url, payload: queryParams);

      debugPrint('✅ [JobItemRepository] Items response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint('   🔄 Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data as String);
        }

        final itemsModel = JobItemsModel.fromJson(jsonData);

        if (itemsModel.items != null) {
          debugPrint('   📦 Parsed ${itemsModel.items!.length} items');
          debugPrint('   📊 Total Items: ${itemsModel.totalItems}');
          debugPrint('   📑 Total Pages: ${itemsModel.pages}');

          // Log first few items for debugging
          if (itemsModel.items!.isNotEmpty) {
            for (int i = 0; i < (itemsModel.items!.length > 3 ? 3 : itemsModel.items!.length); i++) {
              final item = itemsModel.items![i];
              debugPrint('     ${i + 1}. ${item.productName} (${item.itemNumber}) - ${item.salePriceIncVat}€');
            }
            if (itemsModel.items!.length > 3) {
              debugPrint('     ... and ${itemsModel.items!.length - 3} more');
            }
          }

          return itemsModel;
        } else {
          debugPrint('   ⚠️ No items found in response');
          return JobItemsModel(items: [], totalItems: 0, pages: 0);
        }
      } else {
        throw JobItemException(
          message: 'Failed to load items: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [JobItemRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      debugPrint('   📊 Status Code: ${e.response?.statusCode}');

      throw JobItemException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [JobItemRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw JobItemException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<JobItemsModel> searchItems({
    required String userId,
    required String keyword,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 [JobItemRepository] Searching items with keyword: "$keyword"');

      if (keyword.isEmpty) {
        debugPrint('   ℹ️ Empty keyword, returning empty results');
        return JobItemsModel(items: [], totalItems: 0, pages: 0);
      }

      return await getItems(userId: userId, keyword: keyword, page: page, limit: limit);
    } catch (e) {
      debugPrint('💥 [JobItemRepository] Search error: $e');
      rethrow;
    }
  }
}

class JobItemException implements Exception {
  final String message;
  final int? statusCode;

  JobItemException({required this.message, this.statusCode});

  @override
  String toString() => 'JobItemException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
