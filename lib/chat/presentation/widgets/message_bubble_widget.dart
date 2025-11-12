import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../theme/chat_colors.dart';

/// Widget para mostrar una burbuja de mensaje
class MessageBubbleWidget extends StatelessWidget {
  final MessageResponse message;
  final bool isMyMessage;
  final String? senderAvatarUrl;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.senderAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMyMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: _buildMessageBubble(),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            _buildMessageStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 14,
      backgroundColor: ChatColors.cardBackground,
      backgroundImage: senderAvatarUrl != null
          ? NetworkImage(senderAvatarUrl!)
          : null,
      child: senderAvatarUrl == null
          ? Text(
              message.senderUsername.isNotEmpty 
                  ? message.senderUsername[0].toUpperCase() 
                  : 'U',
              style: const TextStyle(
                color: ChatColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMyMessage ? ChatColors.bubbleMine : ChatColors.bubbleOther,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isMyMessage 
              ? const Radius.circular(12) 
              : const Radius.circular(4),
          bottomRight: isMyMessage 
              ? const Radius.circular(4) 
              : const Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMyMessage && message.senderUsername.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                message.senderUsername,
                style: const TextStyle(
                  color: ChatColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            message.body,
            style: const TextStyle(
              color: ChatColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.sentAt),
                style: TextStyle(
                  color: ChatColors.textSecondary.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              if (message.editedAt != null)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'editado',
                    style: TextStyle(
                      color: ChatColors.textSecondary,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    IconData statusIcon;
    Color statusColor;

    switch (message.status) {
      case 'SENT':
        statusIcon = Icons.check;
        statusColor = ChatColors.textSecondary;
        break;
      case 'DELIVERED':
        statusIcon = Icons.done_all;
        statusColor = ChatColors.textSecondary;
        break;
      case 'READ':
        statusIcon = Icons.done_all;
        statusColor = ChatColors.accent;
        break;
      default:
        statusIcon = Icons.access_time;
        statusColor = ChatColors.textSecondary;
    }

    return Icon(
      statusIcon,
      size: 14,
      color: statusColor,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}