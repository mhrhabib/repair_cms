import 'dart:developer';

import 'package:flutter/foundation.dart';
import '../../../core/base/base_client.dart';
import '../../../core/helpers/api_endpoints.dart';
import 'package:dio/dio.dart' as dio;

// Custom exception for file upload errors
class JobFileUploadException implements Exception {
  final String message;
  final int? statusCode;

  JobFileUploadException({required this.message, this.statusCode});

  @override
  String toString() => 'JobFileUploadException: $message';
}

// Model for uploaded file response
class UploadedFile {
  final String file;
  final String id;

  UploadedFile({required this.file, required this.id});

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(file: json['file'] as String, id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'file': file, 'id': id};
}

// Abstract repository interface
abstract class JobBookingFileUploadRepository {
  Future<List<UploadedFile>> uploadJobFile({required String userId, required String jobId, required List fileData});
}

// Repository implementation
class JobBookingFileUploadRepositoryImpl implements JobBookingFileUploadRepository {
  @override
  Future<List<UploadedFile>> uploadJobFile({
    required String userId,
    required String jobId,
    required List fileData,
  }) async {
    debugPrint('🚀 [JobBookingFileUploadRepository] Starting file upload');
    debugPrint('👤 [JobBookingFileUploadRepository] User ID: $userId');
    debugPrint('📋 [JobBookingFileUploadRepository] Job ID: $jobId');
    debugPrint('📊 [JobBookingFileUploadRepository] File data count: ${fileData.length}');

    try {
      final url = ApiEndpoints.jobFileUpload.replaceAll('<userId>', userId).replaceAll('<jobId>', jobId);

      debugPrint('🌐 [JobBookingFileUploadRepository] Uploading to: $url');
      debugPrint('🌐 [JobBookingFileUploadRepository] Payload: $fileData');

      dio.Response response = await BaseClient.post(url: url, payload: fileData);

      debugPrint('📊 [JobBookingFileUploadRepository] Response status: ${response.statusCode}');
      debugPrint('📊 [JobBookingFileUploadRepository] Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [JobBookingFileUploadRepository] File uploaded successfully');
        log(response.data.toString());

        // Handle null or empty response (backend might return 201 with no body)
        if (response.data == null || response.data == '') {
          debugPrint(
            '⚠️ [JobBookingFileUploadRepository] Response body is null/empty, but upload was successful (201)',
          );
          // Return empty list if backend doesn't return file info
          // This indicates upload was successful but no file metadata was returned
          return [];
        }

        if (response.data is List) {
          final uploadedFiles = (response.data as List)
              .map((item) => UploadedFile.fromJson(item as Map<String, dynamic>))
              .toList();

          debugPrint('📦 [JobBookingFileUploadRepository] Uploaded ${uploadedFiles.length} files');
          for (var file in uploadedFiles) {
            debugPrint('  📄 File: ${file.file}, ID: ${file.id}');
          }

          return uploadedFiles;
        }

        // If response.data is a Map, wrap it in a list
        if (response.data is Map) {
          debugPrint('⚠️ [JobBookingFileUploadRepository] Response is Map, converting to List');
          final uploadedFile = UploadedFile.fromJson(response.data as Map<String, dynamic>);
          return [uploadedFile];
        }

        // If we get here, the format is truly unexpected
        debugPrint('⚠️ [JobBookingFileUploadRepository] Unexpected response format: ${response.data.runtimeType}');
        debugPrint('⚠️ [JobBookingFileUploadRepository] Response data: ${response.data}');

        // Return empty list to indicate successful upload without metadata
        // rather than throwing an error
        return [];
      } else {
        debugPrint('❌ [JobBookingFileUploadRepository] Upload failed with status: ${response.statusCode}');
        throw JobFileUploadException(
          message: 'Failed to upload file. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on JobFileUploadException {
      rethrow;
    } catch (e) {
      debugPrint('💥 [JobBookingFileUploadRepository] Unexpected error: $e');
      throw JobFileUploadException(message: 'Failed to upload file: ${e.toString()}');
    }
  }
}
