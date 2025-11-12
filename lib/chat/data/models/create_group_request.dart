import 'package:equatable/equatable.dart';

/// Request para crear un nuevo grupo de chat
class CreateGroupRequest extends Equatable {
  final String name;
  final String? description;
  final String? imageUrl;
  final String visibility; // PUBLIC, PRIVATE
  final List<String> memberIds;
  final String createdBy;

  const CreateGroupRequest({
    required this.name,
    this.description,
    this.imageUrl,
    this.visibility = 'PRIVATE',
    this.memberIds = const [],
    required this.createdBy,
  });

  factory CreateGroupRequest.fromJson(Map<String, dynamic> json) {
    return CreateGroupRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      visibility: json['visibility'] as String? ?? 'PRIVATE',
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'visibility': visibility,
      'memberIds': memberIds,
      'createdBy': createdBy,
    };
  }

  @override
  List<Object?> get props => [
    name, description, imageUrl, visibility, memberIds, createdBy,
  ];
}