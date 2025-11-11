import 'package:equatable/equatable.dart';
import '../../data/models/announcement.dart';
import '../../data/models/comment.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> announcements;

  const AnnouncementLoaded({required this.announcements});

  @override
  List<Object?> get props => [announcements];
}

class AnnouncementDetailLoaded extends AnnouncementState {
  final Announcement announcement;

  const AnnouncementDetailLoaded({required this.announcement});

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementCreated extends AnnouncementState {
  final Announcement announcement;

  const AnnouncementCreated({required this.announcement});

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementUpdated extends AnnouncementState {
  final Announcement announcement;

  const AnnouncementUpdated({required this.announcement});

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementDeleted extends AnnouncementState {
  final String announcementId;

  const AnnouncementDeleted({required this.announcementId});

  @override
  List<Object?> get props => [announcementId];
}

class CommentsLoaded extends AnnouncementState {
  final List<Comment> comments;
  final String announcementId;

  const CommentsLoaded({
    required this.comments,
    required this.announcementId,
  });

  @override
  List<Object?> get props => [comments, announcementId];
}

class CommentCreated extends AnnouncementState {
  final Comment comment;

  const CommentCreated({required this.comment});

  @override
  List<Object?> get props => [comment];
}

class CommentDeleted extends AnnouncementState {
  final String commentId;

  const CommentDeleted({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class AnnouncementError extends AnnouncementState {
  final String message;

  const AnnouncementError({required this.message});

  @override
  List<Object?> get props => [message];
}