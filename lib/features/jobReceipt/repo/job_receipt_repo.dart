import 'package:flutter/foundation.dart';
import '../../../core/base/base_client.dart';
import '../../../core/helpers/api_endpoints.dart';
import '../models/job_receipt_model.dart';

// Custom exception for job receipt errors
class JobReceiptException implements Exception {
  final String message;
  final int? statusCode;

  JobReceiptException({required this.message, this.statusCode});

  @override
  String toString() => 'JobReceiptException: $message';
}

// Abstract repository interface
abstract class JobReceiptRepository {
  Future<JobReceiptModel> getJobReceipt({required String userId});
}

// Repository implementation
class JobReceiptRepositoryImpl implements JobReceiptRepository {
  @override
  Future<JobReceiptModel> getJobReceipt({required String userId}) async {
    debugPrint('🚀 [JobReceiptRepository] Fetching job receipt');
    debugPrint('👤 [JobReceiptRepository] User ID: $userId');

    try {
      final url = '${ApiEndpoints.baseUrl}/job-receipt/user/$userId';

      debugPrint('🌐 [JobReceiptRepository] Request URL: $url');

      final response = await BaseClient.get(url: url);

      debugPrint('📊 [JobReceiptRepository] Response status: ${response.statusCode}');
      debugPrint('📊 [JobReceiptRepository] Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        debugPrint('✅ [JobReceiptRepository] Job receipt fetched successfully');

        if (response.data is Map<String, dynamic>) {
          final receipt = JobReceiptModel.fromJson(response.data as Map<String, dynamic>);
          debugPrint('📦 [JobReceiptRepository] Receipt ID: ${receipt.sId}');
          debugPrint('📋 [JobReceiptRepository] QR Code Enabled: ${receipt.qrCodeEnabled}');
          return receipt;
        } else {
          debugPrint('⚠️ [JobReceiptRepository] Unexpected response format');
          throw JobReceiptException(
            message: 'Unexpected response format. Expected Map but got ${response.data.runtimeType}',
            statusCode: response.statusCode,
          );
        }
      } else {
        debugPrint('❌ [JobReceiptRepository] Request failed with status: ${response.statusCode}');
        throw JobReceiptException(
          message: 'Failed to fetch job receipt. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on JobReceiptException {
      rethrow;
    } catch (e) {
      debugPrint('💥 [JobReceiptRepository] Unexpected error: $e');
      throw JobReceiptException(message: 'Failed to fetch job receipt: ${e.toString()}');
    }
  }
}
