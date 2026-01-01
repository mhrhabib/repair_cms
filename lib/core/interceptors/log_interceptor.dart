import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:repair_cms/core/app_exports.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    _logPrint('🚀 ### API Request - Start ###');

    _printKV('URI', options.uri);
    _printKV('METHOD', options.method);
    _printKV('CONTENT-TYPE', options.contentType?.toString() ?? 'application/json');
    _logPrint('HEADERS:');
    options.headers.forEach((key, v) => _printKV(' - $key', v));

    if (options.data != null) {
      _logPrint('BODY:');
      _printAll(options.data);
    }

    _logPrint('### API Request - End ###');
    _logPrint(''); // Empty line for separation

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logPrint('❌ ### API Error - Start ###');

    _printKV('URI', err.requestOptions.uri);
    _printKV('METHOD', err.requestOptions.method);
    _printKV('ERROR TYPE', err.type.toString());

    if (err.response != null) {
      _printKV('STATUS CODE', err.response?.statusCode?.toString() ?? 'N/A');
      _printKV('STATUS MESSAGE', err.response?.statusMessage ?? 'N/A');

      _logPrint('RESPONSE HEADERS:');
      err.response?.headers.forEach((key, values) => _printKV(' - $key', values));

      _logPrint('RESPONSE DATA:');
      _printAll(err.response?.data);
    } else {
      _logPrint('NO RESPONSE DATA');
    }

    _printKV('ERROR MESSAGE', err.message ?? 'Unknown error');

    // Print the actual error object if available
    if (err.error != null) {
      _printKV('UNDERLYING ERROR', err.error.toString());
      _printKV('ERROR TYPE', err.error.runtimeType.toString());
    }

    _printKV('STACK TRACE', err.stackTrace.toString());

    _logPrint('### API Error - End ###');
    _logPrint(''); // Empty line for separation

    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logPrint('✅ ### API Response - Start ###');

    _printKV('URI', response.requestOptions.uri);
    _printKV('METHOD', response.requestOptions.method);
    _printKV('STATUS CODE', response.statusCode?.toString() ?? 'N/A');
    _printKV('STATUS MESSAGE', response.statusMessage ?? 'N/A');
    _printKV('REDIRECT', response.isRedirect);

    _logPrint('RESPONSE HEADERS:');
    response.headers.forEach((key, values) => _printKV(' - $key', values));

    _logPrint('RESPONSE DATA:');
    _printAll(response.data);

    _logPrint('### API Response - End ###');
    _logPrint(''); // Empty line for separation

    return handler.next(response);
  }

  void _printKV(String key, Object v) {
    _logPrint('$key: $v');
  }

  void _printAll(dynamic msg) {
    if (msg == null) {
      _logPrint('null');
      return;
    }

    String output;

    try {
      if (msg is Map || msg is List) {
        output = const JsonEncoder.withIndent('  ').convert(msg);
      } else if (msg is String) {
        // Try to parse as JSON if it looks like JSON
        try {
          final parsedJson = json.decode(msg);
          output = const JsonEncoder.withIndent('  ').convert(parsedJson);
        } catch (e) {
          output = msg;
        }
      } else if (_hasToJsonMethod(msg)) {
        try {
          final jsonData = (msg as dynamic).toJson();
          output = const JsonEncoder.withIndent('  ').convert(jsonData);
        } catch (e) {
          output = msg.toString();
        }
      } else {
        output = msg.toString();
      }
    } catch (e) {
      output = msg.toString();
    }

    output.split('\n').forEach(_logPrint);
  }

  bool _hasToJsonMethod(dynamic obj) {
    try {
      final type = obj.runtimeType.toString();
      return type.contains('Request') || type.contains('Model') || type.contains('Response') || type.contains('Entity');
    } catch (e) {
      return false;
    }
  }

  void _logPrint(String s) {
    // Use debugPrint for better handling in Flutter
    // This ensures logs are visible even in release mode in debug builds
    debugPrint(s, wrapWidth: 1024);
  }
}
