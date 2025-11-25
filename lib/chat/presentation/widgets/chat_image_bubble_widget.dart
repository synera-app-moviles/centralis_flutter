import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../data/models/chat_image.dart';
import '../theme/chat_colors.dart';

/// Widget para mostrar una burbuja de imagen en el chat
class ChatImageBubbleWidget extends StatefulWidget {
  final ChatImage chatImage;
  final bool isMyImage;

  const ChatImageBubbleWidget({
    super.key,
    required this.chatImage,
    required this.isMyImage,
  });

  @override
  State<ChatImageBubbleWidget> createState() => _ChatImageBubbleWidgetState();
}

class _ChatImageBubbleWidgetState extends State<ChatImageBubbleWidget> {
  ProfileModel? senderProfile;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadSenderProfile();
  }

  Future<void> _loadSenderProfile() async {
    if (!widget.isMyImage) {
      try {
        final profileRepository = sl<ProfileRepository>();
        final profile = await profileRepository.getProfileByUserId(widget.chatImage.senderId);
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
        mainAxisAlignment: widget.isMyImage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isMyImage) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: _buildImageBubble(),
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

  Widget _buildImageBubble() {
    return Column(
      crossAxisAlignment: widget.isMyImage 
          ? CrossAxisAlignment.end 
          : CrossAxisAlignment.start,
      children: [
        // Solo mostrar nombre para imágenes de otros usuarios
        if (!widget.isMyImage)
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
        
        // Burbuja de imagen
        Container(
          constraints: const BoxConstraints(
            maxWidth: 280,
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            color: widget.isMyImage 
                ? const Color(0xFF8B5CF6) // Morado para mis imágenes
                : ChatColors.bubbleOther,  // Gris para otras
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: widget.isMyImage 
                  ? const Radius.circular(16) 
                  : const Radius.circular(4),
              bottomRight: widget.isMyImage 
                  ? const Radius.circular(4) 
                  : const Radius.circular(16),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: widget.isMyImage 
                  ? const Radius.circular(16) 
                  : const Radius.circular(4),
              bottomRight: widget.isMyImage 
                  ? const Radius.circular(4) 
                  : const Radius.circular(16),
            ),
            child: GestureDetector(
              onTap: () => _showFullscreenImage(context),
              child: Image.network(
                widget.chatImage.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Error loading image',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Timestamp
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatTime(widget.chatImage.sentAt),
            style: const TextStyle(
              color: ChatColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  void _showFullscreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  _getSenderDisplayName(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              body: Center(
                child: InteractiveViewer(
                  child: Image.network(
                    widget.chatImage.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator(color: Colors.white);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSenderDisplayName() {
    if (senderProfile != null) {
      return '${senderProfile!.firstName} ${senderProfile!.lastName}';
    }
    
    // Fallback mientras carga el perfil
    return isLoadingProfile 
        ? 'Loading...' 
        : 'User';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      // Today - show only time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      // Previous days - show date
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      return '$day/$month';
    }
  }
}