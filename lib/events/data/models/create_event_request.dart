class CreateEventRequest {
  final String title;
  final String description;
  final String date;
  final String? location;
  final List<String> recipientIds;
  final String createdBy;

  const CreateEventRequest({
    required this.title,
    required this.description,
    required this.date,
    this.location,
    required this.recipientIds,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'date': date,
        if (location != null) 'location': location,
        'recipientIds': recipientIds,
        'createdBy': createdBy,
      };
}