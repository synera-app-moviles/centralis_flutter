import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/theme/colors.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../../data/models/comment.dart';
import 'comment_card.dart';

class CommentsSection extends StatefulWidget {
  final String announcementId;
  final List<Comment> comments;

  const CommentsSection({
    super.key,
    required this.announcementId,
    required this.comments,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  late List<Comment> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.comments);
  }

  @override
  void didUpdateWidget(CommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comments != widget.comments) {
      setState(() {
        _comments = List.from(widget.comments);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnnouncementBloc, AnnouncementState>(
      listener: (context, state) {
        if (state is CommentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Agregar el nuevo comentario a la lista local
          setState(() {
            _comments.add(state.comment);
          });
          _commentController.clear();
        } else if (state is CommentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment deleted successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
          // Remover el comentario de la lista local
          setState(() {
            _comments.removeWhere((comment) => comment.id == state.commentId);
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ..._comments.map((comment) => CommentCard(
            key: ValueKey(comment.id),
            comment: comment,
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
              hintText: 'Add a comment...',
              hintStyle: TextStyle(color: AnnouncementColors.textSecondary),
              filled: true,
              fillColor: AnnouncementColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: Colors.white),
            maxLines: null,
            textInputAction: TextInputAction.newline,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _sendComment(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AnnouncementColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _sendComment(BuildContext context) async {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      // Obtener el userId del usuario actual
      final storageService = sl<SecureStorageService>();
      final userId = await storageService.getUserId();
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el ID del usuario'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      BlocProvider.of<AnnouncementBloc>(context).add(
        CommentCreateRequested(
          announcementId: widget.announcementId,
          employeeId: userId,
          content: content,
        ),
      );
    }
  }
}