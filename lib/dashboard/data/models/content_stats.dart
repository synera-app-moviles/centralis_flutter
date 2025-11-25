/// Model for announcement/event statistics  
class ContentStats {
  final String contentId;
  final String title;
  final String description;
  final int totalViews;
  final int uniqueViewers;
  final ViewsData viewsData;
  final DepartmentBreakdown departmentBreakdown;
  final String? location; // For events
  final DateTime? eventDate; // For events

  const ContentStats({
    required this.contentId,
    required this.title,
    required this.description,
    required this.totalViews,
    required this.uniqueViewers,
    required this.viewsData,
    required this.departmentBreakdown,
    this.location,
    this.eventDate,
  });

  Map<String, dynamic> toJson() => {
    'contentId': contentId,
    'title': title,
    'description': description,
    'totalViews': totalViews,
    'uniqueViewers': uniqueViewers,
    'viewsData': viewsData.toJson(),
    'departmentBreakdown': departmentBreakdown.toJson(),
    'location': location,
    'eventDate': eventDate?.toIso8601String(),
  };

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    final eventDateStr = json['eventDate'] as String?;
    
    // Handle different response formats for contentId
    String contentId = '';
    if (json['announcementId'] != null) {
      final rawId = json['announcementId'].toString();
      // Extract ID from "AnnouncementId[value=xxx]" format if present
      if (rawId.contains('[value=') && rawId.contains(']')) {
        contentId = rawId.substring(rawId.indexOf('value=') + 6, rawId.lastIndexOf(']'));
      } else {
        contentId = rawId;
      }
    } else if (json['eventId'] != null) {
      final rawId = json['eventId'].toString();
      // Extract ID from "EventId[value=xxx]" format if present
      if (rawId.contains('[value=') && rawId.contains(']')) {
        contentId = rawId.substring(rawId.indexOf('value=') + 6, rawId.lastIndexOf(']'));
      } else {
        contentId = rawId;
      }
    }
    
    return ContentStats(
      contentId: contentId,
      title: json['announcementTitle'] as String? ?? json['eventTitle'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? '', // Default to empty if not provided
      totalViews: json['totalViews'] as int? ?? 0,
      uniqueViewers: json['totalUsers'] as int? ?? json['uniqueViewers'] as int? ?? 0,
      viewsData: ViewsData.fromJson(json['viewStats'] as Map<String, dynamic>? ?? {}),
      departmentBreakdown: DepartmentBreakdown.fromJson({'departments': json['departmentBreakdown'] as List? ?? []}),
      location: json['location'] as String?,
      eventDate: eventDateStr != null ? DateTime.parse(eventDateStr) : null,
    );
  }

  ContentStats copyWith({
    String? contentId,
    String? title,
    String? description,
    int? totalViews,
    int? uniqueViewers,
    ViewsData? viewsData,
    DepartmentBreakdown? departmentBreakdown,
    String? location,
    DateTime? eventDate,
  }) {
    return ContentStats(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      description: description ?? this.description,
      totalViews: totalViews ?? this.totalViews,
      uniqueViewers: uniqueViewers ?? this.uniqueViewers,
      viewsData: viewsData ?? this.viewsData,
      departmentBreakdown: departmentBreakdown ?? this.departmentBreakdown,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
    );
  }
}

/// Model for views data
class ViewsData {
  final List<DailyViews> dailyViews;
  final ViewStats? viewStats;

  const ViewsData({
    required this.dailyViews,
    this.viewStats,
  });

  Map<String, dynamic> toJson() => {
    'dailyViews': dailyViews.map((view) => view.toJson()).toList(),
    if (viewStats != null) 'viewStats': viewStats!.toJson(),
  };

  factory ViewsData.fromJson(Map<String, dynamic> json) {
    List<DailyViews> dailyViews = [];
    ViewStats? viewStats;
    
    // Handle new viewStats format
    if (json.containsKey('viewed') && json.containsKey('notViewed')) {
      viewStats = ViewStats.fromJson(json);
    }
    
    // Handle old dailyViews format if present
    if (json.containsKey('dailyViews')) {
      final dailyViewsData = json['dailyViews'] as List<dynamic>;
      dailyViews = dailyViewsData
          .map((data) => DailyViews.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    
    return ViewsData(
      dailyViews: dailyViews,
      viewStats: viewStats,
    );
  }
}

/// Model for view statistics
class ViewStats {
  final ViewInfo viewed;
  final ViewInfo notViewed;

  const ViewStats({
    required this.viewed,
    required this.notViewed,
  });

  Map<String, dynamic> toJson() => {
    'viewed': viewed.toJson(),
    'notViewed': notViewed.toJson(),
  };

  factory ViewStats.fromJson(Map<String, dynamic> json) {
    return ViewStats(
      viewed: ViewInfo.fromJson(json['viewed'] as Map<String, dynamic>),
      notViewed: ViewInfo.fromJson(json['notViewed'] as Map<String, dynamic>),
    );
  }
}

/// Model for view information
class ViewInfo {
  final int count;
  final double percentage;
  final String color;

  const ViewInfo({
    required this.count,
    required this.percentage,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'count': count,
    'percentage': percentage,
    'color': color,
  };

  factory ViewInfo.fromJson(Map<String, dynamic> json) {
    return ViewInfo(
      count: json['count'] as int,
      percentage: json['percentage'] as double,
      color: json['color'] as String,
    );
  }
}

/// Model for daily views
class DailyViews {
  final String date;
  final int views;

  const DailyViews({
    required this.date,
    required this.views,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'views': views,
  };

  factory DailyViews.fromJson(Map<String, dynamic> json) {
    return DailyViews(
      date: json['date'] as String,
      views: json['views'] as int,
    );
  }
}

/// Model for department breakdown
class DepartmentBreakdown {
  final List<DepartmentViews> byDepartment;

  const DepartmentBreakdown({
    required this.byDepartment,
  });

  Map<String, dynamic> toJson() => {
    'byDepartment': byDepartment.map((dept) => dept.toJson()).toList(),
  };

  factory DepartmentBreakdown.fromJson(Map<String, dynamic> json) {
    List<DepartmentViews> byDepartment = [];
    
    // Handle case where departments is a direct list
    if (json.containsKey('departments') && json['departments'] is List) {
      final departmentsList = json['departments'] as List<dynamic>;
      byDepartment = departmentsList
          .map((data) => DepartmentViews.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    // Handle case where byDepartment is provided
    else if (json.containsKey('byDepartment') && json['byDepartment'] is List) {
      final byDepartmentData = json['byDepartment'] as List<dynamic>;
      byDepartment = byDepartmentData
          .map((data) => DepartmentViews.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    
    return DepartmentBreakdown(
      byDepartment: byDepartment,
    );
  }
}

/// Model for department views
class DepartmentViews {
  final String department;
  final int views;
  final double percentage;

  const DepartmentViews({
    required this.department,
    required this.views,
    required this.percentage,
  });

  Map<String, dynamic> toJson() => {
    'department': department,
    'views': views,
    'percentage': percentage,
  };

  factory DepartmentViews.fromJson(Map<String, dynamic> json) {
    return DepartmentViews(
      department: json['department'] as String,
      views: json['viewedUsers'] as int? ?? json['views'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}