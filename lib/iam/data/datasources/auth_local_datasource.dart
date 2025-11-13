import '../../../core/storage/secure_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
  Future<bool> isLoggedIn();
  Future<void> clearAllData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _storage;

  AuthLocalDataSourceImpl({required SecureStorageService storage})
      : _storage = storage;

  @override
  Future<void> saveToken(String token) async {
    await _storage.saveToken(token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  @override
  Future<void> saveUserId(String userId) async {
    await _storage.saveUserId(userId);
  }

  @override
  Future<String?> getUserId() async {
    return await _storage.getUserId();
  }

  @override
  Future<void> saveUsername(String username) async {
    await _storage.saveUsername(username);
  }

  @override
  Future<String?> getUsername() async {
    return await _storage.getUsername();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    if (token == null) return false;
    
    final isExpired = await _storage.isTokenExpired();
    return !isExpired;
  }

  @override
  Future<void> clearAllData() async {
    await _storage.clearAllData();
  }
}