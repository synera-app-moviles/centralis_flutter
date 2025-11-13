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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      location: json['location'],
      createdBy: json['createdBy'],
      recipientIds: List<String>.from(json['recipientIds'] ?? []),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  List<Object?> get props => [id, title, date, recipientIds];
}