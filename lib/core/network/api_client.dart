import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  final String baseUrl;
  final SecureStorageService storage;

  ApiClient({
    required this.baseUrl,
    required this.storage,
  });

  Uri _buildUri(String endpoint, [Map<String, dynamic>? query]) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$cleanBase$cleanEndpoint').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  // dart
  Future<Map<String, String>> _headers({bool requireAuth = false}) async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (requireAuth) {
      final token = await storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
    bool requireAuth = false,
  }) async {
    final uri = _buildUri(endpoint, query);
    final response = await http
        .get(uri, headers: await _headers(requireAuth: requireAuth))
        .timeout(ApiConstants.connectTimeout);
    _throwIfError(response);
    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    Object? body,
    bool requireAuth = false,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await http
        .post(
          uri,
          headers: await _headers(requireAuth: requireAuth),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(ApiConstants.connectTimeout);
    _throwIfError(response);
    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    Object? body,
    bool requireAuth = false,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await http
        .put(
          uri,
          headers: await _headers(requireAuth: requireAuth),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(ApiConstants.connectTimeout);
    _throwIfError(response);
    return response;
  }

  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await http
        .delete(
          uri,
          headers: await _headers(requireAuth: requireAuth),
        )
        .timeout(ApiConstants.connectTimeout);
    _throwIfError(response);
    return response;
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 400) {
      if (response.statusCode == 401) {
        // Opcional: manejar sesión expirada
      }
      throw HttpException(
        'Error ${response.statusCode}: ${response.body}',
        uri: response.request?.url,
      );
    }
  }
}