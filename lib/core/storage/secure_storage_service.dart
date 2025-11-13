import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../constants/api_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.jwtTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.jwtTokenKey);
  }

  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Decode(base64.normalize(parts[1])))
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      return DateTime.now().millisecondsSinceEpoch > (exp * 1000);
    } catch (e) {
      return true;
    }
  }

  // User data management  
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: ApiConstants.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: ApiConstants.userIdKey);
  }

  Future<void> saveUsername(String username) async {
    await _storage.write(key: ApiConstants.usernameKey, value: username);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: ApiConstants.usernameKey);
  }

  // Clear all data (logout)
  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}