class ApiConstants {
  // 🌐 CAMBIA ESTA URL POR LA DE TU WEB SERVICE
  static const String baseUrl = 'https://web-services-okt8.onrender.com/api/v1';
  
  // Auth endpoints
  static const String signIn = '/auth/sign-in';
  static const String signUp = '/auth/sign-up';
  
  // Profile endpoints  
  static const String profiles = '/profiles';
  static const String profileById = '/profiles/{id}';
  static const String profileByUser = '/profiles/user/{userId}';

  //TODO: endpoints announcements

  //TODO: endpoints events

  //TODO: endpoints chat

  //TODO: endpoints notifications
  
  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
}