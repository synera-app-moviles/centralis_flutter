import 'package:equatable/equatable.dart';
import '../../data/models/priority.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

// Announcement Events
class AnnouncementLoadRequested extends AnnouncementEvent {}

class AnnouncementLoadByIdRequested extends AnnouncementEvent {
  final String announcementId;

  const AnnouncementLoadByIdRequested({required this.announcementId});

  @override
  List<Object?> get props => [announcementId];
}

class AnnouncementLoadByPriorityRequested extends AnnouncementEvent {
  final Priority priority;

  const AnnouncementLoadByPriorityRequested({required this.priority});

  @override
  List<Object?> get props => [priority];
}

class AnnouncementLoadByCreatorRequested extends AnnouncementEvent {
  final String creatorId;

  const AnnouncementLoadByCreatorRequested({required this.creatorId});

  @override
  List<Object?> get props => [creatorId];
}

class AnnouncementCreateRequested extends AnnouncementEvent {
  final String title;
  final String description;
  final String? image;
  final Priority priority;
  final String createdBy;

  const AnnouncementCreateRequested({
    required this.title,
    required this.description,
    this.image,
    required this.priority,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [title, description, image, priority, createdBy];
}

class AnnouncementUpdateRequested extends AnnouncementEvent {
  final String announcementId;
  final String title;
  final String description;
  final String? image;
  final Priority priority;

  const AnnouncementUpdateRequested({
    required this.announcementId,
    required this.title,
    required this.description,
    this.image,
    required this.priority,
  });

  @override
  List<Object?> get props => [announcementId, title, description, image, priority];
}

class AnnouncementDeleteRequested extends AnnouncementEvent {
  final String announcementId;

  const AnnouncementDeleteRequested({required this.announcementId});

  @override
  List<Object?> get props => [announcementId];
}

// Comment Events
class CommentCreateRequested extends AnnouncementEvent {
  final String announcementId;
  final String employeeId;
  final String content;

  const CommentCreateRequested({
    required this.announcementId,
    required this.employeeId,
    required this.content,
  });

  @override
  List<Object?> get props => [announcementId, employeeId, content];
}

class CommentDeleteRequested extends AnnouncementEvent {
  final String commentId;

  const CommentDeleteRequested({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class CommentsLoadRequested extends AnnouncementEvent {
  final String announcementId;

  const CommentsLoadRequested({required this.announcementId});

  @override
  List<Object?> get props => [announcementId];
}