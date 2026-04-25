import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:consulting_fe/services/device_service.dart';

class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  static const String baseUrl =
      'https://consulting-production-2926.up.railway.app';

  static void Function()? onSessionExpired;

  Future<Map<String, String>> _headers() async {
    final uuid = await DeviceService.getDeviceId();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-User-UUID': uuid,
    };
  }

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    return _handle(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode == 401) {
      onSessionExpired?.call();
      throw ApiException(401, 'Unauthorized');
    }
    if (response.statusCode >= 400) {
      String detail = response.body;
      try {
        detail = (jsonDecode(response.body) as Map)['detail'] as String? ?? detail;
      } catch (_) {}
      throw ApiException(response.statusCode, detail);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
