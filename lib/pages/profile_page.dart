import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reading_session.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _service = FirestoreService();

  List<Book> _books = [];
  List<ReadingSession> _sessions = [];
  bool _loading = true;

  StreamSubscription? _booksSub;
  StreamSubscription? _sessionsSub;

  @override
  void initState() {
    super.initState();
    _booksSub = _service.getBooks().listen((books) {
      setState(() {
        _books = books;
        _loading = false;
      });
    });
    _sessionsSub = _service.getSessions().listen((sessions) {
      setState(() => _sessions = sessions);
    });
  }

  @override
  void dispose() {
    _booksSub?.cancel();
    _sessionsSub?.cancel();
    super.dispose();
  }

  String _favoriteGenre() {
    if (_books.isEmpty) return '—';
    final counts = <String, int>{};
    for (final b in _books) {
      counts[b.genre] = (counts[b.genre] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final name = user?.displayName ?? 'Readify User';
    final email = user?.email ?? '';

    // Book stats
    final totalBooks = _books.length;
    final finished = _books.where((b) => b.status == 'Already Read').length;
    final reading = _books.where((b) => b.status == 'Reading').length;
    final wishlist = _books.where((b) => b.status == 'Wishlist').length;
    final favorites = _books.where((b) => b.favorite).length;
    final totalPages = _books.fold(0, (s, b) => s + b.currentPage);
    final favoriteGenre = _favoriteGenre();

    // Session stats
    final totalSessions = _sessions.length;
    final totalMinutes =
        _sessions.fold(0, (s, e) => s + e.durationMinutes);
    final totalHours = totalMinutes ~/ 60;
    final remMin = totalMinutes % 60;
    final avgSession =
        totalSessions == 0 ? 0 : totalMinutes ~/ totalSessions;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Profile'),
      appBar: AppBar(title: const Text('My Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar + name card
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE29A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 52, color: Colors.brown),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.brown.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Favorite genre badge
                      if (favoriteGenre != '—')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite,
                                  size: 16, color: Colors.pinkAccent),
                              const SizedBox(width: 6),
                              Text(
                                'Favorite genre: $favoriteGenre',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Library stats
                const _SectionTitle('Library'),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    _StatCard('Total Books', '$totalBooks',
                        Icons.book, Colors.brown),
                    _StatCard('Finished', '$finished',
                        Icons.check_circle, Colors.green),
                    _StatCard('Reading', '$reading',
                        Icons.auto_stories, Colors.orange),
                    _StatCard('Wishlist', '$wishlist',
                        Icons.bookmark, Colors.amber),
                    _StatCard('Favorites', '$favorites',
                        Icons.favorite, Colors.pink),
                    _StatCard('Pages Read', '$totalPages',
                        Icons.pages, Colors.teal),
                  ],
                ),

                const SizedBox(height: 24),

                // Reading activity
                const _SectionTitle('Reading Activity'),
                const SizedBox(height: 10),
                if (totalSessions == 0)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.timer_off, color: Colors.brown),
                        SizedBox(width: 12),
                        Text(
                          'No reading sessions yet.\nOpen a book and start reading!',
                          style:
                              TextStyle(color: Colors.brown, fontSize: 14),
                        ),
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
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard('Sessions', '$totalSessions',
                          Icons.timer, Colors.indigo),
                      _StatCard(
                        'Total Time',
                        totalHours > 0
                            ? '${totalHours}h ${remMin}m'
                            : '${totalMinutes}m',
                        Icons.schedule,
                        Colors.teal,
                      ),
                      _StatCard('Avg Session', '${avgSession}m',
                          Icons.bar_chart, Colors.purple),
                      _StatCard(
                        'Pages in Sessions',
                        '${_sessions.fold(0, (s, e) => s + e.pagesRead)}',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.brown,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.brown),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
