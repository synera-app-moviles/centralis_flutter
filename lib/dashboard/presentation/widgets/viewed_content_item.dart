import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../data/models/user_viewed_announcement.dart';
import '../../data/models/user_viewed_event.dart';

/// Widget for displaying viewed content (announcement or event)
class ViewedContentItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime viewedAt;
  final String? subtitle; // For priority or event details
  final IconData icon;
  final VoidCallback? onTap;

  const ViewedContentItem({
    super.key,
    required this.title,
    required this.description,
    required this.viewedAt,
    this.subtitle,
    required this.icon,
    this.onTap,
  });

  /// Factory constructor for announcement
  factory ViewedContentItem.announcement({
    required UserViewedAnnouncement announcement,
    VoidCallback? onTap,
  }) {
    return ViewedContentItem(
      title: announcement.title,
      description: announcement.truncatedDescription,
      viewedAt: announcement.viewedAt,
      subtitle: announcement.priority != null ? 'Priority: ${announcement.priority}' : null,
      icon: Icons.campaign,
      onTap: onTap,
    );
  }

  /// Factory constructor for event
  factory ViewedContentItem.event({
    required UserViewedEvent event,
    VoidCallback? onTap,
  }) {
    String subtitle = event.formattedEventDate;
    if (event.location != null && event.location!.isNotEmpty) {
      subtitle += ' • ${event.location}';
    }

    return ViewedContentItem(
      title: event.title,
      description: event.truncatedDescription,
      viewedAt: event.viewedAt,
      subtitle: subtitle,
      icon: Icons.event,
      onTap: onTap,
    );
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Icon(
                    icon,
                    color: CentralisColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: CentralisColors.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: TextStyle(
                  color: CentralisColors.onBackground.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Subtitle and viewed date
              Row(
                children: [
                  if (subtitle != null) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CentralisColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            color: CentralisColors.onBackground.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Viewed date
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility,
                        color: CentralisColors.onBackground.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatViewedDate(viewedAt),
                        style: TextStyle(
                          color: CentralisColors.onBackground.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format viewed date for display
  String _formatViewedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}