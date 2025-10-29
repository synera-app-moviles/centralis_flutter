import 'enums.dart';

class CreateProfileRequest {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final Position position;
  final Department department;

  const CreateProfileRequest({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.position,
    required this.department,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'avatarUrl': avatarUrl,
    'position': position.value,
    'department': department.value,
  };

  factory CreateProfileRequest.fromJson(Map<String, dynamic> json) {
    // Parse position enum
    Position position = Position.employee;
    final positionStr = json['position'] as String?;
    if (positionStr != null) {
      position = Position.values.firstWhere(
        (e) => e.value == positionStr,
        orElse: () => Position.employee,
      );
    }

    // Parse department enum
    Department department = Department.other;
    final departmentStr = json['department'] as String?;
    if (departmentStr != null) {
      department = Department.values.firstWhere(
        (e) => e.value == departmentStr,
        orElse: () => Department.other,
      );
    }

    return CreateProfileRequest(
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      position: position,
      department: department,
    );
  }
}