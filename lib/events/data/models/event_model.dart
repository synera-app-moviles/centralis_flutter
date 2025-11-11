import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String date;
  final String? location;
  final String createdBy;
  final List<String> recipientIds;
  final String createdAt;
  final String updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.location,
    required this.createdBy,
    required this.recipientIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      location: json['location'] as String?,
      createdBy: json['createdBy'] as String,
      recipientIds: (json['recipientIds'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'createdBy': createdBy,
      'recipientIds': recipientIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        location,
        createdBy,
        recipientIds,
        createdAt,
        updatedAt,
      ];
}