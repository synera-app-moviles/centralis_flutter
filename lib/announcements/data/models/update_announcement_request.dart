import '../models/priority.dart';

class UpdateAnnouncementRequest {
  final String title;
  final String description;
  final String? image;
  final Priority priority;

  const UpdateAnnouncementRequest({
    required this.title,
    required this.description,
    this.image,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'priority': priority.value,
    };
  }
}