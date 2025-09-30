// services/base_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

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
        'X-Requested-With': 'XMLHttpRequest',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return options;
  }

  static Future<dynamic> get({required String url, dynamic payload}) async {
    final storage = GetStorage();
    print(">>>>>>> Token: ${storage.read('token')}");

    var dio = Dio(await getBaseOptions());
    var response = await dio.get(url, queryParameters: payload);

    print('\nURL: $url');
    print('Response: $response\n');
    return response;
  }

  static Future<dynamic> post({required String url, dynamic payload}) async {
    final storage = GetStorage();
    print(">>>>>>> Token: ${storage.read('token')}");

    var dio = Dio(await getBaseOptions());
    var response = await dio.post(url, data: payload);

    print('\nURL: $url');
    print('Payload: $payload');
    print('Response: ${response.data}\n');
    return response;
  }

  static Future<dynamic> put({required String url, dynamic payload}) async {
    var dio = Dio(await getBaseOptions());
    var response = await dio.put(url, data: payload);
    return response;
  }

  static Future<dynamic> delete({required String url}) async {
    var dio = Dio(await getBaseOptions());
    var response = await dio.delete(url);
    return response;
  }
}
