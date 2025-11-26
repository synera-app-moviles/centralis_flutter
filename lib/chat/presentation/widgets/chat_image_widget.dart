import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/chat_image.dart';

/// Widget para mostrar una imagen en el chat
class ChatImageWidget extends StatelessWidget {
  final ChatImage image;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSenderInfo;

  const ChatImageWidget({
    super.key,
    required this.image,
    this.onTap,
    this.onLongPress,
    this.showSenderInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostrar información del remitente si es necesario
          if (showSenderInfo) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                image.senderId,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
          
          // Imagen principal
          GestureDetector(
            onTap: onTap ?? () => _showFullScreenImage(context),
            onLongPress: onLongPress,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 250,
                maxHeight: 300,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 250,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 250,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              _formatTime(image.sentAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${dateTime.day}/${dateTime.month} ${_formatTimeOnly(dateTime)}';
    } else {
      return _formatTimeOnly(dateTime);
    }
  }

  String _formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(image: image),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Widget para mostrar la imagen en pantalla completa
class _FullScreenImageView extends StatelessWidget {
  final ChatImage image;

  const _FullScreenImageView({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Enviado ${_formatDate(image.sentAt)}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implementar compartir imagen
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: CachedNetworkImage(
            imageUrl: image.imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '${dateTime.day} de $month a las $hour:$minute';
  }
}