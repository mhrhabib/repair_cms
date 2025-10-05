// repositories/job_repository.dart
import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';

class JobRepository {
  Future<JobListResponse> getJobs({
    String? keyword,
    String? startDate,
    String? endDate,
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'pageSize': pageSize};

      // Add optional parameters if provided
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      dio.Response response = await BaseClient.get(url: ApiEndpoints.getAllJobs, payload: queryParams);
      final responseData = response.data;

      if (response.statusCode == 200) {
        debugPrint('✅ API Response data type: ${responseData.runtimeType}');
        debugPrint('✅ API Response data: $responseData');

        // 🔍 DEBUG: Print field types before parsing
        _debugResponseFields(responseData);

        return JobListResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch jobs: ${response.statusCode} - $responseData');
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // 🔍 NEW: Method to debug field types in API response
  void _debugResponseFields(Map<String, dynamic> responseData) {
    debugPrint('\n🔍 DEBUG - API RESPONSE FIELD ANALYSIS:');
    debugPrint('📊 Top-level fields:');
    responseData.forEach((key, value) {
      debugPrint('   📍 $key: $value (type: ${value.runtimeType})');
    });

    // Debug the first job result in detail
    if (responseData['results'] != null && responseData['results'] is List && responseData['results'].isNotEmpty) {
      debugPrint('\n🔍 DEBUG - FIRST JOB OBJECT FIELD TYPES:');
      final firstJob = responseData['results'][0];

      if (firstJob is Map<String, dynamic>) {
        firstJob.forEach((key, value) {
          final valueType = value.runtimeType;
          final valuePreview = value.toString().length > 50
              ? '${value.toString().substring(0, 50)}...'
              : value.toString();

          debugPrint('   🎯 $key: $valuePreview (type: $valueType)');

          // Special handling for nested objects
          if (value is Map) {
            debugPrint('      📂 Nested Map with keys: ${value.keys}');
          } else if (value is List) {
            debugPrint('      📋 List length: ${value.length}');
            if (value.isNotEmpty) {
              debugPrint('      👀 First item type: ${value[0].runtimeType}');
            }
          }
        });
      }
    }
  }

  Future<Job> getJobById(String jobId) async {
    try {
      final url = '${ApiEndpoints.getAllJobs}/$jobId';
      final response = await BaseClient.get(url: url);
      final responseData = response.data;

      if (response.statusCode == 200) {
        debugPrint('🔍 DEBUG - Single Job Response:');
        _debugSingleJobFields(responseData);

        return Job.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch job: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getJobById: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // 🔍 NEW: Method to debug single job fields
  void _debugSingleJobFields(Map<String, dynamic> jobData) {
    debugPrint('\n🔍 DEBUG - SINGLE JOB FIELD TYPES:');
    jobData.forEach((key, value) {
      final valueType = value.runtimeType;
      final valuePreview = value.toString().length > 100
          ? '${value.toString().substring(0, 100)}...'
          : value.toString();

      debugPrint('   🎯 $key: $valuePreview');
      debugPrint('      📝 TYPE: $valueType');

      // Highlight potential type issues
      if (_isPotentialTypeIssue(key, value)) {
        debugPrint('      ⚠️  POTENTIAL TYPE ISSUE - Check model definition!');
      }
    });
  }

  // 🔍 NEW: Identify potential type issues
  bool _isPotentialTypeIssue(String key, dynamic value) {
    // Common numeric fields that might be sent as int but expected as String
    final numericFields = ['subTotal', 'total', 'vat', 'discount', 'price', 'amount'];

    if (numericFields.contains(key) && value is int) {
      debugPrint('      💡 SUGGESTION: API sends $key as int, ensure model handles numeric types');
      return true;
    }

    // ID fields that should be strings
    if (key.contains('Id') || key.contains('_id')) {
      if (value is! String && value != null) {
        debugPrint('      💡 SUGGESTION: $key is ${value.runtimeType}, but should be String?');
        return true;
      }
    }

    return false;
  }

  Future<Job> updateJobStatus(String jobId, String status, String notes) async {
    try {
      final url = '${ApiEndpoints.getAllJobs}/$jobId/status';
      final response = await BaseClient.put(url: url, payload: {'status': status, 'notes': notes});
      final responseData = response.data;

      if (response.statusCode == 200) {
        return Job.fromJson(responseData);
      } else {
        throw Exception('Failed to update job status: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateJobStatus: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // 🔍 NEW: Utility method to test field parsing
  void testFieldParsing(Map<String, dynamic> json, String fieldName) {
    try {
      final value = json[fieldName];
      debugPrint('🧪 Testing $fieldName: $value (type: ${value.runtimeType})');

      // Try different parsing approaches
      if (value != null) {
        debugPrint('   as String: ${value.toString()}');
        if (value is num) {
          debugPrint('   as double: ${value.toDouble()}');
          debugPrint('   as int: ${value.toInt()}');
        }
      }
    } catch (e) {
      debugPrint('   ❌ Error parsing $fieldName: $e');
    }
  }
}
