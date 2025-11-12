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

  // Chat endpoints
  static const String chatGroups = '/groups';
  static const String chatGroupById = '/groups/{groupId}';
  static const String chatGroupsByUser = '/groups';
  static const String chatGroupsByVisibility = '/groups/visibility/{visibility}';
  static const String chatGroupMessages = '/groups/{groupId}/messages';
  static const String chatMessageById = '/groups/{groupId}/messages/{messageId}';
  static const String chatGroupMembers = '/groups/{groupId}/members';
  static const String chatGroupVisibility = '/groups/{groupId}/visibility';

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