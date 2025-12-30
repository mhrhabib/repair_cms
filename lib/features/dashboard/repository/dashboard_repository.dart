import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/dashboard/models/completed_jobs_response_model.dart';

class DashboardRepository {
  Future<CompletedJobsResponseModel> getCompletedJobs({String? userId, String? startDate, String? endDate}) async {
    try {
      final Map<String, dynamic> queryParams = {};

      // Add date parameters if provided
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      debugPrint('\n📊 Fetching completed jobs with params:');
      debugPrint('📍 Start Date: $startDate');
      debugPrint('📍 End Date: $endDate');
      debugPrint('📍 User ID: $userId');

      dio.Response response = await BaseClient.get(
        url: ApiEndpoints.completeUserJob.replaceAll('<id>', userId ?? ''),
        payload: queryParams,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Completed jobs fetched successfully');
        debugPrint('📈 Response data: ${response.data}');

        // Parse JSON string to Map if needed
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

        return CompletedJobsResponseModel.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch completed jobs: ${response.statusCode} - ${response.data}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ Dio Error in completed jobs: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in dashboard stats: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // Utility method to format dates for API
  String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // Utility method to get date range for today
  Map<String, String> getTodayDateRange() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return {'startDate': formatDateForApi(startOfDay), 'endDate': formatDateForApi(endOfDay)};
  }

  // Utility method to get date range for this month
  Map<String, String> getThisMonthDateRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    return {'startDate': formatDateForApi(startOfMonth), 'endDate': formatDateForApi(endOfMonth)};
  }

  Future<CompletedJobsResponseModel> getJobProgress({String? userId}) async {
    try {
      debugPrint('\n📈 Fetching job progress data');

      dio.Response response = await BaseClient.get(url: ApiEndpoints.completeUserJob.replaceAll('<id>', userId ?? ''));

      if (response.statusCode == 200) {
        // Normalize response data: if backend sent a JSON string, decode it.
        final dynamic responseData = response.data is String ? jsonDecode(response.data) : response.data;

        debugPrint('✅ Job progress data fetched successfully');
        debugPrint('📊 response.data type: ${response.data.runtimeType}');
        debugPrint('📊 parsed responseData type: ${responseData.runtimeType}');
        debugPrint('📊 Job Progress Response: ${jsonEncode(responseData)}');

        // Map to model
        return CompletedJobsResponseModel.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch job progress: ${response.statusCode} - ${response.data}');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ Dio Error in job progress: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in job progress: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }
}
