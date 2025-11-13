import 'priority.dart';
import 'comment.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final String? image;
  final Priority priority;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> comments;
  final List<String> seenBy;

  const Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.priority,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.comments = const [],
    this.seenBy = const [],
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      priority: Priority.fromString(json['priority']),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => Comment.fromJson(comment))
              .toList()
          : [],
      seenBy: json['seenBy'] != null 
          ? List<String>.from(json['seenBy'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'priority': priority.value,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'seenBy': seenBy,
    };
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    Priority? priority,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? comments,
    List<String>? seenBy,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}