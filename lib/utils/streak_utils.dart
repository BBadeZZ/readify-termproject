import '../models/reading_session.dart';

/// Returns the number of consecutive days (ending today or yesterday)
/// on which at least one reading session was recorded.
int calculateStreak(List<ReadingSession> sessions) {
  if (sessions.isEmpty) return 0;

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  final sessionDates = sessions
      .map((s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  // Streak is only active if user read today or yesterday
  final mostRecent = sessionDates.first;
  final diff = todayDate.difference(mostRecent).inDays;
  if (diff > 1) return 0;

  int streak = 1;
  for (int i = 0; i < sessionDates.length - 1; i++) {
    if (sessionDates[i].difference(sessionDates[i + 1]).inDays == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
