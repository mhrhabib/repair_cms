// repositories/job_repository.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:uuid/uuid.dart';
import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/services/email_service.dart';
import 'package:repair_cms/features/myJobs/models/assign_user_list_model.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart' hide InternalNote;
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

      debugPrint('🚀 [JobRepository] Fetching jobs:');
      debugPrint('   📍 User ID: $userID');
      debugPrint('   📍 Status Filter: $status');
      debugPrint('   📍 Page: $page');
      debugPrint('   📍 Query Params: $queryParams');

      dio.Response response = await BaseClient.get(
        url: '${ApiEndpoints.getAllJobs}/user/$userID',
        payload: queryParams,
      );

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

        // 🔍 DEBUG: Print field types before parsing
        _debugResponseFields(responseData);

        return JobListResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch jobs: ${response.statusCode} - ${response.data}');
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

      if (response.statusCode == 200) {
        // Parse JSON string to Map if needed
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Job completion status updated successfully');

        // Send email notification if job is completed and notification is enabled
        if (isJobCompleted && sendNotification) {
          await _sendJobCompleteEmail(currentJob, statusConfig['title']);
        }

        // Handle String response that needs decoding
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('📄 Response is String, decoding...');
          responseData = jsonDecode(responseData);
        }

        return SingleJobModel.fromJson(responseData);
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

        // Handle String response by decoding it first
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('📄 Response is String, decoding...');
          responseData = jsonDecode(responseData);
        }

        debugPrint('✅ Response - is_device_returned: ${responseData['data']?['is_device_returned']}');
        debugPrint('✅ Response - status: ${responseData['data']?['status']}');

        return SingleJobModel.fromJson(responseData);
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
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('📄 updateJobDueDate: response is String, decoding...');
          responseData = jsonDecode(responseData);
        }
        return SingleJobModel.fromJson(responseData);
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

      // Handle string response
      dynamic responseData = response.data;
      if (responseData is String) {
        debugPrint('📄 Response is String, decoding...');
        responseData = jsonDecode(responseData);
      }

      if (response.statusCode == 200) {
        debugPrint('✅ Job assignee updated successfully');
        return SingleJobModel.fromJson(responseData);
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

      // Handle string response
      dynamic responseData = response.data;
      if (responseData is String) {
        debugPrint('📄 Response is String, decoding...');
        responseData = jsonDecode(responseData);
      }

      debugPrint('🔄 repo: Updated job priority for Job ID: ${responseData['data']?['_id']} to $priority');

      if (response.statusCode != 200) {
        throw Exception('Failed to update job priority: ${response.statusCode}');
      }
      return SingleJobModel.fromJson(responseData);
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
        // Parse JSON string to Map if needed
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;

        debugPrint('✅ Assign user list fetched successfully');
        debugPrint('✅ Total users: ${responseData['data']?.length ?? 0}');

        return AssignUserListModel.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch assign user list: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getAssignUserList: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Failed to fetch users: $e');
    }
  }

  //add status job
  // Add to JobRepository class
  // Update the addJobStatus method in JobRepository
  Future<SingleJobModel> addJobStatus({
    required String jobId,
    required String status,
    required String userId,
    required String userName,
    required String email,
    String? notes,
    bool sendNotification = true,
    String? colorCode,
    int priority = 2,
  }) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      // First, get the current job to append to existing status
      final currentJobResponse = await BaseClient.get(url: url);

      // Handle String response that needs decoding
      dynamic currentJobData = currentJobResponse.data;
      if (currentJobData is String) {
        debugPrint('📄 Current job response is String, decoding...');
        currentJobData = jsonDecode(currentJobData);
      }

      final currentJob = SingleJobModel.fromJson(currentJobData);
      final existingStatuses = currentJob.data?.jobStatus ?? [];

      // Determine color code if not provided
      final String statusColor = colorCode ?? _getDefaultColorForStatus(status);

      // Create the new job status entry
      final newJobStatusEntry = {
        'title': status,
        'userId': userId,
        'colorCode': statusColor,
        'userName': userName,
        'createAtStatus': DateTime.now().millisecondsSinceEpoch,
        'notifications': sendNotification,
        'email': email,
        'notes': notes ?? _getDefaultNotesForStatus(status),
        'priority': priority,
      };

      // Append the new status to existing ones
      final updatedStatuses = [...existingStatuses, newJobStatusEntry];

      // Prepare the payload with nested structure
      final payload = {
        'job': {
          'status': status, // Update the main status
          'jobStatus': updatedStatuses, // Send the entire updated array
        },
      };

      debugPrint('🔄 Adding job status (appending):');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 Status: $status');
      debugPrint('🔄 Existing statuses: ${existingStatuses.length}');
      debugPrint('🔄 New total statuses: ${updatedStatuses.length}');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job status added successfully (appended)');

        // Handle String response that needs decoding
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('📄 Response is String, decoding...');
          responseData = jsonDecode(responseData);
        }

        return SingleJobModel.fromJson(responseData);
      } else {
        throw Exception('Failed to add job status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in addJobStatus: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper methods for default values
  String _getDefaultColorForStatus(String status) {
    final statusLower = status.toLowerCase();

    if (statusLower.contains('repair') || statusLower.contains('progress')) {
      return '#FEC636';
    } else if (statusLower.contains('quotation')) {
      return '#8a0505';
    } else if (statusLower.contains('invoice')) {
      return '#8a0505';
    } else if (statusLower.contains('ready') || statusLower.contains('return')) {
      return '#008444';
    } else if (statusLower.contains('complete') || statusLower.contains('finished')) {
      return '#008444';
    } else if (statusLower.contains('cancel')) {
      return '#FF0000';
    } else if (statusLower.contains('archive')) {
      return '#EDEEF1';
    } else if (statusLower.contains('pending') || statusLower.contains('waiting')) {
      return '#FFA500';
    }

    return '#2589F6'; // Default blue color
  }

  String _getDefaultNotesForStatus(String status) {
    final statusLower = status.toLowerCase();

    if (statusLower.contains('repair') || statusLower.contains('progress')) {
      return 'Device repair in progress';
    } else if (statusLower.contains('quotation')) {
      return 'Quotation sent to customer';
    } else if (statusLower.contains('invoice')) {
      return 'Invoice sent to customer';
    } else if (statusLower.contains('ready') || statusLower.contains('return')) {
      return 'Device is ready to return';
    } else if (statusLower.contains('complete') || statusLower.contains('finished')) {
      return 'Job completed successfully';
    } else if (statusLower.contains('cancel')) {
      return 'Job has been cancelled';
    }

    return 'Status updated';
  }

  ///.=========================================================================.
  ///! add job notes                                                        !
  ///.=========================================================================.
  // Add to JobRepository class
  Future<SingleJobModel> addJobNote({
    required String jobId,
    required String noteText,
    required String userId,
    required String userName,
  }) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      // First, get the current job to append to existing notes
      final currentJobResponse = await BaseClient.get(url: url);
      dynamic currentJobData = currentJobResponse.data;
      if (currentJobData is String) {
        debugPrint('📄 addJobNote: response is String, decoding...');
        currentJobData = jsonDecode(currentJobData);
      }
      final currentJob = SingleJobModel.fromJson(currentJobData);

      // Get existing defect and notes
      final existingDefects = currentJob.data?.defect ?? [];
      List<InternalNote> existingNotes = [];

      if (existingDefects.isNotEmpty) {
        existingNotes = existingDefects.first.internalNote ?? [];
      }

      // Create the new note entry
      final newNoteEntry = {
        'text': noteText,
        'userId': userId,
        'userName': userName,
        'createdAt': DateTime.now().toIso8601String(),
        'id': '${DateTime.now().millisecondsSinceEpoch}-${userId.substring(0, 8)}', // Generate unique ID
      };

      // Append the new note to existing ones
      final updatedNotes = [...existingNotes, InternalNote.fromJson(newNoteEntry)];

      // Prepare the payload with nested structure
      final payload = {
        'defect': {'internalNote': updatedNotes.map((note) => note.toJson()).toList()},
      };

      debugPrint('🔄 Adding job note:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 Note: $noteText');
      debugPrint('🔄 User: $userName');
      debugPrint('🔄 Existing notes: ${existingNotes.length}');
      debugPrint('🔄 New total notes: ${updatedNotes.length}');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job note added successfully');
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('📄 addJobNote: response is String, decoding...');
          responseData = jsonDecode(responseData);
        }
        return SingleJobModel.fromJson(responseData);
      } else {
        throw Exception('Failed to add job note: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in addJobNote: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // Add update and delete methods as well
  Future<SingleJobModel> updateJobNote({
    required String jobId,
    required String noteId,
    required String noteText,
    required String userId,
    required String userName,
  }) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      // Get the current job
      final currentJobResponse = await BaseClient.get(url: url);
      dynamic currentJobData = currentJobResponse.data;
      if (currentJobData is String) {
        debugPrint('📄 updateJobNote: response is String, decoding...');
        currentJobData = jsonDecode(currentJobData);
      }
      final currentJob = SingleJobModel.fromJson(currentJobData);

      // Get existing defect and notes
      final existingDefects = currentJob.data?.defect ?? [];
      List<InternalNote> existingNotes = [];

      if (existingDefects.isNotEmpty) {
        existingNotes = existingDefects.first.internalNote ?? [];
      }

      // Find and update the specific note
      final updatedNotes = existingNotes.map((note) {
        if (note.id == noteId) {
          return InternalNote(
            text: noteText,
            userId: userId,
            userName: userName,
            createdAt: note.createdAt, // Keep original creation time
            id: note.id,
          );
        }
        return note;
      }).toList();

      // Prepare the payload
      final payload = {
        'defect': {'internalNote': updatedNotes.map((note) => note.toJson()).toList()},
      };

      debugPrint('🔄 Updating job note:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 Note ID: $noteId');
      debugPrint('🔄 Updated note: $noteText');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job note updated successfully');
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('📄 updateJobNote: response is String, decoding...');
          responseData = jsonDecode(responseData);
        }
        return SingleJobModel.fromJson(responseData);
      } else {
        throw Exception('Failed to update job note: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in updateJobNote: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SingleJobModel> deleteJobNote({required String jobId, required String noteId}) async {
    try {
      final url = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);

      // Get the current job
      final currentJobResponse = await BaseClient.get(url: url);
      dynamic currentJobData = currentJobResponse.data;
      if (currentJobData is String) {
        debugPrint('📄 deleteJobNote: response is String, decoding...');
        currentJobData = jsonDecode(currentJobData);
      }
      final currentJob = SingleJobModel.fromJson(currentJobData);

      // Get existing defect and notes
      final existingDefects = currentJob.data?.defect ?? [];
      List<InternalNote> existingNotes = [];

      if (existingDefects.isNotEmpty) {
        existingNotes = existingDefects.first.internalNote ?? [];
      }

      // Remove the specific note
      final updatedNotes = existingNotes.where((note) => note.id != noteId).toList();

      // Prepare the payload
      final payload = {
        'defect': {'internalNote': updatedNotes.map((note) => note.toJson()).toList()},
      };

      debugPrint('🔄 Deleting job note:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 Note ID: $noteId');
      debugPrint('🔄 Remaining notes: ${updatedNotes.length}');

      dio.Response response = await BaseClient.patch(url: url, payload: payload);

      if (response.statusCode == 200) {
        debugPrint('✅ Job note deleted successfully');
        dynamic responseData = response.data;
        if (responseData is String) {
          debugPrint('📄 deleteJobNote: response is String, decoding...');
          responseData = jsonDecode(responseData);
        }
        return SingleJobModel.fromJson(responseData);
      } else {
        throw Exception('Failed to delete job note: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in deleteJobNote: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  ///.=========================================================================.
  ///! file upload                                                     !
  ///.=========================================================================.
  ///
  ///
  // Add to JobRepository class
  Future<SingleJobModel> uploadJobFile({
    required String jobId,
    required String jobNo,
    required String filePath,
    required String fileName,
    required int fileSize,
  }) async {
    try {
      final userId = storage.read('userId');
      final uploadUrl = '${ApiEndpoints.fileUplaodUrl}$userId/job/$jobNo';
      final patchUrl = '${ApiEndpoints.baseUrl}/job/$jobId';

      debugPrint('🚀 Step 1: Upload file to S3...');

      // Validate file
      final file = io.File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Read and encode file as base64
      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final fileId = const Uuid().v4();

      debugPrint('   🖼️ MIME type: $mimeType');
      debugPrint('   📊 Base64 length: ${base64File.length}');

      final base64String = 'data:$mimeType;base64,$base64File';

      // Step 1: POST file as base64 to get file path
      final uploadPayload = {'file': base64String, 'id': fileId, 'fileName': fileName, 'size': fileSize};

      debugPrint('📦 Uploading to: $uploadUrl');
      final uploadResponse = await BaseClient.post(url: uploadUrl, payload: uploadPayload);

      if (uploadResponse.statusCode != 201 && uploadResponse.statusCode != 200) {
        throw Exception('File upload failed: ${uploadResponse.statusCode}');
      }

      // Response is a plain string with the file path
      final uploadedFilePath = uploadResponse.data is String ? uploadResponse.data as String : null;

      if (uploadedFilePath == null || uploadedFilePath.isEmpty) {
        throw Exception('No file path returned from upload');
      }

      debugPrint('✅ File uploaded: $uploadedFilePath');

      // Step 2: Get signed URL for display
      debugPrint('🚀 Step 2: Getting signed URL...');

      String? signedUrl;
      try {
        final imageUrl = '${ApiEndpoints.fileUplaodUrl}images?imagePath=$uploadedFilePath';
        debugPrint('📥 Fetching signed URL: $imageUrl');

        final urlResponse = await BaseClient.get(url: imageUrl);

        if (urlResponse.statusCode == 200 && urlResponse.data is String) {
          signedUrl = urlResponse.data as String;
          debugPrint('✅ Got signed URL');
        }
      } catch (e) {
        debugPrint('⚠️ Could not get signed URL: $e');
      }

      // Step 3: PATCH job with file metadata
      debugPrint('🚀 Step 3: Patching job...');

      // First, get existing files from the job
      debugPrint('📋 Fetching existing files...');
      final existingJob = await getJobById(jobId);
      final existingFiles =
          existingJob.data?.files
              ?.map(
                (f) => {
                  'file': f.file,
                  'id': f.id,
                  'fileName': f.fileName,
                  'size': f.size,
                  if (f.url != null) 'url': f.url,
                },
              )
              .toList() ??
          [];

      debugPrint('📊 Found ${existingFiles.length} existing files');

      final fileMetadata = {'file': uploadedFilePath, 'id': fileId, 'fileName': fileName, 'size': fileSize};

      // Add signed URL if we got it
      if (signedUrl != null && signedUrl.isNotEmpty) {
        fileMetadata['url'] = signedUrl;
      }

      // Append new file to existing files
      final allFiles = [...existingFiles, fileMetadata];
      debugPrint('📊 Total files after upload: ${allFiles.length}');

      final patchPayload = {
        'job': {
          'files': allFiles, // Send all files (existing + new)
        },
      };

      debugPrint('📦 Patching: $patchUrl');
      final patchResponse = await BaseClient.patch(url: patchUrl, payload: patchPayload);

      if (patchResponse.statusCode != 200 && patchResponse.statusCode != 201) {
        throw Exception('Job patch failed: ${patchResponse.statusCode}');
      }

      debugPrint('✅ Job patched successfully');

      // Parse the response (now it's plain text, so we need to parse it)
      final responseData = patchResponse.data is String ? jsonDecode(patchResponse.data) : patchResponse.data;

      // The response should contain the updated job with files
      if (responseData is Map && responseData['data'] != null) {
        final jobData = responseData['data'];

        // Fetch signed URLs for any files that don't have them yet
        if (jobData is Map && jobData['files'] != null && jobData['files'] is List) {
          final files = jobData['files'] as List;

          for (var fileData in files) {
            if (fileData is Map && fileData['file'] != null && fileData['url'] == null) {
              final filePath = fileData['file'] as String;

              try {
                // Get signed URL
                final imageUrl = '${ApiEndpoints.fileUplaodUrl}images?imagePath=$filePath';
                debugPrint('📥 Fetching signed URL: $imageUrl');

                final urlResponse = await BaseClient.get(url: imageUrl);

                if (urlResponse.statusCode == 200 && urlResponse.data is String) {
                  fileData['url'] = urlResponse.data as String;
                  debugPrint('✅ Got signed URL for: ${fileData['fileName']}');
                }
              } catch (e) {
                debugPrint('⚠️ Could not get signed URL for ${fileData['fileName']}: $e');
              }
            }
          }
        }

        return SingleJobModel.fromJson(Map<String, dynamic>.from(responseData));
      } else if (responseData is Map && responseData['job'] != null) {
        return SingleJobModel.fromJson({'success': true, 'data': Map<String, dynamic>.from(responseData['job'])});
      } else {
        // Fallback: fetch the updated job
        return await getJobById(jobId);
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      throw Exception('File upload failed: ${e.toString()}');
    }
  }

  Future<SingleJobModel> deleteJobFile({required String jobId, required String filePath}) async {
    try {
      debugPrint('🔄 Deleting job file:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 File Path: $filePath');

      // Step 1: Get the current job to find the file entry
      final currentJob = await getJobById(jobId);
      final currentFiles = currentJob.data?.files ?? [];

      debugPrint('📊 Current files count: ${currentFiles.length}');

      // Step 2: Remove the file from S3
      final deleteUrl = '${ApiEndpoints.fileUplaodUrl}images?imagePath=$filePath';
      debugPrint('🗑️ Deleting from S3: $deleteUrl');

      try {
        final deleteResponse = await BaseClient.delete(url: deleteUrl);
        if (deleteResponse.statusCode == 200) {
          debugPrint('✅ File deleted from S3');
        } else {
          debugPrint('⚠️ S3 delete returned: ${deleteResponse.statusCode}');
        }
      } catch (e) {
        debugPrint('⚠️ S3 delete error (continuing): $e');
        // Continue even if S3 delete fails - we still want to remove from DB
      }

      // Step 3: Remove the file entry from the job's files array
      final updatedFiles = currentFiles.where((file) => file.file != filePath).toList();
      debugPrint('📊 Updated files count: ${updatedFiles.length}');

      if (updatedFiles.length == currentFiles.length) {
        debugPrint('⚠️ Warning: File not found in job files list');
      }

      // Step 4: PATCH the job with the updated files array
      final patchUrl = ApiEndpoints.getJobById.replaceFirst('<id>', jobId);
      final patchPayload = {
        'job': {
          'files': updatedFiles
              .map(
                (f) => {
                  'file': f.file,
                  'id': f.id,
                  'fileName': f.fileName,
                  'size': f.size,
                  if (f.url != null) 'url': f.url,
                },
              )
              .toList(),
        },
      };

      debugPrint('🔄 Patching job to remove file entry');
      final patchResponse = await BaseClient.patch(url: patchUrl, payload: patchPayload);

      if (patchResponse.statusCode == 200 || patchResponse.statusCode == 201) {
        debugPrint('✅ Job file list updated successfully');

        // Handle String response that needs decoding
        dynamic responseData = patchResponse.data;
        if (responseData is String) {
          debugPrint('📄 Response is String, decoding...');
          responseData = jsonDecode(responseData);
        }

        return SingleJobModel.fromJson(responseData);
      } else {
        throw Exception('Failed to update job file list: ${patchResponse.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in deleteJobFile: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Failed to delete file: $e');
    }
  }

  // Helper method to get MIME type from file extension
}
