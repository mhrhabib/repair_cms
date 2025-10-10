import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';

abstract class JobBookingRepository {
  Future<CreateJobResponse> createJob({required CreateJobRequest request});
}

class JobBookingRepositoryImpl implements JobBookingRepository {
  @override
  Future<CreateJobResponse> createJob({required CreateJobRequest request}) async {
    try {
      print('🚀 [JobRepository] Creating job with data:');
      print('   📍 URL: ${ApiEndpoints.createJob}');
      print('   📦 Request payload: ${request.toJson()}');

      final response = await BaseClient.post(url: ApiEndpoints.createJob, payload: request.toJson());

      print('✅ [JobRepository] Job creation response:');
      print('   📊 Status Code: ${response.statusCode}');
      print('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateJobResponse.fromJson(response.data);
      } else {
        throw JobException(message: 'Failed to create job: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on dio.DioException catch (e) {
      print('🌐 [JobRepository] DioException:');
      print('   💥 Error: ${e.message}');
      print('   📍 Type: ${e.type}');
      print('   🔧 Response: ${e.response?.data}');
      throw JobException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      print('💥 [JobRepository] Unexpected error:');
      print('   💥 Error: $e');
      print('   📋 Stack: $stackTrace');
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
