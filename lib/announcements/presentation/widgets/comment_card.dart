import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../shared/theme/colors.dart';
import '../../data/models/comment.dart';

class CommentCard extends StatefulWidget {
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
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  ProfileModel? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profileRepository = sl<ProfileRepository>();
      final profile = await profileRepository.getProfileByUserId(widget.comment.employeeId);
      
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: AnnouncementColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AnnouncementColors.primary),
                strokeWidth: 2,
              ),
              const SizedBox(width: 12),
              Text(
                'Loading user...',
                style: TextStyle(color: AnnouncementColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: AnnouncementColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AnnouncementColors.primary,
                    child: Text(
                      _getInitials(widget.comment.employeeId),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User ${widget.comment.employeeId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(widget.comment.createdAt),
                          style: TextStyle(
                            color: AnnouncementColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.comment.content,
                style: TextStyle(
                  color: AnnouncementColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AnnouncementColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: _userProfile?.avatarUrl != null
                      ? NetworkImage(_userProfile!.avatarUrl!)
                      : null,
                  backgroundColor: AnnouncementColors.primary,
                  child: _userProfile?.avatarUrl == null
                      ? Text(
                          _getInitials(_userProfile?.fullName ?? widget.comment.employeeId),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userProfile?.fullName ?? 'User ${widget.comment.employeeId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(widget.comment.createdAt),
                        style: TextStyle(
                          color: AnnouncementColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.comment.content,
              style: TextStyle(
                color: AnnouncementColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    // Si es un nombre completo, tomar las primeras letras
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0].toUpperCase()}${nameParts[1][0].toUpperCase()}';
    }
    
    // Si es un employeeId con punto, dividir por punto
    final parts = name.split('.');
    if (parts.length >= 2) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    
    return name.substring(0, 1).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}