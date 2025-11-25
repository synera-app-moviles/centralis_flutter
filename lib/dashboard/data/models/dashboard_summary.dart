import 'dashboard_user.dart';

/// Model for dashboard summary statistics
class DashboardSummary {
  final int totalViews;
  final int totalUniqueUsers;
  final int totalContent;
  final MostViewedContent? mostViewedContent;
  final List<DashboardUser> topActiveUsers;

  const DashboardSummary({
    required this.totalViews,
    required this.totalUniqueUsers,
    required this.totalContent,
    this.mostViewedContent,
    required this.topActiveUsers,
  });

  Map<String, dynamic> toJson() => {
    'totalViews': totalViews,
    'totalUniqueUsers': totalUniqueUsers,
    'totalContent': totalContent,
    'mostViewedContent': mostViewedContent?.toJson(),
    'topActiveUsers': topActiveUsers.map((user) => user.toJson()).toList(),
  };

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final mostViewedData = json['mostViewedContent'] as Map<String, dynamic>?;
    final topUsersData = json['topActiveUsers'] as List<dynamic>? ?? [];

    return DashboardSummary(
      totalViews: json['totalViews'] as int,
      totalUniqueUsers: json['totalUniqueUsers'] as int,
      totalContent: json['totalContent'] as int,
      mostViewedContent: mostViewedData != null 
          ? MostViewedContent.fromJson(mostViewedData)
          : null,
      topActiveUsers: topUsersData
          .map((userData) => DashboardUser.fromJson(userData as Map<String, dynamic>))
          .toList(),
    );
  }

  DashboardSummary copyWith({
    int? totalViews,
    int? totalUniqueUsers,
    int? totalContent,
    MostViewedContent? mostViewedContent,
    List<DashboardUser>? topActiveUsers,
  }) {
    return DashboardSummary(
      totalViews: totalViews ?? this.totalViews,
      totalUniqueUsers: totalUniqueUsers ?? this.totalUniqueUsers,
      totalContent: totalContent ?? this.totalContent,
      mostViewedContent: mostViewedContent ?? this.mostViewedContent,
      topActiveUsers: topActiveUsers ?? this.topActiveUsers,
    );
  }
}

/// Model for most viewed content
class MostViewedContent {
  final String contentId;
  final String title;
  final String description;
  final String? location;
  final DateTime? eventDate;

  const MostViewedContent({
    required this.contentId,
    required this.title,
    required this.description,
    this.location,
    this.eventDate,
  });

  Map<String, dynamic> toJson() => {
    'contentId': contentId,
    'title': title,
    'description': description,
    'location': location,
    'eventDate': eventDate?.toIso8601String(),
  };

  factory MostViewedContent.fromJson(Map<String, dynamic> json) {
    final eventDateStr = json['eventDate'] as String?;
    return MostViewedContent(
      contentId: json['contentId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      eventDate: eventDateStr != null ? DateTime.parse(eventDateStr) : null,
    );
  }

  MostViewedContent copyWith({
    String? contentId,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
  }) {
    return MostViewedContent(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
    );
  }
}