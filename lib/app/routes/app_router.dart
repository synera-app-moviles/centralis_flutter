import 'package:flutter/material.dart';
import '../../chat/presentation/pages/pages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../iam/presentation/pages/sign_in_page.dart';
import '../../iam/presentation/pages/sign_up_page.dart';
import '../../iam/presentation/pages/splash_page.dart';
import '../../profile/presentation/pages/edit_profile_page.dart';
import '../../events/presentation/pages/create_event_page.dart';
import '../../events/presentation/pages/update_event_page.dart';
import '../../events/presentation/pages/event_details_page.dart';
import '../../notifications/presentation/pages/notifications_page.dart';
import '../../notifications/presentation/bloc/notification_bloc.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../dashboard/presentation/pages/user_views_detail_page.dart';
import '../../dashboard/presentation/pages/content_stats_page.dart';
import '../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../core/di/service_locator.dart';
import '../navigation/main_navigation.dart';
import 'route_names.dart';

/// Professional route generator using onGenerateRoute pattern
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Analyze route name and build appropriate page
    switch (settings.name) {
      // Initial splash/loading page
      case '/':
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      // Auth routes
      case RouteNames.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());

      case RouteNames.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());

      // Main app with bottom navigation
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const MainNavigation());

      // Individual tab routes (accessible directly)
      case RouteNames.announcements:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialTab: 0),
        );

      case RouteNames.events:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialTab: 1),
        );

      case RouteNames.chat:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialTab: 2),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialTab: 3),
        );

      // Profile editing route
      case RouteNames.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
        );

      // Rutas de eventos
      case RouteNames.createEvent:
        return MaterialPageRoute(
          builder: (_) => const CreateEventPage(),
        );

      case RouteNames.updateEvent:
        final eventId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => UpdateEventPage(eventId: eventId),
        );

      case RouteNames.eventDetails:
        final eventId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EventDetailsPage(eventId: eventId),
        );


      
      // Chat specific routes
      case RouteNames.chatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('groupId') && args.containsKey('groupName')) {
          return MaterialPageRoute(
            builder: (_) => ChatDetailView(
              groupId: args['groupId'] as String,
              groupName: args['groupName'] as String,
            ),
          );
        }
        return _errorRoute(settings.name);
      
      case RouteNames.createGroup:
        return MaterialPageRoute(
          builder: (_) => const CreateGroupView(),
        );
      
      case RouteNames.editGroup:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('groupId')) {
          return MaterialPageRoute(
            builder: (_) => EditGroupView(
              groupId: args['groupId'] as String,
            ),
          );
        }
        return _errorRoute(settings.name);
      
      // Dashboard routes
      case RouteNames.dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<DashboardBloc>(),
            child: const DashboardPage(),
          ),
        );

      case RouteNames.userViewsDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && 
            args.containsKey('userId') && 
            args.containsKey('userFullName')) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<DashboardBloc>(),
              child: UserViewsDetailPage(
                userId: args['userId'] as String,
                userFullName: args['userFullName'] as String,
              ),
            ),
          );
        }
        return _errorRoute(settings.name);

      case RouteNames.contentStats:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && 
            args.containsKey('contentId') && 
            args.containsKey('contentType') &&
            args.containsKey('contentTitle')) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<DashboardBloc>(),
              child: ContentStatsPage(
                contentId: args['contentId'] as String,
                contentType: args['contentType'] as String,
                contentTitle: args['contentTitle'] as String,
              ),
            ),
          );
        }
        return _errorRoute(settings.name);
      
      // Notifications route
      case RouteNames.notifications:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<NotificationBloc>(),
            child: const NotificationsPage(),
          ),
        );

      // Route not found
      default:
        return _errorRoute(settings.name);
    }
  }

  /// Error route for unknown paths
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Ruta: ${routeName ?? "desconocida"}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.signIn,
                    (route) => false,
                  );
                },
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
