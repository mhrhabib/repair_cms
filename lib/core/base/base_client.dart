// services/base_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';

class BaseClient {
  static Future<BaseOptions> getBaseOptions() async {
    final storage = GetStorage();
    final token = await storage.read('token');

    BaseOptions options = BaseOptions(
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
      headers: {
        "Accept": "application/json",
        'Content-type': 'application/json',
        // 'api_key': "repair_123456",
        'X-Requested-With': 'XMLHttpRequest',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return options;
  }

  static Future<dynamic> get({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio();

    // Apply base options
    final baseOptions = await getBaseOptions();
    dio.options = baseOptions;

    // Print the URL before making the request
    debugPrint('\n🌐 GET Request:');
    debugPrint('📝 URL: $url');
    if (payload != null) {
      debugPrint('📦 Query Parameters: $payload');
    }

    try {
      var response = await dio.get(url, queryParameters: payload);

      // Print response summary
      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Data Type: ${response.data.runtimeType}');
      debugPrint('--- End of Request ---\n');

      return response;
    } catch (e) {
      debugPrint('❌ GET Request Error: $e');
      rethrow;
    }
  }

  static Future<dynamic> post({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio();
    final baseOptions = await getBaseOptions();
    dio.options = baseOptions;

    debugPrint('\n🌐 POST Request:');
    debugPrint('📝 URL: $url');
    debugPrint('📦 Payload Type: ${payload.runtimeType}');

    try {
      var response = await dio.post(url, data: payload);

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Data Type: ${response.data.runtimeType}');
      debugPrint('--- End of Request ---\n');

      return response;
    } catch (e) {
      debugPrint('❌ POST Request Error: $e');
      rethrow;
    }
  }

  static Future<dynamic> put({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio();
    final baseOptions = await getBaseOptions();
    dio.options = baseOptions;

    debugPrint('\n🌐 PUT Request:');
    debugPrint('📝 URL: $url');
    debugPrint('📦 Payload Type: ${payload.runtimeType}');

    try {
      var response = await dio.put(url, data: payload);

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Data Type: ${response.data.runtimeType}');
      debugPrint('--- End of Request ---\n');

      return response;
    } catch (e) {
      debugPrint('❌ PUT Request Error: $e');
      rethrow;
    }
  }

  static Future<dynamic> patch({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio();
    final baseOptions = await getBaseOptions();
    dio.options = baseOptions;

    debugPrint('\n🌐 PATCH Request:');
    debugPrint('📝 URL: $url');
    debugPrint('📦 Payload Type: ${payload.runtimeType}');

    try {
      var response = await dio.patch(url, data: payload);

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Data Type: ${response.data.runtimeType}');
      debugPrint('--- End of Request ---\n');

      return response;
    } catch (e) {
      debugPrint('❌ PATCH Request Error: $e');
      rethrow;
    }
  }

  static Future<dynamic> delete({required String url}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio();
    final baseOptions = await getBaseOptions();
    dio.options = baseOptions;

    debugPrint('\n🌐 DELETE Request:');
    debugPrint('📝 URL: $url');

    try {
      var response = await dio.delete(url);

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📄 Response Data Type: ${response.data.runtimeType}');
      debugPrint('--- End of Request ---\n');

      return response;
    } catch (e) {
      debugPrint('❌ DELETE Request Error: $e');
      rethrow;
    }
  }
}
