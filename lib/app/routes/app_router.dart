import 'package:flutter/material.dart';
import '../../iam/presentation/pages/sign_in_page.dart';
import '../../iam/presentation/pages/sign_up_page.dart';
import '../../iam/presentation/pages/splash_page.dart';
import '../../profile/presentation/pages/edit_profile_page.dart';
import '../../events/presentation/pages/create_event_page.dart';
import '../../events/presentation/pages/update_event_page.dart';
import '../../events/presentation/pages/event_details_page.dart';
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
