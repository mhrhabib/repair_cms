// repositories/job_repository.dart
import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/core/services/email_service.dart';
import 'package:repair_cms/features/myJobs/models/assign_user_list_model.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';

class JobRepository {
  Future<JobListResponse> getJobs({
    String? keyword,
    String? startDate,
    String? endDate,
    int page = 1,
    int pageSize = 20,
    String? status,
    String? userID,
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

      dio.Response response = await BaseClient.get(
        url: '${ApiEndpoints.getAllJobs}/user/$userID',
        payload: queryParams,
      );
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

  Future<SingleJobModel> getJobById(String jobId) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);
      dio.Response response = await BaseClient.get(url: url);
      final responseData = response.data;

      if (response.statusCode == 200) {
        debugPrint('🔍 DEBUG - Single Job Response:');
        _debugSingleJobFields(responseData);

        return SingleJobModel.fromJson(responseData);
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

  Future<SingleJobModel> updateJobCompletionStatus(
    String jobId,
    bool isJobCompleted,
    String userId,
    String userName,
    String email, {
    String? customNotes,
    bool sendNotification = true,
    required SingleJobModel currentJob, // Add current job for email data
  }) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      // Define status configuration based on completion
      final Map<String, dynamic> statusConfig = isJobCompleted
          ? {
              'title': 'ready_to_return',
              'colorCode': '#008444',
              'defaultNotes': 'Device is ready to return',
              'priority': 2,
            }
          : {'title': 'in_progress', 'colorCode': '#FEC636', 'defaultNotes': 'Device is in progress', 'priority': 2};

      // Create the job status entry
      final jobStatusEntry = {
        'title': statusConfig['title'],
        'userId': userId,
        'colorCode': statusConfig['colorCode'],
        'userName': userName,
        'createAtStatus': DateTime.now().millisecondsSinceEpoch,
        'notifications': sendNotification,
        'email': email,
        'notes': customNotes ?? statusConfig['defaultNotes'],
        'priority': statusConfig['priority'],
      };

      // Prepare the payload
      final payload = {
        'job': {
          'is_job_completed': isJobCompleted,
          'status': statusConfig['title'],
          'jobStatus': [jobStatusEntry],
        },
      };

      debugPrint('🔄 Updating job completion status:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 is_job_completed: $isJobCompleted');
      debugPrint('🔄 New status: ${statusConfig['title']}');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job completion status updated successfully');

        // Send email notification if job is completed and notification is enabled
        if (isJobCompleted && sendNotification) {
          await _sendJobCompleteEmail(currentJob, statusConfig['title']);
        }

        return SingleJobModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update job status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateJobCompletionStatus: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to send completion email
  Future<void> _sendJobCompleteEmail(SingleJobModel job, String jobStatus) async {
    try {
      // Extract required data from the job
      final jobData = job.data!;
      final customerDetails = jobData.customerDetails!;
      final contact = jobData.contact!.isNotEmpty ? jobData.contact!.first : null;

      await EmailService.sendJobCompleteEmail(
        jobNo: jobData.jobNo!,
        email: customerDetails.email ?? contact?.email ?? '',
        userId: jobData.userId!,
        jobId: jobData.sId!,
        salutation: customerDetails.salutation ?? '',
        contactFirstname: contact?.firstName! ?? customerDetails.firstName!,
        contactLastname: contact?.lastName! ?? customerDetails.lastName!,
        locationId: jobData.location!,
        jobStatus: jobStatus,
        loggedUserId: jobData.userId!,
      );
    } catch (e) {
      debugPrint('❌ Error preparing email data: $e');
      // Don't throw - email failure shouldn't block job completion
    }
  }

  Future<SingleJobModel> updateJobReturnStatus(
    String jobId,
    bool isReturnDevice,
    String userId,
    String userName,
    String email, {
    String? customNotes,
    bool sendNotification = true,
  }) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      // Define status configuration based on return device status
      final Map<String, dynamic> statusConfig = isReturnDevice
          ? {'title': 'archive', 'colorCode': '#EDEEF1', 'defaultNotes': 'move to trash', 'priority': 'archive'}
          : {'title': 'in_progress', 'colorCode': '#008444', 'defaultNotes': 'Device is in progress', 'priority': 2};

      // Create the job status entry
      final jobStatusEntry = {
        'title': statusConfig['title'],
        'userId': userId,
        'colorCode': statusConfig['colorCode'],
        'userName': userName,
        'createAtStatus': DateTime.now().millisecondsSinceEpoch,
        'notifications': sendNotification,
        'email': email,
        'notes': customNotes ?? statusConfig['defaultNotes'],
        'priority': statusConfig['priority'],
      };

      // Prepare the payload with nested structure
      final payload = {
        'job': {
          'is_device_returned': isReturnDevice,
          'status': statusConfig['title'],
          'jobStatus': [jobStatusEntry],
        },
      };

      debugPrint('🔄 Updating job return status:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 is_device_returned: $isReturnDevice');
      debugPrint('🔄 New status: ${statusConfig['title']}');
      debugPrint('🔄 Notes: ${customNotes ?? statusConfig['defaultNotes']}');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job return status updated successfully');
        debugPrint('✅ Response - is_device_returned: ${response.data['data']?['is_device_returned']}');
        debugPrint('✅ Response - status: ${response.data['data']?['status']}');

        return SingleJobModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update job return status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateJobReturnStatus: $e');
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

  ///. ------------------------------------------------------------------------------.
  ///| Additional job-related repository methods can be added here.               |
  ///' ------------------------------------------------------------------------------'

  // Add to JobRepository

  Future<SingleJobModel> updateJobDueDate(String jobId, DateTime dueDate) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      final payload = {
        'job': {'due_date': dueDate.toIso8601String()},
      };

      debugPrint('🔄 Updating job due date:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 Due Date: ${dueDate.toIso8601String()}');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job due date updated successfully');
        return SingleJobModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update job due date: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateJobDueDate: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SingleJobModel> updateJobAssignee(String jobId, String assignUserId, String assignerName) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      final payload = {
        'job': {'assign_user': assignUserId, 'assigner_name': assignerName},
      };

      debugPrint('🔄 Updating job assignee:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 Assign User ID: $assignUserId');
      debugPrint('🔄 Assigner Name: $assignerName');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job assignee updated successfully');
        return SingleJobModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update job assignee: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateJobAssignee: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // Update the existing updateJobPriority method to use nested structure
  Future<SingleJobModel> updateJobPriority(String jobId, String priority) async {
    debugPrint('🔄 JobRepository: Updating job priority for Job ID: $jobId to $priority');
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      final payload = {
        'job': {'job_priority': priority},
      };

      dio.Response response = await BaseClient.patch(url: url, payload: payload);
      debugPrint('🔄 repo: Updated job priority for Job ID: ${response.data['data']?['_id']} to $priority');

      if (response.statusCode != 200) {
        throw Exception('Failed to update job priority: ${response.statusCode}');
      }
      return SingleJobModel.fromJson(response.data);
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.data['message'] ?? e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateJobPriority: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // Add this to your JobRepository

  Future<AssignUserListModel> getAssignUserList(String ownerId) async {
    try {
      final url = '${ApiEndpoints.findByOwner}$ownerId';

      debugPrint('🔄 Fetching assign user list for owner: $ownerId');
      debugPrint('🔄 URL: $url');

      dio.Response response = await BaseClient.get(url: url);

      if (response.statusCode == 200) {
        debugPrint('✅ Assign user list fetched successfully');
        debugPrint('✅ Total users: ${response.data['data']?.length ?? 0}');

        return AssignUserListModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch assign user list: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getAssignUserList: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Failed to fetch users: $e');
    }
  }
}
