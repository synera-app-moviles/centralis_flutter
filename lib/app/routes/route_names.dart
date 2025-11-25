/// Route names for navigation throughout the app
class RouteNames {
  // Auth routes
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';
  
  // Main app routes  
  static const String home = '/home';
  static const String announcements = '/announcements';
  static const String events = '/events';
  static const String chat = '/chat';
  static const String profile = '/profile';
  
  // Chat specific routes
  static const String chatDetail = '/chat/detail';
  static const String createGroup = '/chat/create-group';
  static const String editGroup = '/chat/edit-group';
  
  // Secondary routes
  static const String editProfile = '/editProfile';
  static const String notifications = '/notifications';
  static const String splash = '/splash';

  // Event routes
  static const String createEvent = '/events/create';
  static const String updateEvent = '/events/update';
  static const String eventDetails = '/events/details';

  // Dashboard routes
  static const String dashboard = '/dashboard';
  static const String userViewsDetail = '/dashboard/user-views';
}
