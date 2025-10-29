import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/routes/route_names.dart';

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
    _navigateToSignIn();
  }

  /// Navigate to sign in after a brief delay
  void _navigateToSignIn() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.signIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}