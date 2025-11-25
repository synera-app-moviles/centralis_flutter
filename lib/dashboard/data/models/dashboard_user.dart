import '../../../profile/data/models/enums.dart';

/// Model representing a user in the dashboard
class DashboardUser {
  final String userId;
  final String userFullName;
  final String userEmail;
  final Department userDepartment;
  final Position userPosition;
  final String? avatarUrl;
  final int totalViews;

  const DashboardUser({
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.userDepartment,
    required this.userPosition,
    this.avatarUrl,
    this.totalViews = 0,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userFullName': userFullName,
    'userEmail': userEmail,
    'userDepartment': userDepartment.value,
    'userPosition': userPosition.value,
    'avatarUrl': avatarUrl,
    'totalViews': totalViews,
  };

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    // Parse department enum
    Department department = Department.other;
    final departmentStr = json['userDepartment'] as String?;
    if (departmentStr != null) {
      department = Department.values.firstWhere(
        (e) => e.value == departmentStr,
        orElse: () => Department.other,
      );
    }

    // Parse position enum
    Position position = Position.employee;
    final positionStr = json['userPosition'] as String?;
    if (positionStr != null) {
      position = Position.values.firstWhere(
        (e) => e.value == positionStr,
        orElse: () => Position.employee,
      );
    }

    return DashboardUser(
      userId: json['userId'] as String,
      userFullName: json['userFullName'] as String,
      userEmail: json['userEmail'] as String,
      userDepartment: department,
      userPosition: position,
      avatarUrl: json['avatarUrl'] as String?,
      totalViews: json['totalViews'] as int? ?? 0,
    );
  }

  DashboardUser copyWith({
    String? userId,
    String? userFullName,
    String? userEmail,
    Department? userDepartment,
    Position? userPosition,
    String? avatarUrl,
    int? totalViews,
  }) {
    return DashboardUser(
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      userEmail: userEmail ?? this.userEmail,
      userDepartment: userDepartment ?? this.userDepartment,
      userPosition: userPosition ?? this.userPosition,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalViews: totalViews ?? this.totalViews,
    );
  }
}