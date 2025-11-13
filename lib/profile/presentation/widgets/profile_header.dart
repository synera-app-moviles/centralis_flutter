import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/routes/route_names.dart';

/// Profile header with title and notifications icon
class ProfileHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const ProfileHeader({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onNotificationTap ?? () {
                  // Navigate to notifications page
                  Navigator.pushNamed(context, RouteNames.notifications);
                },
                icon: const Icon(
                  Icons.notifications,
                  color: CentralisColors.onBackground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}