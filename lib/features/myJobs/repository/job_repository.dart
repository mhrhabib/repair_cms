// repositories/job_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart' as dio;
import 'package:uuid/uuid.dart';
import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
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

      dio.Response response = await BaseClient.get(
        url: '${ApiEndpoints.getAllJobs}/user/$userID',
        payload: queryParams,
      );
      final responseData = response.data;

      if (response.statusCode == 200) {
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
      final currentJob = SingleJobModel.fromJson(currentJobResponse.data);
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
        return SingleJobModel.fromJson(response.data);
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
      final currentJob = SingleJobModel.fromJson(currentJobResponse.data);

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
        return SingleJobModel.fromJson(response.data);
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
      final currentJob = SingleJobModel.fromJson(currentJobResponse.data);

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
        return SingleJobModel.fromJson(response.data);
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
      final currentJob = SingleJobModel.fromJson(currentJobResponse.data);

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
        return SingleJobModel.fromJson(response.data);
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
      final url = '${ApiEndpoints.fileUplaodUrl}${storage.read('userId')}/job/$jobNo';

      debugPrint('🚀 [JobRepository] Starting file upload...');
      debugPrint('   👤 User ID: ${storage.read('userId')}');
      debugPrint('   📋 Job ID: $jobNo');
      debugPrint('   📁 File path: $filePath');
      debugPrint('   📄 File name: $fileName');
      debugPrint('   📏 File size: $fileSize bytes');
      debugPrint('   🌐 URL: $url');

      // Validate file
      final file = io.File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final actualFileSize = await file.length();
      debugPrint('   📊 Actual file size: ${actualFileSize ~/ 1024}KB');

      // Read and encode file
      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);
      final mimeType = _getMimeType(fileName);

      debugPrint('   🖼️ MIME type: $mimeType');
      debugPrint('   🔤 Base64 length: ${base64File.length}');

      final base64String = 'data:$mimeType;base64,$base64File';

      // Generate unique ID for the file
      final fileId = const Uuid().v4();

      // Create payload
      final Map<String, dynamic> payload = {"file": base64String, "id": fileId, "fileName": fileName, "size": fileSize};

      debugPrint('📤 [JobRepository] Sending request with authentication... $payload');

      // Get authentication token from storage
      final token = storage.read('token'); // Adjust this based on your storage key
      debugPrint('   🔑 Token available: ${token != null}');
      debugPrint(
        '   🔑 Token starts with: ${token != null ? token.substring(0, min(20, token.length)) : 'NO TOKEN'}...',
      );

      // Use Dio directly with authentication
      final dio.Dio dioInstance = dio.Dio();

      // Configure Dio with authentication headers
      dioInstance.options = dio.BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          // Add any other headers your API requires
        },
      );

      // Add interceptors for better debugging
      dioInstance.interceptors.add(
        dio.InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('🚀 [Dio] Request: ${options.method} ${options.uri}');
            debugPrint('📦 [Dio] Headers: ${options.headers}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('✅ [Dio] Response: ${response.statusCode}');
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('❌ [Dio] Error: ${error.type}');
            debugPrint('❌ [Dio] Error message: ${error.message}');
            debugPrint('❌ [Dio] Response status: ${error.response?.statusCode}');
            return handler.next(error);
          },
        ),
      );

      final response = await dioInstance.post(url, data: payload);

      debugPrint('✅ [JobRepository] Response received');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📄 Response Data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('   🎉 File uploaded successfully!');

        // After successful upload, get the updated job to include the new file
        return await getJobById(jobId);
      } else {
        debugPrint('❌ Upload failed with status: ${response.statusCode}');
        debugPrint('❌ Response data: ${response.data}');
        throw Exception('Failed to upload file: ${response.statusCode} - ${response.data}');
      }
    } on dio.DioException catch (e, stackTrace) {
      debugPrint('❌ [JobRepository] DIO ERROR DETAILS:');
      debugPrint('   🚨 Error Type: ${e.type}');
      debugPrint('   📝 Error Message: ${e.message}');
      debugPrint('   📝 Error Message: $stackTrace');
      debugPrint('   🔗 Request URL: ${e.requestOptions.uri}');
      debugPrint('   📦 Request Headers: ${e.requestOptions.headers}');

      if (e.response != null) {
        debugPrint('   📊 Response Status: ${e.response?.statusCode}');
        debugPrint('   📄 Response Data: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      }

      throw Exception('Upload failed: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('💥 [JobRepository] UNEXPECTED ERROR:');
      debugPrint('   📝 Error: $e');
      debugPrint('   📜 Stack Trace: $stackTrace');
      throw Exception('File upload failed: ${e.toString()}');
    }
  }

  Future<SingleJobModel> deleteJobFile({required String jobId, required String fileId}) async {
    try {
      final url = '${ApiEndpoints.fileUplaodUrl}images?/$jobId/$fileId';

      debugPrint('🔄 Deleting job file:');
      debugPrint('🔄 Job ID: $jobId');
      debugPrint('🔄 File ID: $fileId');

      dio.Response response = await BaseClient.delete(url: url);

      if (response.statusCode == 200) {
        debugPrint('✅ Job file deleted successfully');

        // After successful deletion, get the updated job
        return await getJobById(jobId);
      } else {
        throw Exception('Failed to delete file: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in deleteJobFile: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Failed to delete file: $e');
    }
  }

  // Helper method to get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'mp4':
        return 'video/mp4';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
