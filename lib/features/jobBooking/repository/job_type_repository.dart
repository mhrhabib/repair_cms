// features/jobBooking/repository/job_type_repository.dart
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/features/jobBooking/models/job_type_model.dart';

abstract class JobTypeRepository {
  Future<List<JobType>> getJobTypeList({required String userId});
  Future<JobType> createJobType({required String name, required String userId, required String locationId});
}

class JobTypeRepositoryImpl implements JobTypeRepository {
  @override
  Future<List<JobType>> getJobTypeList({required String userId}) async {
    try {
      debugPrint('🚀 [JobTypeRepository] Fetching job type list');

      final String url = ApiEndpoints.jobTypeListUrl.replaceAll('<id>', userId);
      debugPrint('   📍 URL: $url');
      debugPrint('   👤 User ID: $userId');

      Response response = await BaseClient.get(url: url);

      debugPrint('✅ [JobTypeRepository] Job type response received:');
      debugPrint('   📊 Status Code: ${response.statusCode}');
      debugPrint('   📊 Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint('   🔄 Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data as String);
        }

        final jobTypeModel = JobTypeModel.fromJson(jsonData);

        if (jobTypeModel.data != null) {
          debugPrint('   📦 Parsed ${jobTypeModel.data!.length} job types');
          return jobTypeModel.data!;
        } else {
          debugPrint('   ⚠️ No job types found');
          return [];
        }
      } else {
        throw JobTypeException(
          message: 'Failed to load job types: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [JobTypeRepository] DioException:');
      debugPrint('   💥 Error: ${e.message}');
      debugPrint('   📍 Type: ${e.type}');
      debugPrint('   🔧 Response: ${e.response?.data}');
      throw JobTypeException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [JobTypeRepository] Unexpected error:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw JobTypeException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<JobType> createJobType({required String name, required String userId, required String locationId}) async {
    try {
      debugPrint('🚀 [JobTypeRepository] Creating job type: $name');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   📍 Location ID: $locationId');

      final Map<String, dynamic> payload = {'name': name, 'userId': userId, 'locationId': locationId};

      Response response = await BaseClient.post(url: ApiEndpoints.createJobType, payload: payload);

      debugPrint('✅ [JobTypeRepository] Job type creation response:');
      debugPrint('   📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        dynamic jsonData = response.data;
        if (response.data is String) {
          debugPrint('   🔄 Response is String, parsing JSON...');
          jsonData = jsonDecode(response.data as String);
        }

        // Handle different response structures
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            debugPrint('   ✅ Job type created successfully');
            return JobType.fromJson(jsonData['data']);
          } else {
            // If response is directly the job type object
            return JobType.fromJson(jsonData);
          }
        }

        throw JobTypeException(message: 'Unexpected response format');
      } else {
        throw JobTypeException(
          message: 'Failed to create job type: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 [JobTypeRepository] DioException during creation:');
      debugPrint('   💥 Error: ${e.message}');
      throw JobTypeException(message: 'Network error: ${e.message}', statusCode: e.response?.statusCode);
    } catch (e, stackTrace) {
      debugPrint('💥 [JobTypeRepository] Unexpected error during creation:');
      debugPrint('   💥 Error: $e');
      debugPrint('   📋 Stack: $stackTrace');
      throw JobTypeException(message: 'Unexpected error: $e');
    }
  }
}

class JobTypeException implements Exception {
  final String message;
  final int? statusCode;

  JobTypeException({required this.message, this.statusCode});

  @override
  String toString() => 'JobTypeException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
