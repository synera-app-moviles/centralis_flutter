import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// Reusable input field widget for auth forms
class AuthInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.validator,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: CentralisColors.onBackground,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: const TextStyle(
            color: CentralisColors.inputText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: const TextStyle(
              color: CentralisColors.placeholder,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: CentralisColors.placeholder,
                    ),
                    onPressed: _togglePasswordVisibility,
                  )
                : null,
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}