import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'notification_model.g.dart';

/// Notification model for notifications from the web service
@JsonSerializable()
class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String message;
  final String type; // 'ANNOUNCEMENT', 'EVENT', 'CHAT', etc.
  final String userId;
  final int? relatedId; // ID of related announcement, event, etc.
  final DateTime sentDate;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.userId,
    this.relatedId,
    required this.sentDate,
    this.read = false,
  });

  /// Creates a NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Converts this NotificationModel to JSON
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Creates a copy with some fields modified
  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    String? userId,
    int? relatedId,
    DateTime? sentDate,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      relatedId: relatedId ?? this.relatedId,
      sentDate: sentDate ?? this.sentDate,
      read: read ?? this.read,
    );
  }

  /// Converts to a Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'userId': userId,
      'relatedId': relatedId,
      'sentDate': sentDate.toIso8601String(),
      'read': read ? 1 : 0,
    };
  }

  /// Creates a NotificationModel from a SQLite Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      userId: map['userId'] as String,
      relatedId: map['relatedId'] as int?,
      sentDate: DateTime.parse(map['sentDate'] as String),
      read: map['read'] == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, userId, relatedId, sentDate, read];
}

