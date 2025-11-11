import 'package:equatable/equatable.dart';

class UpdateEventRequest extends Equatable {
  final String? title;
  final String? description;
  final String? date;
  final String? location;
  final List<String>? recipientIds;
  final String? createdBy;

  const UpdateEventRequest({
    this.title,
    this.description,
    this.date,
    this.location,
    this.recipientIds,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (date != null) data['date'] = date;
    if (location != null) data['location'] = location;
    if (recipientIds != null) data['recipientIds'] = recipientIds;
    if (createdBy != null) data['createdBy'] = createdBy;
    return data;
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