import 'package:flutter/material.dart';
import '../theme/chat_colors.dart';

/// Header personalizado para las vistas de chat
class ChatHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const ChatHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: ChatColors.background,
        border: Border(
          bottom: BorderSide(
            color: ChatColors.cardBackground,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: ChatColors.textPrimary,
                size: 24,
              ),
            ),
            if (avatarUrl != null) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: ChatColors.cardBackground,
                backgroundImage: NetworkImage(avatarUrl!),
                child: avatarUrl == null
                    ? Text(
                        title.isNotEmpty ? title[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: ChatColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ChatColors.titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: ChatColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}