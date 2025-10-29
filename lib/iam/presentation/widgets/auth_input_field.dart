import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// Reusable input field widget for auth forms
class AuthInputField extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
}