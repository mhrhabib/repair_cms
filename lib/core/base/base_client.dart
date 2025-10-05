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

    var dio = Dio(await getBaseOptions());

    // Print the URL before making the request
    debugPrint('\n🌐 GET Request:');
    debugPrint('📝 URL: $url');
    if (payload != null) {
      debugPrint('📦 Payload: $payload');
    }

    var response = await dio.get(url, queryParameters: payload);

    // Print response details
    debugPrint('✅ Response Status: ${response.statusCode}');
    debugPrint('📄 Response Data: ${response.data}');
    debugPrint('--- End of Request ---\n');

    return response;
  }

  static Future<dynamic> post({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio(await getBaseOptions());

    debugPrint('\n🌐 POST Request:');
    debugPrint('📝 URL: $url');
    debugPrint('📦 Payload: $payload');

    var response = await dio.post(url, data: payload);

    debugPrint('✅ Response Status: ${response.statusCode}');
    debugPrint('📄 Response Data: ${response.data}');
    debugPrint('--- End of Request ---\n');

    return response;
  }

  static Future<dynamic> put({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio(await getBaseOptions());

    debugPrint('\n🌐 PUT Request:');
    debugPrint('📝 URL: $url');
    debugPrint('📦 Payload: $payload');

    var response = await dio.put(url, data: payload);

    debugPrint('✅ Response Status: ${response.statusCode}');
    debugPrint('📄 Response Data: ${response.data}');
    debugPrint('--- End of Request ---\n');

    return response;
  }

  static Future<dynamic> patch({required String url, dynamic payload}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio(await getBaseOptions());

    debugPrint('\n🌐 PATCH Request:');
    debugPrint('📝 URL: $url');
    debugPrint('📦 Payload: $payload');

    var response = await dio.patch(url, data: payload);

    debugPrint('✅ Response Status: ${response.statusCode}');
    debugPrint('📄 Response Data: ${response.data}');
    debugPrint('--- End of Request ---\n');

    return response;
  }

  static Future<dynamic> delete({required String url}) async {
    final storage = GetStorage();
    final token = storage.read('token');
    debugPrint(">>>>>>> Token: $token");

    var dio = Dio(await getBaseOptions());

    debugPrint('\n🌐 DELETE Request:');
    debugPrint('📝 URL: $url');

    var response = await dio.delete(url);

    debugPrint('✅ Response Status: ${response.statusCode}');
    debugPrint('📄 Response Data: ${response.data}');
    debugPrint('--- End of Request ---\n');

    return response;
  }
}
