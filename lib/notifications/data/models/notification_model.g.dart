// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      userId: json['userId'] as String,
      relatedId: (json['relatedId'] as num?)?.toInt(),
      sentDate: DateTime.parse(json['sentDate'] as String),
      read: json['read'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'userId': instance.userId,
      'relatedId': instance.relatedId,
      'sentDate': instance.sentDate.toIso8601String(),
      'read': instance.read,
    };

