import 'package:equatable/equatable.dart';

class CreateEventRequest extends Equatable {
  final String title;
  final String? description;
  final String date;
  final String? location;
  final List<String>? recipientIds;
  final String? createdBy;

  const CreateEventRequest({
    required this.title,
    this.description,
    required this.date,
    this.location,
    this.recipientIds,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'recipientIds': recipientIds,
      'createdBy': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        title,
        description,
        date,
        location,
        recipientIds,
        createdBy,
      ];
}