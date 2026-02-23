import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/dashboard/models/completed_jobs_response_model.dart';

// Custom exception for dashboard errors
class DashboardException implements Exception {
  final String message;
  final int? statusCode;

  DashboardException({required this.message, this.statusCode});

  @override
  String toString() => 'DashboardException: $message';
}

class DashboardRepository {
  // Timeout duration for API calls (30 seconds)
  static const Duration apiTimeout = Duration(seconds: 30);

  Future<CompletedJobsResponseModel> getCompletedJobs({
    String? userId,
    String? startDate,
    String? endDate,
  }) async {
    debugPrint(
      '\n📊 [DashboardRepository] Fetching completed jobs with params:',
    );
    debugPrint('📍 [DashboardRepository] Start Date: $startDate');
    debugPrint('📍 [DashboardRepository] End Date: $endDate');
    debugPrint('📍 [DashboardRepository] User ID: $userId');

    try {
      if (userId == null || userId.isEmpty) {
        throw DashboardException(message: 'User ID is required');
      }

      final Map<String, dynamic> queryParams = {};

      // Add date parameters if provided
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      final url = ApiEndpoints.completeUserJob.replaceAll('<id>', userId);
      debugPrint('🌐 [DashboardRepository] Request URL: $url');

      // Wrap API call with timeout protection
      final response = await BaseClient.get(
        url: url,
        payload: queryParams,
      ).timeout(
        apiTimeout,
        onTimeout: () {
          debugPrint('⏱️ [DashboardRepository] API call timeout - completed jobs');
          throw DashboardException(
            message: 'Request timed out. Please check your connection and try again.',
          );
        },
      );

      debugPrint(
        '📊 [DashboardRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint(
          '✅ [DashboardRepository] Completed jobs fetched successfully',
        );

        // Parse JSON string to Map if needed
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        if (responseData is! Map<String, dynamic>) {
          throw DashboardException(
            message:
                'Unexpected response format. Expected Map but got ${responseData.runtimeType}',
            statusCode: response.statusCode,
          );
        }

        return CompletedJobsResponseModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw DashboardException(
          message: 'Unauthorized - Please login again',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw DashboardException(
          message: 'Data not found',
          statusCode: response.statusCode,
        );
      } else {
        debugPrint(
          '❌ [DashboardRepository] Request failed with status: ${response.statusCode}',
        );
        throw DashboardException(
          message: 'Failed to fetch completed jobs (Error: ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on DashboardException {
      rethrow;
    } on dio.DioException catch (e) {
      debugPrint('❌ [DashboardRepository] Dio Error: ${e.message}');
      if (e.response != null) {
        throw DashboardException(
          message: 'Server error: ${e.response?.data ?? e.message}',
          statusCode: e.response?.statusCode,
        );
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        throw DashboardException(
          message: 'Connection timeout - please check your internet connection',
        );
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        throw DashboardException(
          message: 'Server is taking too long to respond',
        );
      } else {
        throw DashboardException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint(
        '💥 [DashboardRepository] Unexpected error in completed jobs: $e',
      );
      debugPrint('📋 [DashboardRepository] Stack trace: $stackTrace');
      throw DashboardException(
        message: 'Failed to fetch completed jobs: ${e.toString()}',
      );
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

    return {
      'startDate': formatDateForApi(startOfDay),
      'endDate': formatDateForApi(endOfDay),
    };
  }

  // Utility method to get date range for this month
  Map<String, String> getThisMonthDateRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    return {
      'startDate': formatDateForApi(startOfMonth),
      'endDate': formatDateForApi(endOfMonth),
    };
  }

  Future<CompletedJobsResponseModel> getJobProgress({String? userId}) async {
    debugPrint('\n📈 [DashboardRepository] Fetching job progress data');
    debugPrint('👤 [DashboardRepository] User ID: $userId');

    try {
      if (userId == null || userId.isEmpty) {
        throw DashboardException(message: 'User ID is required');
      }

      final url = ApiEndpoints.completeUserJob.replaceAll('<id>', userId);
      debugPrint('🌐 [DashboardRepository] Request URL: $url');

      // Wrap API call with timeout protection
      final response = await BaseClient.get(url: url).timeout(
        apiTimeout,
        onTimeout: () {
          debugPrint('⏱️ [DashboardRepository] API call timeout - job progress');
          throw DashboardException(
            message: 'Request timed out. Please check your connection and try again.',
          );
        },
      );

      debugPrint(
        '📊 [DashboardRepository] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Normalize response data: if backend sent a JSON string, decode it.
        final dynamic responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        debugPrint(
          '✅ [DashboardRepository] Job progress data fetched successfully',
        );
        debugPrint(
          '📊 [DashboardRepository] Response data type: ${responseData.runtimeType}',
        );

        if (responseData is! Map<String, dynamic>) {
          throw DashboardException(
            message:
                'Unexpected response format. Expected Map but got ${responseData.runtimeType}',
            statusCode: response.statusCode,
          );
        }

        return CompletedJobsResponseModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw DashboardException(
          message: 'Unauthorized - Please login again',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw DashboardException(
          message: 'Data not found',
          statusCode: response.statusCode,
        );
      } else {
        debugPrint(
          '❌ [DashboardRepository] Request failed with status: ${response.statusCode}',
        );
        throw DashboardException(
          message: 'Failed to fetch job progress (Error: ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on DashboardException {
      rethrow;
    } on dio.DioException catch (e) {
      debugPrint('❌ [DashboardRepository] Dio Error: ${e.message}');
      if (e.response != null) {
        throw DashboardException(
          message: 'Server error: ${e.response?.data ?? e.message}',
          statusCode: e.response?.statusCode,
        );
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        throw DashboardException(
          message: 'Connection timeout - please check your internet connection',
        );
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        throw DashboardException(
          message: 'Server is taking too long to respond',
        );
      } else {
        throw DashboardException(message: 'Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint(
        '💥 [DashboardRepository] Unexpected error in job progress: $e',
      );
      debugPrint('📋 [DashboardRepository] Stack trace: $stackTrace');
      throw DashboardException(
        message: 'Failed to fetch job progress: ${e.toString()}',
      );
    }
  }
}
