import '../models/priority.dart';

class CreateAnnouncementRequest {
  final String title;
  final String description;
  final String? image;
  final Priority priority;
  final String createdBy;

  const CreateAnnouncementRequest({
    required this.title,
    required this.description,
    this.image,
    required this.priority,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'priority': priority.value,
      'createdBy': createdBy,
    };
  }
}