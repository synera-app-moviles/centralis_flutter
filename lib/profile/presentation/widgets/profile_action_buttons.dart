import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// Profile action buttons (Edit Profile, Sign Out)
class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;
  final bool isLoading;

  const ProfileActionButtons({
    super.key,
    required this.onEditProfile,
    required this.onSignOut,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: CentralisColors.primary,
                foregroundColor: CentralisColors.onPrimary,
              ),
              child: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF332149),
                foregroundColor: CentralisColors.onBackground,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CentralisColors.onBackground,
                        ),
                      ),
                    )
                  : const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}