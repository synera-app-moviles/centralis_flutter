import 'enums.dart';

class ProfileModel {
  final String profileId;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final Position position;
  final Department department;

  const ProfileModel({
    required this.profileId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.position,
    required this.department,
  });

  Map<String, dynamic> toJson() => {
    'profileId': profileId,
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    'position': position.value,
    'department': department.value,
  };

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
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

    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return ProfileModel(
      profileId: json['profileId'] as String? ?? json['id'] as String,
      userId: json['userId'] as String,
      firstName: firstName,
      lastName: lastName,
      email: json['email'] as String,
      fullName: fullName,
      avatarUrl: json['avatarUrl'] as String?,
      position: position,
      department: department,
    );
  }

  ProfileModel copyWith({
    String? profileId,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? fullName,
    String? avatarUrl,
    Position? position,
    Department? department,
  }) {
    return ProfileModel(
      profileId: profileId ?? this.profileId,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      position: position ?? this.position,
      department: department ?? this.department,
    );
  }
}