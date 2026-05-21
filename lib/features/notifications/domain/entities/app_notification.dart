class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  static int _lastGeneratedId = 0;

  factory AppNotification.create({
    required String title,
    required String message,
    DateTime? timestamp,
  }) {
    final createdAt = timestamp ?? DateTime.now();
    final timestampId = createdAt.microsecondsSinceEpoch;
    final id = timestampId <= _lastGeneratedId
        ? _lastGeneratedId + 1
        : timestampId;
    _lastGeneratedId = id;

    return AppNotification(
      id: id,
      title: title,
      message: message,
      timestamp: createdAt,
      isRead: false,
    );
  }

  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
