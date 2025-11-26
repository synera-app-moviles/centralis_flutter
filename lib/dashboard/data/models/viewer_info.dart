/// Model for viewer information with view timestamp
class ViewerInfo {
  final String viewId;
  final String userId;
  final String userFullName;
  final String userEmail;
  final String userDepartment;
  final String? avatarUrl;
  final DateTime viewedAt;
  final String? announcementId;
  final String? eventId;
  final String? announcementTitle;
  final String? eventTitle;

  const ViewerInfo({
    required this.viewId,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.userDepartment,
    this.avatarUrl,
    required this.viewedAt,
    this.announcementId,
    this.eventId,
    this.announcementTitle,
    this.eventTitle,
  });

  Map<String, dynamic> toJson() => {
    'viewId': viewId,
    'userId': userId,
    'userFullName': userFullName,
    'userEmail': userEmail,
    'userDepartment': userDepartment,
    'avatarUrl': avatarUrl,
    'viewedAt': viewedAt.toIso8601String(),
    'announcementId': announcementId,
    'eventId': eventId,
    'announcementTitle': announcementTitle,
    'eventTitle': eventTitle,
  };

  factory ViewerInfo.fromJson(Map<String, dynamic> json) {
    return ViewerInfo(
      viewId: json['viewId'] as String,
      userId: json['userId'] as String,
      userFullName: json['userFullName'] as String? ?? 'Unknown User',
      userEmail: json['userEmail'] as String? ?? '',
      userDepartment: json['userDepartment'] as String? ?? 'Unknown',
      avatarUrl: json['avatarUrl'] as String?,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
      announcementId: json['announcementId'] as String?,
      eventId: json['eventId'] as String?,
      announcementTitle: json['announcementTitle'] as String?,
      eventTitle: json['eventTitle'] as String?,
    );
  }

  ViewerInfo copyWith({
    String? viewId,
    String? userId,
    String? userFullName,
    String? userEmail,
    String? userDepartment,
    String? avatarUrl,
    DateTime? viewedAt,
    String? announcementId,
    String? eventId,
    String? announcementTitle,
    String? eventTitle,
  }) {
    return ViewerInfo(
      viewId: viewId ?? this.viewId,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      userEmail: userEmail ?? this.userEmail,
      userDepartment: userDepartment ?? this.userDepartment,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      viewedAt: viewedAt ?? this.viewedAt,
      announcementId: announcementId ?? this.announcementId,
      eventId: eventId ?? this.eventId,
      announcementTitle: announcementTitle ?? this.announcementTitle,
      eventTitle: eventTitle ?? this.eventTitle,
    );
  }
}