import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../shared/config/app_runtime_config_loader.dart';

class BackendApiClient {
  BackendApiClient({
    String? apiBaseUrl,
    http.Client? client,
  })  : _apiBaseUrl = _normalizeBaseUrl(
          apiBaseUrl ?? const AppRuntimeConfigLoader().load().apiBaseUrl,
        ),
        _client = client ?? http.Client();

  final String? _apiBaseUrl;
  final http.Client _client;

  bool get isConfigured => _apiBaseUrl != null;

  Future<List<Map<String, dynamic>>> getCollection(
    String path,
    String collectionKey,
  ) async {
    final response = await _send('GET', path);
    final collection = response[collectionKey];
    if (collection is! List) {
      return const [];
    }

    return collection
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getObject(String path) async {
    final response = await _send('GET', path);
    return response;
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _send('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final baseUrl = _apiBaseUrl;
    if (baseUrl == null) {
      throw StateError('API base URL is not configured');
    }

    final uri = Uri.parse(baseUrl).resolve(path);
    final response = await _client.send(
      http.Request(method, uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Content-Type'] = 'application/json'
        ..body = body == null ? '' : jsonEncode(body),
    );

    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 400) {
      throw StateError(
        'API $method $path failed with ${response.statusCode}: $responseBody',
      );
    }

    if (responseBody.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return {'data': decoded};
  }

  static String? _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
