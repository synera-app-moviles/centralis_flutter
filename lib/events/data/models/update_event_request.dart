class UpdateEventRequest {
  final String? title;
  final String? description;
  final String? date;
  final String? location;
  final List<String>? recipientIds;

  const UpdateEventRequest({
    this.title,
    this.description,
    this.date,
    this.location,
    this.recipientIds,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (date != null) map['date'] = date;
    if (location != null) map['location'] = location;
    if (recipientIds != null) map['recipientIds'] = recipientIds;
    return map;
  }
}