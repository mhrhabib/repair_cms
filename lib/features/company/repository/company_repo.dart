import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/base/base_client.dart';
import '../../../core/helpers/api_endpoints.dart';
import '../models/company_model.dart';

// Custom exception for company errors
class CompanyException implements Exception {
  final String message;
  final int? statusCode;

  CompanyException({required this.message, this.statusCode});

  @override
  String toString() => 'CompanyException: $message';
}

// Abstract repository interface
abstract class CompanyRepository {
  Future<CompanyModel> getCompanyInfo({required String companyId});
}

// Repository implementation
class CompanyRepositoryImpl implements CompanyRepository {
  @override
  Future<CompanyModel> getCompanyInfo({required String companyId}) async {
    debugPrint('🚀 [CompanyRepository] Fetching company info');
    debugPrint('🏢 [CompanyRepository] Company ID: $companyId');

    try {
      final url = '${ApiEndpoints.baseUrl}/company/$companyId';

      debugPrint('🌐 [CompanyRepository] Request URL: $url');

      final response = await BaseClient.get(url: url);

      debugPrint('📊 [CompanyRepository] Response status: ${response.statusCode}');
      debugPrint('📊 [CompanyRepository] Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        debugPrint('✅ [CompanyRepository] Company info fetched successfully');

        // Parse JSON string to Map if needed
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

        if (responseData is Map<String, dynamic>) {
          final company = CompanyModel.fromJson(responseData);
          debugPrint('📦 [CompanyRepository] Company: ${company.companyName}');
          debugPrint('📧 [CompanyRepository] Email: ${company.companyEmail}');
          return company;
        } else {
          debugPrint('⚠️ [CompanyRepository] Unexpected response format');
          throw CompanyException(
            message: 'Unexpected response format. Expected Map but got ${responseData.runtimeType}',
            statusCode: response.statusCode,
          );
        }
      } else {
        debugPrint('❌ [CompanyRepository] Request failed with status: ${response.statusCode}');
        throw CompanyException(
          message: 'Failed to fetch company info. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on CompanyException {
      rethrow;
    } catch (e) {
      debugPrint('💥 [CompanyRepository] Unexpected error: $e');
      throw CompanyException(message: 'Failed to fetch company info: ${e.toString()}');
    }
  }
}
