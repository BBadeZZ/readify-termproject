class ReadingSession {
  final String id;
  final String bookId;
  final String bookTitle;
  final DateTime startedAt;
  final DateTime endedAt;
  final int pagesRead;
  final int durationMinutes;

  ReadingSession({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.startedAt,
    required this.endedAt,
    required this.pagesRead,
    required this.durationMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'pagesRead': pagesRead,
      'durationMinutes': durationMinutes,
    };
  }

  factory ReadingSession.fromMap(String id, Map<String, dynamic> data) {
    return ReadingSession(
      id: id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      startedAt: DateTime.tryParse(data['startedAt'] ?? '') ?? DateTime.now(),
      endedAt: DateTime.tryParse(data['endedAt'] ?? '') ?? DateTime.now(),
      pagesRead: data['pagesRead'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 0,
    );
  }
}
