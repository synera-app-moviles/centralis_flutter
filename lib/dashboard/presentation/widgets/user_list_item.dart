import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../profile/data/models/enums.dart';
import '../../data/models/dashboard_user.dart';

/// Widget for displaying a user item in the dashboard list
class UserListItem extends StatelessWidget {
  final DashboardUser user;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: CentralisColors.secondary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: CentralisColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 30,
                backgroundColor: CentralisColors.primary,
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? Text(
                        _getInitials(user.userFullName),
                        style: const TextStyle(
                          color: CentralisColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full name
                    Text(
                      user.userFullName,
                      style: const TextStyle(
                        color: CentralisColors.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      user.userEmail,
                      style: TextStyle(
                        color: CentralisColors.onBackground.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Department and position
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CentralisColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CentralisColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${user.userDepartment.displayName} • ${user.userPosition.displayName}',
                        style: const TextStyle(
                          color: CentralisColors.onBackground,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: CentralisColors.onBackground.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Extract initials from full name
  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    }
    return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
  }
}