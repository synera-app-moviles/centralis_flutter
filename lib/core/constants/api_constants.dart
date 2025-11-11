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

  // Announcement endpoints
  static const String announcements = '/announcements';
  static const String announcementById = '/announcements/{announcementId}';
  static const String announcementsByPriority = '/announcements/priority/{priority}';
  static const String announcementsByCreator = '/announcements/creator/{createdBy}';
  static const String announcementComments = '/announcements/{announcementId}/comments';
  static const String commentById = '/comments/{commentId}';

  //TODO: endpoints events

  //TODO: endpoints chat

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String notificationById = '/notifications/{notificationId}';
  static const String notificationsByUser = '/notifications/{userId}';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
}