import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../core/di/service_locator.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../widgets/comment_card.dart';
import '../../data/models/announcement.dart';
import '../../data/models/priority.dart';
import 'edit_announcement_page.dart';

class AnnouncementDetailPage extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailPage({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCreator = false; // TODO: Get from current user

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementBloc>()
        ..add(AnnouncementLoadByIdRequested(announcementId: widget.announcementId)),
      child: Scaffold(
        backgroundColor: AnnouncementColors.background,
        appBar: _buildAppBar(context),
        body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            if (state is AnnouncementLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AnnouncementColors.primary,
                ),
              );
            }

            if (state is AnnouncementError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AnnouncementColors.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AnnouncementBloc>().add(
                          AnnouncementLoadByIdRequested(announcementId: widget.announcementId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AnnouncementColors.primary,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is AnnouncementDetailLoaded) {
              return _buildContent(context, state.announcement);
            }

            return const Center(
              child: Text(
                'Announcement not found',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Announcement Detail",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AnnouncementColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isCreator)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _navigateToEdit(context);
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Announcement announcement) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            announcement.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Fecha y prioridad
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(announcement.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  announcement.priority.value.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDetailDate(announcement.createdAt),
                style: const TextStyle(
                  color: AnnouncementColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Imagen si existe
          if (announcement.image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                announcement.image!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AnnouncementColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AnnouncementColors.textSecondary,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Descripción
          Text(
            announcement.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Sección de comentarios
          const Text(
            'Comments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de comentarios
          ...announcement.comments.map((comment) => CommentCard(
            comment: comment,
            canDelete: comment.employeeId == 'current-user-id', // TODO: Get from current user
            onDelete: () => _deleteComment(context, comment.id),
          )).toList(),
          
          const SizedBox(height: 16),
          
          // Input para nuevo comentario
          _buildCommentInput(context),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Write a comment...',
              hintStyle: TextStyle(color: AnnouncementColors.textSecondary),
              filled: true,
              fillColor: AnnouncementColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            style: const TextStyle(color: Colors.white),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _sendComment(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AnnouncementColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Send',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.normal:
        return Colors.blue;
    }
  }

  String _formatDetailDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  void _sendComment(BuildContext context) {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      context.read<AnnouncementBloc>().add(
        CommentCreateRequested(
          announcementId: widget.announcementId,
          employeeId: 'current-user-id', // TODO: Get from current user
          content: content,
        ),
      );
      _commentController.clear();
    }
  }

  void _deleteComment(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AnnouncementColors.cardBackground,
          title: const Text(
            'Delete Comment',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this comment?',
            style: TextStyle(color: AnnouncementColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AnnouncementColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AnnouncementBloc>().add(
                  CommentDeleteRequested(commentId: commentId),
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEdit(BuildContext context) {
    final announcement = (context.read<AnnouncementBloc>().state as AnnouncementDetailLoaded).announcement;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAnnouncementPage(announcement: announcement),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AnnouncementColors.cardBackground,
          title: const Text(
            'Delete Announcement',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this announcement? This action cannot be undone.',
            style: TextStyle(color: AnnouncementColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AnnouncementColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AnnouncementBloc>().add(
                  AnnouncementDeleteRequested(announcementId: widget.announcementId),
                );
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Regresar a lista
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}