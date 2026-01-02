// services/base_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/interceptors/log_interceptor.dart';

class BaseClient {
  static Future<BaseOptions> getBaseOptions() async {
    final storage = GetStorage();
    final token = await storage.read('token');

    BaseOptions options = BaseOptions(
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 120), // Longer for file uploads
      responseType: ResponseType.plain, // Get raw response to see what server returns
      headers: {
        "Accept": "application/json",
        'Content-type': 'application/json',
        'rcms-mobile-app': 'ZnxmGWN2aEuMNeRVnQZrRvyr0Vn4uHLAZ08GxYt9M39PVB2c1Mx0ulqwYnIxl',
        'X-Requested-With': 'XMLHttpRequest',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return options;
  }

  static Dio _createDioInstance() {
    var dio = Dio();
    // Add custom log interceptor for detailed request/response logging
    dio.interceptors.add(LoggingInterceptor());
    return dio;
  }

  static Future<dynamic> get({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = _createDioInstance();

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

    var dio = _createDioInstance();
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

    var dio = _createDioInstance();
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

    var dio = _createDioInstance();
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

    var dio = _createDioInstance();
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
