import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiHelper {
  static Map<String, String> getDefaultHeader() {
    return {
      'Content-type': 'application/json;charset=UTF-8',
      'Accept': 'application/json;charset=UTF-8',
    };
  }

  /// Method post
  /// [path] path url api
  /// [headers] headers methods get
  /// [params] params of request
  static Future<http.Response> post({
    required String path,
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? customBaseApi,
  }) async {
    return http
        .post(
      Uri.parse("$customBaseApi/$path").resolveUri(Uri(
        queryParameters: params,
      )),
      headers: headers,
      body: jsonEncode(body ?? {}),
    )
        .timeout(const Duration(seconds: 45), onTimeout: () {
      return responseTimeoutHttp();
    });
  }

  static http.Response responseTimeoutHttp() {
    return http.Response(
        jsonEncode({'timeout': true}), HttpStatus.requestTimeout);
  }
}
