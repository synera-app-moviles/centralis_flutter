import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../data/models/models.dart';
import '../theme/chat_colors.dart';

/// Widget para mostrar una burbuja de mensaje
class MessageBubbleWidget extends StatefulWidget {
  final MessageResponse message;
  final bool isMyMessage;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
  });

  @override
  State<MessageBubbleWidget> createState() => _MessageBubbleWidgetState();
}

class _MessageBubbleWidgetState extends State<MessageBubbleWidget> {
  ProfileModel? senderProfile;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadSenderProfile();
  }

  Future<void> _loadSenderProfile() async {
    if (!widget.isMyMessage) {
      try {
        final profileRepository = sl<ProfileRepository>();
        final profile = await profileRepository.getProfileByUserId(widget.message.senderId);
        if (mounted) {
          setState(() {
            senderProfile = profile;
            isLoadingProfile = false;
          });
        }
      } catch (error) {
        print('❌ Error loading sender profile: $error');
        if (mounted) {
          setState(() {
            isLoadingProfile = false;
          });
        }
      }
    } else {
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: widget.isMyMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isMyMessage) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: _buildMessageBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = senderProfile?.avatarUrl;
    final senderName = _getSenderDisplayName();
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: ChatColors.cardBackground,
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(
              senderName.isNotEmpty 
                  ? senderName[0].toUpperCase() 
                  : 'U',
              style: const TextStyle(
                color: ChatColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageBubble() {
    return Column(
      crossAxisAlignment: widget.isMyMessage 
          ? CrossAxisAlignment.end 
          : CrossAxisAlignment.start,
      children: [
        // Solo mostrar nombre para mensajes de otros usuarios
        if (!widget.isMyMessage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _getSenderDisplayName(),
              style: const TextStyle(
                color: ChatColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        // Burbuja de mensaje
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isMyMessage 
                ? const Color(0xFF8B5CF6) // Morado para mis mensajes
                : ChatColors.bubbleOther,  // Gris para otros
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: widget.isMyMessage 
                  ? const Radius.circular(16) 
                  : const Radius.circular(4),
              bottomRight: widget.isMyMessage 
                  ? const Radius.circular(4) 
                  : const Radius.circular(16),
            ),
          ),
          child: Text(
            widget.message.body,
            style: TextStyle(
              color: widget.isMyMessage 
                  ? Colors.white 
                  : ChatColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _getSenderDisplayName() {
    if (senderProfile != null) {
      return '${senderProfile!.firstName} ${senderProfile!.lastName}';
    }
    
    // Fallback mientras carga el perfil
    return isLoadingProfile 
        ? 'Cargando...' 
        : 'Usuario';
  }
}