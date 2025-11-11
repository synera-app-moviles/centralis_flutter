import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../data/models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onDelete;
  final bool canDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onDelete,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AnnouncementColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha y opciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comment.employeeId, // En producción sería el nombre real
                  style: const TextStyle(
                    color: AnnouncementColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatCommentDate(comment.createdAt),
                      style: const TextStyle(
                        color: AnnouncementColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (canDelete && onDelete != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Contenido del comentario
            Text(
              comment.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}