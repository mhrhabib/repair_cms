import 'package:dio/dio.dart' as dio;
import 'package:flutter/rendering.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';

abstract class JobBookingRepository {
  Future<CreateJobResponse> createJob({required CreateJobRequest request});
  Future<CreateJobResponse> updateJob({required CreateJobRequest request, required String jobId});
}

class JobBookingRepositoryImpl implements JobBookingRepository {
  @override
  Future<CreateJobResponse> createJob({required CreateJobRequest request}) async {
    try {
      debugPrint('🚀 [JobRepository] Creating job with data:');
      debugPrint('   📍 URL: ${ApiEndpoints.createJob}');
      debugPrint('   📦 Request payload: ${request.toJson()}');

      dio.Response response = await BaseClient.post(url: ApiEndpoints.createJob, payload: request.toJson());

      debugPrint('✅ [JobRepository] Job creation response:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateJobResponse.fromJson(response.data);
      } else {
        throw JobException(message: 'Failed to create job: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on dio.DioException catch (e) {
      debugPrint('🌐 [JobRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw JobException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [JobRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw JobException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<CreateJobResponse> updateJob({required CreateJobRequest request, required String jobId}) async {
    try {
      debugPrint('🚀 [JobRepository] Updating job with data:');
      debugPrint('   📍 URL: ${ApiEndpoints.getJobById.replaceAll('<id>', jobId)}');

      final payload = request.toJson();
      debugPrint('   📦 Request payload keys: ${payload.keys.toList()}');

      // Log receipt footer specifically
      if (payload.containsKey('receiptFooter')) {
        final receiptFooter = payload['receiptFooter'];
        debugPrint('   📋 Receipt Footer in Payload:');
        debugPrint('      - Logo URL: ${receiptFooter['companyLogoURL']}');
        debugPrint('      - Address: ${receiptFooter['address']}');
        debugPrint('      - Contact: ${receiptFooter['contact']}');
        debugPrint('      - Bank: ${receiptFooter['bank']}');
      } else {
        debugPrint('   ⚠️ NO receiptFooter in payload!');
      }

      dio.Response response = await BaseClient.patch(
        url: ApiEndpoints.getJobById.replaceAll('<id>', jobId),
        payload: payload,
      );

      debugPrint('✅ [JobRepository] Job update response:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle successful update if needed
        return CreateJobResponse.fromJson(response.data);
      } else {
        throw JobException(message: 'Failed to update job: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on dio.DioException catch (e) {
      debugPrint('🌐 [JobRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw JobException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [JobRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw JobException(message: 'Unexpected error: $e');
    }
  }
}

class JobException implements Exception {
  final String message;
  final int? statusCode;

  JobException({required this.message, this.statusCode});

  @override
  String toString() => 'JobException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
