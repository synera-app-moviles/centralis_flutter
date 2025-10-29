import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/routes/route_names.dart';

/// Sign Up page with complete registration form
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedPosition;
  String? _selectedDepartment;
  bool _isLoading = false;

  // Mock data for dropdowns
  final List<String> _positions = [
    'Software Engineer',
    'Senior Software Engineer',
    'Tech Lead',
    'Product Manager',
    'Designer',
    'DevOps Engineer',
  ];

  final List<String> _departments = [
    'Engineering',
    'Product',
    'Design',
    'Marketing',
    'Sales',
    'HR',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle sign up button tap
  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Navigate to home on success
          Navigator.pushReplacementNamed(context, RouteNames.home);
        }
      });
    }
  }

  /// Navigate back to sign in
  void _navigateToSignIn() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      body: SafeArea(
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
                        // Header
                        _buildHeader(),
                        const SizedBox(height: 20),
                        
                        // Title
                        Text(
                          'Create your account',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        
                        // Avatar section
                        _buildAvatarSection(),
                        const SizedBox(height: 24),
                        
                        // Form fields
                        _buildInputField(
                          label: 'Username',
                          controller: _usernameController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInputField(
                          label: 'Name',
                          controller: _nameController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInputField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInputField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value!)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Position dropdown
                        _buildDropdown(
                          label: 'Position',
                          value: _selectedPosition,
                          items: _positions,
                          onChanged: (value) {
                            setState(() {
                              _selectedPosition = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Department dropdown
                        _buildDropdown(
                          label: 'Department',
                          value: _selectedDepartment,
                          items: _departments,
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInputField(
                          label: 'Password',
                          controller: _passwordController,
                          isPassword: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Password is required';
                            }
                            if (value!.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInputField(
                          label: 'Confirm Password',
                          controller: _confirmPasswordController,
                          isPassword: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Navigation row
                        _buildNavigationRow(),
                        const SizedBox(height: 24),
                        
                        // Sign up button
                        _buildSignUpButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Centralis',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CentralisColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: CentralisColors.placeholder,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: CentralisColors.placeholder,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: CentralisColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: CentralisColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CentralisColors.onBackground,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: CentralisColors.inputText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(
              color: CentralisColors.placeholder,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CentralisColors.onBackground,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: CentralisColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Select $label',
                style: const TextStyle(
                  color: CentralisColors.placeholder,
                  fontSize: 16,
                ),
              ),
              dropdownColor: CentralisColors.background,
              style: const TextStyle(
                color: CentralisColors.inputText,
                fontSize: 16,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRow() {
    return Row(
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(
            color: CentralisColors.placeholder,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _navigateToSignIn,
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: CentralisColors.linkText,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        child: _isLoading
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
            : const Text('Create Account'),
      ),
    );
  }
}
