import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/routes/route_names.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_input_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Sign In page with Centralis styling
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle sign in button tap using real API
  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      // Get the AuthBloc and dispatch sign in event
      final authBloc = context.read<AuthBloc>();
      
      // Dispatch the event with username and password
      authBloc.add(AuthSignInRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  /// Navigate to sign up page
  void _navigateToSignUp() {
    Navigator.pushNamed(context, RouteNames.signUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to home when authentication is successful
            Navigator.pushReplacementNamed(context, RouteNames.home);
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Update loading state based on AuthState
            final isLoading = state is AuthLoading;
            
            return SafeArea(
              child: Column(
                children: [
                  // Main content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: CentralisColors.secondary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with logo/title
                              const AuthHeader(),
                              const SizedBox(height: 20),
                              
                              // Sign in title
                              Text(
                                'Sign in to your account',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 32),
                              
                              // Username field
                              AuthInputField(
                                label: 'Username',
                                controller: _usernameController,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Password field
                              AuthInputField(
                                label: 'Password',
                                controller: _passwordController,
                                isPassword: true,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              // Navigation to sign up
                              _buildNavigationRow(),
                              const SizedBox(height: 24),
                              
                              // Sign in button
                              _buildSignInButton(isLoading),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationRow() {
    return Row(
      children: [
        const Text(
          'New to Centralis?',
          style: TextStyle(
            color: CentralisColors.placeholder,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _navigateToSignUp,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: CentralisColors.linkText,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSignIn,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CentralisColors.onPrimary,
                  ),
                ),
              )
            : const Text('Sign In'),
      ),
    );
  }
}
