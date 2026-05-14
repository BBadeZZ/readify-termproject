import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../models/reading_session.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/stat_card.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {

  List<Book> _books = [];
  List<ReadingSession> _sessions = [];
  bool _loading = true;
  bool _hasError = false;

  StreamSubscription? _booksSub;
  StreamSubscription? _sessionsSub;

  @override
  void initState() {
    super.initState();
    _booksSub = firestoreService.getBooks().listen(
      (books) {
        if (mounted) setState(() { _books = books; _loading = false; });
      },
      onError: (_) {
        if (mounted) setState(() { _hasError = true; _loading = false; });
      },
    );
    _sessionsSub = firestoreService.getSessions().listen(
      (sessions) {
        if (mounted) setState(() => _sessions = sessions);
      },
      onError: (_) {
        if (mounted) setState(() => _hasError = true);
      },
    );
  }

  @override
  void dispose() {
    _booksSub?.cancel();
    _sessionsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        drawer: const AppDrawer(currentPage: 'Analytics'),
        appBar: AppBar(title: Text(l10n.analyticsTitle)),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      );
    }

    if (_hasError) {
      return Scaffold(
        drawer: const AppDrawer(currentPage: 'Analytics'),
        appBar: AppBar(title: Text(l10n.analyticsTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 52, color: cs.error),
              const SizedBox(height: 12),
              Text(l10n.librarySomethingWrong, style: TextStyle(color: cs.error)),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      );
    }

    final totalBooks = _books.length;
    final reading = _books.where((b) => b.status == BookStatus.reading).length;
    final wishlist = _books.where((b) => b.status == BookStatus.wishlist).length;
    final alreadyRead = _books.where((b) => b.status == BookStatus.alreadyRead).length;
    final favorite = _books.where((b) => b.favorite).length;

    int pagesRead = 0, totalPages = 0, ratingSum = 0;
    for (final b in _books) {
      pagesRead += b.currentPage;
      totalPages += b.totalPages;
      ratingSum += b.rating;
    }
    final avgRating = totalBooks == 0 ? 0.0 : ratingSum / totalBooks;
    final progress = totalPages == 0 ? 0.0 : pagesRead / totalPages;

    final totalSessions = _sessions.length;
    final totalMinutes = _sessions.fold(0, (s, e) => s + e.durationMinutes);
    final totalHours = totalMinutes ~/ 60;
    final remainingMin = totalMinutes % 60;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekPages = _sessions.where((s) => s.startedAt.isAfter(weekAgo)).fold(0, (s, e) => s + e.pagesRead);
    final avgSession = totalSessions == 0 ? 0 : totalMinutes ~/ totalSessions;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Analytics'),
      appBar: AppBar(title: Text(l10n.analyticsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.analyticsReadingSummary, style: tt.headlineSmall),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              StatCard(label: l10n.analyticsTotalBooks, value: '$totalBooks', icon: Icons.book_rounded, color: cs.primaryContainer, iconColor: cs.primary),
              StatCard(label: l10n.analyticsReading, value: '$reading', icon: Icons.auto_stories_rounded, color: AppColors.readingBlueContainer, iconColor: AppColors.readingBlue),
              StatCard(label: l10n.analyticsAlreadyRead, value: '$alreadyRead', icon: Icons.check_circle_rounded, color: AppColors.completedGreenContainer, iconColor: AppColors.completedGreen),
              StatCard(label: l10n.analyticsWishlist, value: '$wishlist', icon: Icons.bookmark_rounded, color: cs.secondaryContainer, iconColor: cs.secondary),
              StatCard(label: l10n.analyticsFavorites, value: '$favorite', icon: Icons.favorite_rounded, color: AppColors.favoritesContainer, iconColor: Colors.pink),
              StatCard(label: l10n.analyticsPagesRead, value: '$pagesRead', icon: Icons.menu_book_rounded, color: AppColors.pagesTealContainer, iconColor: AppColors.pagesTeal),
              StatCard(
                label: l10n.analyticsAvgRating,
                value: avgRating.toStringAsFixed(1),
                icon: Icons.star_rounded,
                color: AppColors.starYellowContainer,
                iconColor: AppColors.starYellow,
                suffix: '/ 5',
              ),
            ],
          ),

          const SizedBox(height: 20),
          _WeeklyChart(sessions: _sessions),

          const SizedBox(height: 20),
          if (_books.isNotEmpty) ...[
            _GenreChart(books: _books),
            const SizedBox(height: 20),
          ],

          _ReadingHeatmap(sessions: _sessions),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.analyticsOverallProgress, style: tt.titleMedium),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: progress, minHeight: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.pagesProgress(pagesRead, totalPages), style: tt.bodyMedium),
                    Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(l10n.analyticsReadingSessions, style: tt.headlineSmall),
          const SizedBox(height: 12),

          if (totalSessions == 0)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_off_outlined, color: cs.outline, size: 28),
                  const SizedBox(width: 16),
                  Text(l10n.analyticsNoSessions, style: tt.bodyMedium),
                ],
              ),
            )
          else ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
              children: [
                StatCard(label: l10n.analyticsSessions, value: '$totalSessions', icon: Icons.timer_rounded, color: AppColors.sessionPurpleContainer, iconColor: AppColors.sessionPurple),
                StatCard(
                  label: l10n.analyticsTotalTime,
                  value: totalHours > 0 ? '${totalHours}h ${remainingMin}m' : totalMinutes > 0 ? '${totalMinutes}m' : '< 1m',
                  icon: Icons.schedule_rounded,
                  color: AppColors.pagesTealContainer,
                  iconColor: AppColors.pagesTeal,
                ),
                StatCard(label: l10n.analyticsPagesThisWeek, value: '$weekPages', icon: Icons.trending_up_rounded, color: AppColors.completedGreenContainer, iconColor: AppColors.completedGreen),
                StatCard(label: l10n.analyticsAvgSession, value: '${avgSession}m', icon: Icons.bar_chart_rounded, color: AppColors.readingBlueContainer, iconColor: AppColors.readingBlue),
              ],
            ),

            const SizedBox(height: 24),
            Text(l10n.analyticsRecentSessions, style: tt.titleLarge),
            const SizedBox(height: 10),
            ..._sessions.take(5).map((s) => _SessionCard(session: s)),
          ],
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _GenreChart extends StatelessWidget {
  final List<Book> books;
  const _GenreChart({required this.books});

  static const _palette = [
    AppColors.readingBlue,
    AppColors.completedGreen,
    AppColors.starYellow,
    AppColors.sessionPurple,
    AppColors.pagesTeal,
    AppColors.suggestionsPurple,
    AppColors.wishlistAmber,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final counts = <String, int>{};
    for (final b in books) {
      final g = b.genre.trim().isEmpty ? '–' : b.genre;
      counts[g] = (counts[g] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = books.length;
    final slices = sorted.map((e) => e.value / total).toList();
    final colors = List.generate(sorted.length, (i) => _palette[i % _palette.length]);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.analyticsGenreBreakdown, style: tt.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(painter: _DonutPainter(slices: slices, colors: colors)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sorted.take(6).toList().asMap().entries.map((entry) {
                    final color = colors[entry.key];
                    final genre = entry.value.key;
                    final count = entry.value.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 9, height: 9,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(genre, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          ),
                          Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> slices;
  final List<Color> colors;
  const _DonutPainter({required this.slices, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = math.min(cx, cy);
    final strokeW = outerR * 0.42;
    final arcR = outerR - strokeW / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: arcR);
    const gap = 0.05;
    double angle = -math.pi / 2;

    for (int i = 0; i < slices.length; i++) {
      final sweep = slices[i] * 2 * math.pi - gap;
      canvas.drawArc(
        rect,
        angle + gap / 2,
        sweep.clamp(0.01, 2 * math.pi),
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt,
      );
      angle += slices[i] * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      !listEquals(old.slices, slices) || !listEquals(old.colors, colors);
}

class _WeeklyChart extends StatelessWidget {
  final List<ReadingSession> sessions;
  const _WeeklyChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final pages = sessions
          .where((s) =>
              s.startedAt.year == date.year &&
              s.startedAt.month == date.month &&
              s.startedAt.day == date.day)
          .fold(0, (sum, s) => sum + s.pagesRead);
      return (date: date, pages: pages);
    });

    final maxPages = days.fold(0, (m, d) => d.pages > m ? d.pages : m);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.analyticsWeeklyChart, style: tt.titleMedium),
              if (maxPages > 0)
                Text(
                  l10n.analyticsWeeklyMax(maxPages),
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 124,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final isToday = d.date == today;
                final ratio = maxPages == 0 ? 0.0 : d.pages / maxPages;
                final barH = d.pages == 0 ? 4.0 : (ratio * 72).clamp(6.0, 72.0);
                final label = DateFormat.E(locale).format(d.date);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (d.pages > 0)
                        Text(
                          '${d.pages}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isToday ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        height: barH,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: isToday
                              ? cs.primary
                              : cs.primaryContainer,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ReadingSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final s = session;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMd(locale).format(s.startedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.sessionPurpleContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.sessionPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.bookTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('$date  ·  ${l10n.detailSessionFormat(s.durationMinutes, s.pagesRead)}',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.sessionPurpleContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${l10n.detailPages(s.pagesRead)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.sessionPurple, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingHeatmap extends StatelessWidget {
  final List<ReadingSession> sessions;
  const _ReadingHeatmap({required this.sessions});

  static const _cellSize = 11.0;
  static const _gap = 2.0;

  Color _cellColor(int pages, ColorScheme cs) {
    if (pages == 0) return cs.surfaceContainerHighest;
    if (pages <= 5) return cs.primary.withValues(alpha: 0.22);
    if (pages <= 15) return cs.primary.withValues(alpha: 0.45);
    if (pages <= 30) return cs.primary.withValues(alpha: 0.70);
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Build day → pages map
    final Map<String, int> dayPages = {};
    for (final s in sessions) {
      final key = '${s.startedAt.year}-${s.startedAt.month}-${s.startedAt.day}';
      dayPages[key] = (dayPages[key] ?? 0) + s.pagesRead;
    }

    // 365 days ending today, oldest first
    final days = List.generate(365, (i) => today.subtract(Duration(days: 364 - i)));

    // Pad start so first column begins on Monday (weekday 1)
    final leadingEmpty = (days.first.weekday - 1) % 7;
    final allCells = <DateTime?>[...List.filled(leadingEmpty, null), ...days];
    final numCols = (allCells.length / 7).ceil();

    // Organize into week columns of 7 rows
    final weeks = List.generate(numCols, (col) =>
      List.generate(7, (row) {
        final idx = col * 7 + row;
        return idx < allCells.length ? allCells[idx] : null;
      }),
    );

    String monthLabel(int col) {
      final DateTime? first = weeks[col].firstWhere((d) => d != null, orElse: () => null);
      if (first == null) return '';
      if (col == 0) return DateFormat.MMM(locale).format(first);
      final DateTime? prev = weeks[col - 1].firstWhere((d) => d != null, orElse: () => null);
      if (prev == null || prev.month != first.month) return DateFormat.MMM(locale).format(first);
      return '';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.analyticsHeatmap, style: tt.titleMedium),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month labels
                Row(
                  children: List.generate(numCols, (col) => SizedBox(
                    width: _cellSize + _gap,
                    child: Text(
                      monthLabel(col),
                      style: TextStyle(fontSize: 8.5, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.visible,
                    ),
                  )),
                ),
                const SizedBox(height: 3),
                // Cell grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(numCols, (col) => Column(
                    children: List.generate(7, (row) {
                      final date = weeks[col][row];
                      final pages = date == null ? 0 : (dayPages['${date.year}-${date.month}-${date.day}'] ?? 0);
                      final isToday = date != null && date == today;
                      return Container(
                        width: _cellSize,
                        height: _cellSize,
                        margin: const EdgeInsets.only(right: _gap, bottom: _gap),
                        decoration: BoxDecoration(
                          color: date == null ? Colors.transparent : _cellColor(pages, cs),
                          borderRadius: BorderRadius.circular(2),
                          border: isToday ? Border.all(color: cs.primary, width: 1.5) : null,
                        ),
                      );
                    }),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(l10n.analyticsHeatmapLess, style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)),
              const SizedBox(width: 4),
              ...[0, 3, 10, 25, 50].map((p) => Container(
                width: 11, height: 11,
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  color: _cellColor(p, cs),
                  borderRadius: BorderRadius.circular(2),
                ),
              )),
              const SizedBox(width: 4),
              Text(l10n.analyticsHeatmapMore, style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
