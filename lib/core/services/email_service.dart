// email_service.dart
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:dio/dio.dart' as dio;

class EmailService {
  static const String baseUrl = 'https://api.repaircms.com';

  static Future<void> sendJobCompleteEmail({
    required String jobNo,
    required String email,
    required String userId,
    required String jobId,
    required String salutation,
    required String contactFirstname,
    required String contactLastname,
    required String locationId,
    required String jobStatus,
    required String loggedUserId,
  }) async {
    try {
      final url = '$baseUrl/send-mail/job/complete';

      final payload = {
        'jobNo': jobNo,
        'email': email,
        'userId': userId,
        'jobId': jobId,
        'salutation': salutation,
        'contact_firstname': contactFirstname,
        'contact_lastname': contactLastname,
        'locationId': locationId,
        'job_status': jobStatus,
        'loggedUserId': loggedUserId,
      };

      debugPrint('📧 Sending job completion email...');
      debugPrint('📧 URL: $url');
      debugPrint('📧 Payload: $payload');

      dio.Response response = await BaseClient.post(url: url, payload: payload);

      if (response.statusCode == 201) {
        debugPrint('✅ Job completion email sent successfully');
      } else {
        debugPrint('❌ Failed to send email. Status: ${response.statusCode}');
        throw Exception(
          'Failed to send completion email: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending job completion email: $e');
      // Don't throw error here - email failure shouldn't block job completion
      // You can handle this differently based on your requirements
    }
  }
}
