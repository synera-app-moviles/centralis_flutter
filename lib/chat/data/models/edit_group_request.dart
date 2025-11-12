import 'package:equatable/equatable.dart';

/// Request model para actualizar un grupo de chat
class EditGroupRequest extends Equatable {
  final String name;
  final String description;
  final String visibility; // PUBLIC, PRIVATE
  final String? imageUrl;

  const EditGroupRequest({
    required this.name,
    required this.description,
    required this.visibility,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    data['name'] = name;
    data['description'] = description;
    data['visibility'] = visibility;
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      data['imageUrl'] = imageUrl;
    }
    
    return data;
  }

  @override
  List<Object?> get props => [name, description, visibility, imageUrl];
}