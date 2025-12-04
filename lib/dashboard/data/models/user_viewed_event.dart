/// Model for representing an event viewed by a user
class UserViewedEvent {
  final String eventId;
  final String title;
  final String description;
  final String? location;
  final DateTime eventDate;
  final DateTime viewedAt;

  const UserViewedEvent({
    required this.eventId,
    required this.title,
    required this.description,
    this.location,
    required this.eventDate,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'title': title,
    'description': description,
    'location': location,
    'eventDate': eventDate.toIso8601String(),
    'viewedAt': viewedAt.toIso8601String(),
  };

  factory UserViewedEvent.fromJson(Map<String, dynamic> json) {
    try {
      // Safe parsing con valores por defecto
      final eventId = json['eventId'] as String? ?? '';
      final title = json['title'] as String? ?? 
                   json['eventTitle'] as String? ?? 
                   'Sin título';
      final description = json['description'] as String? ?? 
                         json['eventDescription'] as String? ?? 
                         json['eventContent'] as String? ?? 
                         'Sin descripción';
      final location = json['location'] as String?;
      final eventDateStr = json['eventDate'] as String?;
      final viewedAtStr = json['viewedAt'] as String?;

      // Verificar que tenemos los datos mínimos necesarios
      if (eventId.isEmpty) {
        throw FormatException('eventId is required but was null or empty');
      }
      
      if (eventDateStr == null || eventDateStr.isEmpty) {
        throw FormatException('eventDate is required but was null or empty');
      }
      
      if (viewedAtStr == null || viewedAtStr.isEmpty) {
        throw FormatException('viewedAt is required but was null or empty');
      }

      return UserViewedEvent(
        eventId: eventId,
        title: title,
        description: description,
        location: location,
        eventDate: DateTime.parse(eventDateStr),
        viewedAt: DateTime.parse(viewedAtStr),
      );
    } catch (e) {
      print('❌ Error parsing UserViewedEvent: $e');
      print('📋 Raw JSON: $json');
      rethrow;
    }
  }

  UserViewedEvent copyWith({
    String? eventId,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
    DateTime? viewedAt,
  }) {
    return UserViewedEvent(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }

  /// Returns a truncated description for UI display
  String get truncatedDescription {
    if (description.length <= 100) {
      return description;
    }
    return '${description.substring(0, 100)}...';
  }

  /// Returns formatted event date for display
  String get formattedEventDate {
    return '${eventDate.day}/${eventDate.month}/${eventDate.year} at ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}';
  }
}