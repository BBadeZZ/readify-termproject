import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
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

  StreamSubscription? _booksSub;
  StreamSubscription? _sessionsSub;

  @override
  void initState() {
    super.initState();
    _booksSub = firestoreService.getBooks().listen((books) {
      if (mounted) setState(() { _books = books; _loading = false; });
    });
    _sessionsSub = firestoreService.getSessions().listen((sessions) {
      if (mounted) setState(() => _sessions = sessions);
    });
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

    final totalBooks = _books.length;
    final reading = _books.where((b) => b.status == 'Reading').length;
    final wishlist = _books.where((b) => b.status == 'Wishlist').length;
    final alreadyRead = _books.where((b) => b.status == 'Already Read').length;
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
            childAspectRatio: 1.6,
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

          const SizedBox(height: 24),

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
              childAspectRatio: 1.6,
              children: [
                StatCard(label: l10n.analyticsSessions, value: '$totalSessions', icon: Icons.timer_rounded, color: AppColors.sessionPurpleContainer, iconColor: AppColors.sessionPurple),
                StatCard(
                  label: l10n.analyticsTotalTime,
                  value: totalHours > 0 ? '${totalHours}h ${remainingMin}m' : '${totalMinutes}m',
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
            child: const Icon(Icons.menu_book_rounded, color: Color(0xFF5E35B1), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.bookTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('$date  ·  ${s.durationMinutes}m  ·  ${l10n.detailPages(s.pagesRead)}',
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
              '+${s.pagesRead}p',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5E35B1), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
