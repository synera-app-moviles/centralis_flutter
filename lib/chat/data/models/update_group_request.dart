import 'package:equatable/equatable.dart';

/// Request para actualizar información de un grupo
class UpdateGroupRequest extends Equatable {
  final String? name;
  final String? description;
  final String? imageUrl;

  const UpdateGroupRequest({
    this.name,
    this.description,
    this.imageUrl,
  });

  factory UpdateGroupRequest.fromJson(Map<String, dynamic> json) {
    return UpdateGroupRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [name, description, imageUrl];
}