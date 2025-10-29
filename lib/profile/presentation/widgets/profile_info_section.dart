import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// Profile information display section with avatar and basic info
class ProfileInfoSection extends StatelessWidget {
  final Map<String, String> userProfile;

  const ProfileInfoSection({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CentralisColors.background,
              border: Border.all(
                color: CentralisColors.placeholder,
                width: 2,
              ),
            ),
            child: userProfile['avatarUrl']?.isEmpty ?? true
                ? const Icon(
                    Icons.person,
                    size: 64,
                    color: CentralisColors.placeholder,
                  )
                : ClipOval(
                    child: Image.network(
                      userProfile['avatarUrl']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 64,
                          color: CentralisColors.placeholder,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          
          // Full name
          Text(
            '${userProfile['name']} ${userProfile['lastName']}',
            style: const TextStyle(
              color: CentralisColors.onBackground,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Email
          Text(
            userProfile['email']!,
            style: const TextStyle(
              color: CentralisColors.placeholder,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          
        ],
      ),
    );
  }
}