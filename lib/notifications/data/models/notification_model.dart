import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'notification_model.g.dart';

/// Notification model for notifications from the web service
@JsonSerializable()
class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final List<String> recipientIds;
  final String priority; // 'HIGH', 'MEDIUM', 'LOW'
  final String status; // 'PENDING', 'SENT', 'READ'
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientIds,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Converts this NotificationModel to JSON
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Creates a copy with some fields modified
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    List<String>? recipientIds,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      recipientIds: recipientIds ?? this.recipientIds,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts to a Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'recipientIds': recipientIds.join(','), // Convert list to comma-separated string
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a NotificationModel from a SQLite Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      recipientIds: (map['recipientIds'] as String).split(','), // Convert comma-separated string to list
      priority: map['priority'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Helper getter to check if notification is read
  bool get isRead => status == 'READ';

  /// Helper getter to check if notification is high priority
  bool get isHighPriority => priority == 'HIGH';

  @override
  List<Object?> get props => [id, title, message, recipientIds, priority, status, createdAt, updatedAt];
}

