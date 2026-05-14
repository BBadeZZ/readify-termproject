import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../models/reading_session.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/streak_utils.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/stat_card.dart';
import '../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  List<Book> _books = [];
  List<ReadingSession> _sessions = [];
  String _favoriteGenre = '—';
  bool _loading = true;

  StreamSubscription? _booksSub;
  StreamSubscription? _sessionsSub;

  @override
  void initState() {
    super.initState();
    _booksSub = firestoreService.getBooks().listen((books) {
      if (mounted) {
        setState(() {
          _books = books;
          _loading = false;
          _favoriteGenre = _computeFavoriteGenre(books);
        });
      }
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

  Future<void> _exportLibrary(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await exportService.exportBooks(_books);
    } catch (_) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.profileExportError),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  static String _computeFavoriteGenre(List<Book> books) {
    if (books.isEmpty) return '—';
    final counts = <String, int>{};
    for (final b in books) {
      counts[b.genre] = (counts[b.genre] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final user = authService.currentUser;
    final name = user?.displayName ?? 'Readify User';
    final email = user?.email ?? '';

    final totalBooks = _books.length;
    final finished = _books.where((b) => b.status == BookStatus.alreadyRead).length;
    final reading = _books.where((b) => b.status == BookStatus.reading).length;
    final wishlist = _books.where((b) => b.status == BookStatus.wishlist).length;
    final favorites = _books.where((b) => b.favorite).length;
    final totalPages = _books.fold(0, (s, b) => s + b.currentPage);
    final favoriteGenre = _favoriteGenre;
    final streak = calculateStreak(_sessions);

    final totalSessions = _sessions.length;
    final totalMinutes = _sessions.fold(0, (s, e) => s + e.durationMinutes);
    final totalHours = totalMinutes ~/ 60;
    final remMin = totalMinutes % 60;
    final avgSession = totalSessions == 0 ? 0 : totalMinutes ~/ totalSessions;
    final sessionPages = _sessions.fold(0, (s, e) => s + e.pagesRead);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Profile'),
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: l10n.profileExportLibrary,
              onPressed: _books.isEmpty ? null : () => _exportLibrary(l10n),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primaryContainer, cs.secondaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: cs.surface,
                        child: Icon(Icons.person, size: 52, color: cs.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: tt.headlineSmall?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (favoriteGenre != '—')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.favorite, size: 14, color: Colors.pinkAccent),
                                  const SizedBox(width: 5),
                                  Text(
                                    l10n.profileFavoriteGenre(favoriteGenre),
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (favoriteGenre != '—' && streak > 0) const SizedBox(width: 8),
                          if (streak > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$streak ${l10n.profileStreakLabel}',
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(l10n.profileLibrary, style: tt.titleLarge),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: [
                    StatCard(label: l10n.profileTotalBooks, value: '$totalBooks', icon: Icons.book_rounded, color: cs.primaryContainer, iconColor: cs.primary),
                    StatCard(label: l10n.profileFinished, value: '$finished', icon: Icons.check_circle_rounded, color: AppColors.completedGreenContainer, iconColor: AppColors.completedGreen),
                    StatCard(label: l10n.profileReading, value: '$reading', icon: Icons.auto_stories_rounded, color: AppColors.readingBlueContainer, iconColor: AppColors.readingBlue),
                    StatCard(label: l10n.profileWishlist, value: '$wishlist', icon: Icons.bookmark_rounded, color: cs.secondaryContainer, iconColor: cs.secondary),
                    StatCard(label: l10n.profileFavorites, value: '$favorites', icon: Icons.favorite_rounded, color: AppColors.favoritesContainer, iconColor: Colors.pink),
                    StatCard(label: l10n.profilePagesRead, value: '$totalPages', icon: Icons.menu_book_rounded, color: AppColors.pagesTealContainer, iconColor: AppColors.pagesTeal),
                  ],
                ),

                const SizedBox(height: 24),
                Text(l10n.profileAchievements, style: tt.titleLarge),
                const SizedBox(height: 12),
                _AchievementsRow(
                  books: _books,
                  sessions: _sessions,
                  totalPages: totalPages,
                  streak: streak,
                ),

                const SizedBox(height: 24),
                Text(l10n.profileActivity, style: tt.titleLarge),
                const SizedBox(height: 10),

                if (totalSessions == 0)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_off_outlined, color: cs.outline, size: 28),
                        const SizedBox(width: 12),
                        Text(l10n.profileNoSessions, style: tt.bodyMedium),
                      ],
                    ),
                  )
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(label: l10n.profileSessions, value: '$totalSessions', icon: Icons.timer_rounded, color: AppColors.sessionPurpleContainer, iconColor: AppColors.sessionPurple),
                      StatCard(
                        label: l10n.profileTotalTime,
                        value: totalHours > 0
                            ? '${totalHours}h ${remMin}m'
                            : totalMinutes > 0
                                ? '${totalMinutes}m'
                                : '< 1m',
                        icon: Icons.schedule_rounded,
                        color: AppColors.pagesTealContainer,
                        iconColor: AppColors.pagesTeal,
                      ),
                      StatCard(
                        label: l10n.profileAvgSession,
                        value: avgSession > 0 ? '${avgSession}m' : '< 1m',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.readingBlueContainer,
                        iconColor: AppColors.readingBlue,
                      ),
                      StatCard(label: l10n.profilePagesInSessions, value: '$sessionPages', icon: Icons.trending_up_rounded, color: AppColors.completedGreenContainer, iconColor: AppColors.completedGreen),
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  final List<Book> books;
  final List<ReadingSession> sessions;
  final int totalPages;
  final int streak;

  const _AchievementsRow({
    required this.books,
    required this.sessions,
    required this.totalPages,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final finished = books.where((b) => b.status == BookStatus.alreadyRead).length;
    final favorites = books.where((b) => b.favorite).length;
    final maxSessionPages = sessions.isEmpty ? 0 : sessions.map((s) => s.pagesRead).reduce((a, b) => a > b ? a : b);
    final maxSessionMin = sessions.isEmpty ? 0 : sessions.map((s) => s.durationMinutes).reduce((a, b) => a > b ? a : b);
    final hasHighRating = books.any((b) => b.rating >= 4);

    final l10n = AppLocalizations.of(context)!;
    final badges = [
      (emoji: '📚', label: l10n.achieveFirstBook,    unlocked: books.isNotEmpty),
      (emoji: '🎯', label: l10n.achieve5Books,        unlocked: books.length >= 5),
      (emoji: '🏆', label: l10n.achieve10Books,       unlocked: books.length >= 10),
      (emoji: '✅', label: l10n.achieveFirstFinish,   unlocked: finished >= 1),
      (emoji: '❤️', label: l10n.achieveCollector,    unlocked: favorites >= 5),
      (emoji: '💯', label: l10n.achieve100Pages,      unlocked: totalPages >= 100),
      (emoji: '📖', label: l10n.achieve1000Pages,     unlocked: totalPages >= 1000),
      (emoji: '⚡', label: l10n.achieveSpeedReader,   unlocked: maxSessionPages >= 50),
      (emoji: '⏱️', label: l10n.achieveMarathoner,   unlocked: maxSessionMin >= 60),
      (emoji: '🔥', label: l10n.achieve7DayStreak,    unlocked: streak >= 7),
      (emoji: '⭐', label: l10n.achieveCritic,        unlocked: hasHighRating),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final b = badges[i];
          return Opacity(
            opacity: b.unlocked ? 1.0 : 0.35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 76,
                decoration: BoxDecoration(
                  color: b.unlocked ? cs.primaryContainer : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: b.unlocked ? Border.all(color: cs.primary.withValues(alpha: 0.4)) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(b.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        b.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.labelSmall?.copyWith(
                          fontSize: 9,
                          height: 1.15,
                          fontWeight: b.unlocked ? FontWeight.bold : FontWeight.normal,
                          color: b.unlocked ? cs.onPrimaryContainer : cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
