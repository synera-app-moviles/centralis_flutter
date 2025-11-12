import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../theme/chat_colors.dart';

/// Widget para mostrar un item de chat en la lista principal
class ChatItemWidget extends StatelessWidget {
  final ChatItem chat;
  final VoidCallback onTap;

  const ChatItemWidget({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 4),
                  _buildLastMessage(),
                ],
              ),
            ),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: ChatColors.cardBackground,
          backgroundImage: chat.imageUrl != null
              ? NetworkImage(chat.imageUrl!)
              : null,
          child: chat.imageUrl == null
              ? Text(
                  chat.name.isNotEmpty ? chat.name[0].toUpperCase() : 'G',
                  style: const TextStyle(
                    color: ChatColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        if (chat.isGroup && chat.memberIds.length > 2)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: ChatColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group,
                size: 10,
                color: ChatColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            chat.name,
            style: const TextStyle(
              color: ChatColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (chat.lastMessageTime != null)
          Text(
            _formatTime(chat.lastMessageTime!),
            style: const TextStyle(
              color: ChatColors.textSecondary,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildLastMessage() {
    if (chat.lastMessage == null || chat.lastMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    final prefix = chat.lastSenderName != null ? '${chat.lastSenderName}: ' : '';
    
    return Text(
      '$prefix${chat.lastMessage}',
      style: const TextStyle(
        color: ChatColors.textSecondary,
        fontSize: 13,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (chat.unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ChatColors.unreadIndicator,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
              style: const TextStyle(
                color: ChatColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (chat.visibility == 'PRIVATE')
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.lock,
              size: 14,
              color: ChatColors.textSecondary,
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}