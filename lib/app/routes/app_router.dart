import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../iam/presentation/pages/sign_in_page.dart';
import '../../iam/presentation/pages/sign_up_page.dart';
import '../../iam/presentation/pages/splash_page.dart';
import '../../profile/presentation/pages/edit_profile_page.dart';
import '../../notifications/presentation/pages/notifications_page.dart';
import '../../notifications/presentation/bloc/notification_bloc.dart';
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
