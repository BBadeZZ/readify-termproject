import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reading_session.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/settings_service.dart';
import '../utils/streak_utils.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/stat_card.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'book_detail_page.dart';
import '../utils/page_transitions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetMorning;
    if (hour < 17) return l10n.homeGreetAfternoon;
    return l10n.homeGreetEvening;
  }

  String _firstName(AppLocalizations l10n) {
    final name = authService.currentUser?.displayName ?? '';
    if (name.trim().isEmpty) return l10n.homeReader;
    return name.split(' ').first;
  }

  void _showQuickPageSheet(BuildContext context, Book book) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: book.currentPage.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.homeUpdatePage, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              book.title,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.homeCurrentPage,
                hintText: '1 – ${book.totalPages}',
                prefixIcon: const Icon(Icons.bookmark_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  int newPage = int.tryParse(controller.text) ?? book.currentPage;
                  newPage = newPage.clamp(0, book.totalPages);
                  Navigator.pop(ctx);
                  final updated = book.copyWith(
                    currentPage: newPage,
                    status: newPage >= book.totalPages
                        ? 'Already Read'
                        : newPage > 0
                            ? 'Reading'
                            : book.status,
                  );
                  try {
                    await firestoreService.updateBook(updated);
                  } catch (_) {}
                },
                child: Text(l10n.homeSave),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Home'),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_rounded, color: cs.primary, size: 24),
            const SizedBox(width: 8),
            Text('Readify', style: tt.headlineSmall),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/add'),
            icon: Icon(Icons.add_circle_outline_rounded, color: cs.primary, size: 26),
            tooltip: l10n.homeAddBook,
          ),
        ],
      ),
      body: StreamBuilder<List<ReadingSession>>(
        stream: firestoreService.getSessions(),
        builder: (context, sessionsSnapshot) {
          final streak = calculateStreak(sessionsSnapshot.data ?? []);
          return StreamBuilder<List<Book>>(
            stream: firestoreService.getBooks(),
            builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 52, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.librarySomethingWrong,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!;

          if (books.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_stories_rounded, size: 80, color: Theme.of(context).colorScheme.primaryContainer),
                    const SizedBox(height: 20),
                    Text(
                      l10n.homeAddBook,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.libraryEmptyDefault,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/add'),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.homeAddBook),
                    ),
                  ],
                ),
              ),
            );
          }
          final totalBooks = books.length;
          final reading = books.where((b) => b.status == 'Reading').toList();
          final alreadyRead = books.where((b) => b.status == 'Already Read').length;
          final pagesRead = books.fold(0, (sum, b) => sum + b.currentPage);

          reading.sort((a, b) => b.progress.compareTo(a.progress));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                '${_greeting(l10n)}, ${_firstName(l10n)} 👋',
                style: tt.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.homeSubtitle,
                style: tt.bodyMedium,
              ),
              const SizedBox(height: 24),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  StatCard(
                    label: l10n.homeTotalBooks,
                    value: '$totalBooks',
                    icon: Icons.book_rounded,
                    color: cs.primaryContainer,
                    iconColor: cs.primary,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'All'}),
                  ),
                  StatCard(
                    label: l10n.homeReading,
                    value: '${reading.length}',
                    icon: Icons.auto_stories_rounded,
                    color: AppColors.readingBlueContainer,
                    iconColor: AppColors.readingBlue,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'Reading'}),
                  ),
                  StatCard(
                    label: l10n.homeAlreadyRead,
                    value: '$alreadyRead',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.completedGreenContainer,
                    iconColor: AppColors.completedGreen,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'Already Read'}),
                  ),
                  StatCard(
                    label: l10n.homePagesRead,
                    value: '$pagesRead',
                    icon: Icons.menu_book_rounded,
                    color: cs.secondaryContainer,
                    iconColor: cs.secondary,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'All'}),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _DailyGoalCard(sessions: sessionsSnapshot.data ?? []),
              const SizedBox(height: 12),
              _StreakBanner(streak: streak),
              const SizedBox(height: 16),

              if (reading.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.homeCurrentlyReading, style: tt.titleLarge),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'Reading'}),
                      child: Text(l10n.homeSeeAll, style: TextStyle(color: cs.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: reading.length > 5 ? 5 : reading.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final book = reading[index];
                      return _ReadingBookCard(
                        book: book,
                        onTap: () => Navigator.push(
                          context,
                          SlidePageRoute(page: BookDetailPage(book: book)),
                        ),
                        onLongPress: () => _showQuickPageSheet(context, book),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],

              Text(l10n.homeQuickActions, style: tt.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_rounded,
                      label: l10n.homeAddBook,
                      color: cs.primary,
                      onTap: () => Navigator.pushNamed(context, '/add'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.library_books_rounded,
                      label: l10n.homeMyLibrary,
                      color: cs.secondary,
                      onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'All'}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.auto_awesome_rounded,
                      label: l10n.homeSuggestions,
                      color: AppColors.suggestionsPurple,
                      onTap: () => Navigator.pushNamed(context, '/recommendations'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.bar_chart_rounded,
                      label: l10n.navAnalytics,
                      color: AppColors.readingBlue,
                      onTap: () => Navigator.pushNamed(context, '/analytics'),
                    ),
                  ),
                ],
              ),

              if (alreadyRead > 0) ...[
                const SizedBox(height: 20),
                _AlreadyReadBanner(count: alreadyRead, onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'Already Read'})),
              ],
            ],
          );
        },
      );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final List<ReadingSession> sessions;

  const _DailyGoalCard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final goal = settingsService.dailyGoal.toInt();
    final today = DateTime.now();
    final todayPages = sessions
        .where((s) =>
            s.startedAt.year == today.year &&
            s.startedAt.month == today.month &&
            s.startedAt.day == today.day)
        .fold(0, (sum, s) => sum + s.pagesRead);
    final progress = (todayPages / goal).clamp(0.0, 1.0);
    final done = todayPages >= goal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: done ? AppColors.completedGreenContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? AppColors.completedGreen.withValues(alpha: 0.35)
              : cs.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                done ? Icons.check_circle_rounded : Icons.track_changes_rounded,
                color: done ? AppColors.completedGreen : cs.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                done ? l10n.homeGoalReached : l10n.homeGoalTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: done ? AppColors.completedGreen : cs.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                l10n.homeGoalProgress(todayPages, goal),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                done ? AppColors.completedGreen : cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int streak;

  const _StreakBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = streak > 0 ? l10n.streakDays(streak) : l10n.streakStart;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.starYellowContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.starYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.starYellow,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ReadingBookCard({required this.book, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = (book.progress * 100).toInt();

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'book-cover-${book.id}',
                child: BookCoverWidget(title: book.title, coverUrl: book.coverUrl, width: 70, height: 96),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.2),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      minHeight: 5,
                      backgroundColor: cs.surfaceContainerHighest,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$percent%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlreadyReadBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _AlreadyReadBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.secondaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.history_edu_rounded, color: cs.primary, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.homeBooksAlreadyRead(count), style: TextStyle(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer, fontSize: 15)),
                  Text(AppLocalizations.of(context)!.homeViewHistory, style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
