import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/stat_card.dart';
import '../theme/app_colors.dart';
import 'book_detail_page.dart';
import '../utils/page_transitions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName() {
    final name = authService.currentUser?.displayName ?? '';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
            tooltip: 'Add Book',
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: firestoreService.getBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!;
          final totalBooks = books.length;
          final reading = books.where((b) => b.status == 'Reading').toList();
          final alreadyRead = books.where((b) => b.status == 'Already Read').length;
          final pagesRead = books.fold(0, (sum, b) => sum + b.currentPage);

          // Sort currently reading by most progress
          reading.sort((a, b) => b.progress.compareTo(a.progress));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Greeting
              Text(
                '${_greeting()}, ${_firstName()} 👋',
                style: tt.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s your reading overview',
                style: tt.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  StatCard(
                    label: 'Total Books',
                    value: '$totalBooks',
                    icon: Icons.book_rounded,
                    color: cs.primaryContainer,
                    iconColor: cs.primary,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'All'}),
                  ),
                  StatCard(
                    label: 'Reading',
                    value: '${reading.length}',
                    icon: Icons.auto_stories_rounded,
                    color: AppColors.readingBlueContainer,
                    iconColor: AppColors.readingBlue,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'Reading'}),
                  ),
                  StatCard(
                    label: 'Already Read',
                    value: '$alreadyRead',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.completedGreenContainer,
                    iconColor: AppColors.completedGreen,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'Already Read'}),
                  ),
                  StatCard(
                    label: 'Pages Read',
                    value: '$pagesRead',
                    icon: Icons.menu_book_rounded,
                    color: cs.secondaryContainer,
                    iconColor: cs.secondary,
                    onTap: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'All'}),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Currently Reading section
              if (reading.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Currently Reading', style: tt.titleLarge),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/library', arguments: {'filter': 'Reading'}),
                      child: Text('See all', style: TextStyle(color: cs.primary)),
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Quick actions
              Text('Quick Actions', style: tt.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_rounded,
                      label: 'Add Book',
                      color: cs.primary,
                      onTap: () => Navigator.pushNamed(context, '/add'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.library_books_rounded,
                      label: 'My Library',
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
                      label: 'Suggestions',
                      color: const Color(0xFF7E5EA8),
                      onTap: () => Navigator.pushNamed(context, '/recommendations'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.bar_chart_rounded,
                      label: 'Analytics',
                      color: const Color(0xFF1A6FA8),
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
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _ReadingBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _ReadingBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = (book.progress * 100).toInt();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
                      backgroundColor: cs.primaryContainer,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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
                  Text('$count books already read', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer, fontSize: 15)),
                  Text('Tap to view your reading history', style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
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
