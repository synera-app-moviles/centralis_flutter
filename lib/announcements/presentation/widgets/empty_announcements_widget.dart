import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

class EmptyAnnouncementsWidget extends StatelessWidget {
  const EmptyAnnouncementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: AnnouncementColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No announcements yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first announcement',
            style: TextStyle(
              color: AnnouncementColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}