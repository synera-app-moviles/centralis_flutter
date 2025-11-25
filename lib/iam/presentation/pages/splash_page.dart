import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/routes/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Splash/Loading page - shown when app starts
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  /// Check if user is already authenticated
  void _checkAuthenticationStatus() {
    // Dispatch event to check if user is logged in
    context.read<AuthBloc>().add(AuthCheckStatusRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is logged in, navigate to home
          Navigator.pushReplacementNamed(context, RouteNames.home);
        } else if (state is AuthUnauthenticated) {
          // User is not logged in, navigate to sign in
          Navigator.pushReplacementNamed(context, RouteNames.signIn);
        } else if (state is AuthError) {
          // Error occurred, navigate to sign in
          Navigator.pushReplacementNamed(context, RouteNames.signIn);
        }
        // If AuthLoading or AuthInitial, stay on splash screen
      },
      child: Scaffold(
      backgroundColor: CentralisColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: CentralisColors.primary,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.business,
                size: 60,
                color: CentralisColors.onPrimary,
              ),
            ),
            const SizedBox(height: 32),
            
            // App name
            Text(
              'Centralis',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Employee Management Platform',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CentralisColors.placeholder,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CentralisColors.primary),
            ),
          ],
        ),
        ),
      ),
    );
  }
}