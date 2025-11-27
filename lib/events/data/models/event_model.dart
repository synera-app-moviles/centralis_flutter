import 'package:equatable/equatable.dart';
import 'dart:convert';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String date;
  final String? location;
  final String? createdBy;
  final List<String> recipientIds;
  final String? createdAt;
  final String? updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.location,
    this.createdBy,
    this.recipientIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic v) {
      try {
        return (v ?? '').toString();
      } catch (_) {
        return '';
      }
    }

    List<String> parseRecipients(dynamic raw) {
      try {
        if (raw == null) return <String>[];
        if (raw is List) {
          return raw.where((e) => e != null).map((e) => e.toString()).toList();
        }
        if (raw is String) {
          // Intenta parsear JSON si es un array serializado
          try {
            final decoded = jsonDecodeSafe(raw);
            if (decoded is List) return decoded.map((e) => e.toString()).toList();
          } catch (_) {}
          return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        }
        return [raw.toString()];
      } catch (_) {
        return <String>[];
      }
    }

    return EventModel(
      id: parseString(json['id'] ?? json['eventId'] ?? json['_id']),
      title: parseString(json['title']),
      description: parseString(json['description']),
      date: parseString(json['date']),
      location: (json['location'] == null) ? null : parseString(json['location']),
      createdBy: (json['createdBy'] == null) ? null : parseString(json['createdBy']),
      recipientIds: parseRecipients(json['recipientIds'] ?? json['recipients'] ?? json['participants']),
      createdAt: (json['createdAt'] == null) ? null : parseString(json['createdAt']),
      updatedAt: (json['updatedAt'] == null) ? null : parseString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      if (location != null) 'location': location,
      if (createdBy != null) 'createdBy': createdBy,
      'recipientIds': recipientIds,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? location,
    String? createdBy,
    List<String>? recipientIds,
    String? createdAt,
    String? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      recipientIds: recipientIds ?? List<String>.from(this.recipientIds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, date, location, createdBy, recipientIds, createdAt, updatedAt];

  @override
  String toString() => 'EventModel(id: $id, title: $title, date: $date)';
}

dynamic jsonDecodeSafe(String input) {
  try {
    if (input.isEmpty) return null;
    return jsonDecode(input);
  } catch (_) {
    return null;
  }
}