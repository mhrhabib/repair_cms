import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';

class FileService {
  /// Generates a full URL for an image path from the server.
  /// Handles absolute and relative paths by direct construction.
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // For relative paths, append the download endpoint
    return '${ApiEndpoints.baseUrl}/file-upload/download/new?imagePath=$imagePath';
  }

  /// Fetches a full URL for an image path from the server asynchronously.
  /// This typically returns a signed URL from the file-upload service.
  static Future<String> getImageUrlAsync(String imagePath) async {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    try {
      debugPrint('🔄 FileService: Fetching image URL for path: $imagePath');
      final response = await BaseClient.get(url: ApiEndpoints.getAnImage, payload: {'imagePath': imagePath});

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        String? url;

        if (data is String && data.isNotEmpty) {
          url = data;
        } else if (data is Map) {
          url = data['data'] ?? data['url'];
        }

        if (url != null && url.isNotEmpty) {
          debugPrint('✅ FileService: Image URL retrieved: $url');
          return url;
        }
      }
      debugPrint('⚠️ FileService: Failed to get image URL, fallback to constructed URL');
      return getImageUrl(imagePath);
    } catch (e) {
      debugPrint('❌ FileService Error getting image URL: $e');
      return getImageUrl(imagePath);
    }
  }
}
