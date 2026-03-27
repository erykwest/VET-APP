import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_runtime_config_loader.dart';

class BackendApiClient {
  BackendApiClient({
    AppRuntimeConfigLoader? configLoader,
    http.Client? httpClient,
  })  : _configLoader = configLoader ?? const AppRuntimeConfigLoader(),
        _httpClient = httpClient ?? http.Client();

  final AppRuntimeConfigLoader _configLoader;
  final http.Client _httpClient;

  bool get isConfigured => _configLoader.load().hasApiBaseUrl;

  Future<List<Map<String, dynamic>>> getCollection(
    String path,
    String collectionKey,
  ) async {
    final payload = await getJson(path);
    if (payload is Map<String, dynamic>) {
      final collection = payload[collectionKey];
      if (collection is List) {
        return collection
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList(growable: false);
      }
      return const [];
    }

    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);
    }

    return const [];
  }

  Future<Map<String, dynamic>> getObject(String path) async {
    final payload = await getJson(path);
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final payload = await _sendJson(
      method: 'POST',
      path: path,
      body: body,
    );
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final payload = await _sendJson(
      method: 'PUT',
      path: path,
      body: body,
    );
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    return const <String, dynamic>{};
  }

  Future<dynamic> getJson(String path) async {
    final response = await _httpClient.get(
      _buildUri(path),
      headers: _jsonHeaders,
    );
    return _decodeResponse(response);
  }

  Uri _buildUri(String path) {
    final baseUrl = _configLoader.load().apiBaseUrl.trim();
    if (baseUrl.isEmpty) {
      throw StateError('API base url is not configured');
    }

    return Uri.parse(baseUrl).resolve(path);
  }

  Future<dynamic> _sendJson({
    required String method,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final uri = _buildUri(path);
    final encodedBody = jsonEncode(body);
    final response = switch (method) {
      'POST' => await _httpClient.post(
          uri,
          headers: _jsonHeaders,
          body: encodedBody,
        ),
      'PUT' => await _httpClient.put(
          uri,
          headers: _jsonHeaders,
          body: encodedBody,
        ),
      _ => throw ArgumentError.value(method, 'method'),
    };
    return _decodeResponse(response);
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Backend request failed with ${response.statusCode}: ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    return jsonDecode(response.body);
  }

  Map<String, String> get _jsonHeaders => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
}
