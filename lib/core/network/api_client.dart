import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../storage/secure_storage_service.dart';
import '../error/exceptions.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final String baseUrl;
  final SecureStorageService _storage;

  ApiClient({required this.baseUrl, required SecureStorageService storage})
      : _storage = storage;

  // Headers builder with JWT token
  Future<Map<String, String>> _buildHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _storage.getToken();
      print('🔐 ApiClient: Token requerido. Token encontrado: ${token != null ? "✅ SÍ (${token.substring(0, 20)}...)" : "❌ NO"}');
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        print('🔐 ApiClient: Header Authorization agregado');
      } else {
        print('❌ ApiClient: No se encontró token de autenticación');
        throw UnauthorizedException('No authentication token found');
      }
    }

    return headers;
  }

  // Generic HTTP methods
  Future<http.Response> post(String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(requireAuth: requireAuth);
      
      print('🚀 ApiClient POST: URL completa: $url');
      print('🚀 ApiClient POST: Headers: $headers');
      if (body != null) {
        final bodyString = jsonEncode(body);
        print('🚀 ApiClient POST: Body: $bodyString');
      }
      
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    }
  }

  Future<http.Response> get(String endpoint, {bool requireAuth = false}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 ApiClient GET: ${url.toString()}');
      print('🔐 ApiClient GET: Requiere auth: $requireAuth');
      
      final headers = await _buildHeaders(requireAuth: requireAuth);
      print('📋 ApiClient GET: Headers: ${headers.keys.join(", ")}');
      
      final response = await http.get(url, headers: headers).timeout(ApiConstants.connectTimeout);
      print('📡 ApiClient GET: Respuesta recibida - Status: ${response.statusCode}');
      print('📡 ApiClient GET: Respuesta body (primeros 200 chars): ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
      
      return _handleResponse(response);
    } on SocketException {
      print('❌ ApiClient GET: Error de conexión - No internet connection');
      throw NetworkException('No internet connection');
    } on TimeoutException {
      print('❌ ApiClient GET: Error de timeout');
      throw NetworkException('Request timeout');
    } catch (e) {
      print('❌ ApiClient GET: Error inesperado: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(requireAuth: requireAuth);
      
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    }
  }

  Future<http.Response> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(requireAuth: requireAuth);
      
      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    }
  }

  // Response handler with error mapping
  http.Response _handleResponse(http.Response response) {
    print('🌐 ApiClient: Response status: ${response.statusCode}');
    print('🌐 ApiClient: Response body: ${response.body}');
    
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 400:
        throw BadRequestException(_getErrorMessage(response));
      case 401:
        final errorMessage = _getErrorMessage(response);
        print('🔒 ApiClient: 401 Error details: $errorMessage');
        throw UnauthorizedException('Authentication failed: $errorMessage');
      case 403:
        throw ForbiddenException('Access denied');
      case 404:
        throw NotFoundException('Resource not found');
      case 409:
        throw ConflictException(_getErrorMessage(response));
      case 500:
        throw ServerException('Internal server error');
      default:
        throw ServerException('Unknown error: ${response.statusCode}');
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? 'Unknown error';
    } catch (e) {
      return 'Error parsing response';
    }
  }
}