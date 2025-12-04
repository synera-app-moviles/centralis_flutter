/// Model for representing an announcement viewed by a user
class UserViewedAnnouncement {
  final String announcementId;
  final String title;
  final String description;
  final DateTime viewedAt;
  final String? priority;

  const UserViewedAnnouncement({
    required this.announcementId,
    required this.title,
    required this.description,
    required this.viewedAt,
    this.priority,
  });

  Map<String, dynamic> toJson() => {
    'announcementId': announcementId,
    'title': title,
    'description': description,
    'viewedAt': viewedAt.toIso8601String(),
    'priority': priority,
  };

  factory UserViewedAnnouncement.fromJson(Map<String, dynamic> json) {
    try {
      // Safe parsing con valores por defecto
      final announcementId = json['announcementId'] as String? ?? '';
      final title = json['announcementTitle'] as String? ?? 
                   json['title'] as String? ?? 
                   'Sin título';
      final description = json['announcementContent'] as String? ?? 
                         json['description'] as String? ?? 
                         'Sin descripción';
      final viewedAtStr = json['viewedAt'] as String?;
      final priority = json['priority'] as String?;

      // Verificar que tenemos los datos mínimos necesarios
      if (announcementId.isEmpty) {
        throw FormatException('announcementId is required but was null or empty');
      }
      
      if (viewedAtStr == null || viewedAtStr.isEmpty) {
        throw FormatException('viewedAt is required but was null or empty');
      }

      return UserViewedAnnouncement(
        announcementId: announcementId,
        title: title,
        description: description,
        viewedAt: DateTime.parse(viewedAtStr),
        priority: priority,
      );
    } catch (e) {
      print('❌ Error parsing UserViewedAnnouncement: $e');
      print('📋 Raw JSON: $json');
      rethrow;
    }
  }

  UserViewedAnnouncement copyWith({
    String? announcementId,
    String? title,
    String? description,
    DateTime? viewedAt,
    String? priority,
  }) {
    return UserViewedAnnouncement(
      announcementId: announcementId ?? this.announcementId,
      title: title ?? this.title,
      description: description ?? this.description,
      viewedAt: viewedAt ?? this.viewedAt,
      priority: priority ?? this.priority,
    );
  }

  /// Returns a truncated description for UI display
  String get truncatedDescription {
    if (description.length <= 100) {
      return description;
    }
    return '${description.substring(0, 100)}...';
  }
}