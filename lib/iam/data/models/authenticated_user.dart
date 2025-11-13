import 'dart:convert';

class AuthenticatedUser {
  final String id;
  final String username;
  final String token;

  const AuthenticatedUser({
    required this.id,
    required this.username, 
    required this.token,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'token': token,
  };

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) => AuthenticatedUser(
    id: json['id'] as String,
    username: json['username'] as String,
    token: json['token'] as String,
  );

  // Utility method to check token expiration
  bool get isTokenExpired {
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
}