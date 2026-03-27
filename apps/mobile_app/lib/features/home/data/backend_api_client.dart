import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/config/app_runtime_config_loader.dart';

class BackendApiException implements Exception {
  const BackendApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (status $statusCode)';
    final bodySuffix =
        body == null || body!.trim().isEmpty ? '' : ': $body';
    return 'BackendApiException$status: $message$bodySuffix';
  }
}

class BackendApiClient {
  const BackendApiClient();

  Future<Map<String, dynamic>> getJson(String path) {
    return _request('GET', path);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
  }) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? body,
  }) {
    return _request('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? body,
  }) async {
    final uri = _resolveUri(path);
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    Object? payload;
    if (body != null) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
      payload = jsonEncode(body);
    }

    final response = switch (method) {
      'GET' => await http.get(uri, headers: headers),
      'POST' => await http.post(uri, headers: headers, body: payload),
      'PUT' => await http.put(uri, headers: headers, body: payload),
      _ => throw ArgumentError.value(method, 'method'),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendApiException(
        'Request failed for $method $path',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    if (response.body.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw BackendApiException(
      'Unexpected JSON shape for $method $path',
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Uri _resolveUri(String path) {
    final config = const AppRuntimeConfigLoader().load();
    final baseUrl = config.apiBaseUrl.trim();
    if (baseUrl.isEmpty) {
      throw const BackendApiException('API base URL non configurato');
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath =
        path.startsWith('/') ? path.substring(1) : path.trim();
    return Uri.parse('$normalizedBase/$normalizedPath');
  }
}
