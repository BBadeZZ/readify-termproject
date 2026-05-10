import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reading_session.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';

class AnalyticsPage extends StatefulWidget {
  AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        drawer: const AppDrawer(currentPage: 'Analytics'),
        appBar: AppBar(title: const Text('Reading Analytics')),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      );
    }

    // Book stats
    final totalBooks = _books.length;
    final reading = _books.where((b) => b.status == 'Reading').length;
    final finished = _books.where((b) => b.status == 'Finished').length;
    final wishlist = _books.where((b) => b.status == 'Wishlist').length;
    final alreadyRead = _books.where((b) => b.status == 'Already Read').length;
    final favorite = _books.where((b) => b.favorite).length;

    int pagesRead = 0;
    int totalPages = 0;
    int ratingSum = 0;
    for (final b in _books) {
      pagesRead += b.currentPage;
      totalPages += b.totalPages;
      ratingSum += b.rating;
    }
    final avgRating = totalBooks == 0 ? 0.0 : ratingSum / totalBooks;
    final progress = totalPages == 0 ? 0.0 : pagesRead / totalPages;

    // Session stats
    final totalSessions = _sessions.length;
    final totalMinutes =
        _sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalHours = totalMinutes ~/ 60;
    final remainingMin = totalMinutes % 60;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekSessions = _sessions.where((s) => s.startedAt.isAfter(weekAgo));
    final weekPages = weekSessions.fold(0, (sum, s) => sum + s.pagesRead);
    final avgSession = totalSessions == 0
        ? 0
        : (_sessions.fold(0, (s, e) => s + e.durationMinutes) ~/
            totalSessions);

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Analytics'),
      appBar: AppBar(title: const Text('Reading Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Book stats
          const Text(
            'Your Reading Summary',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 16),
          _box('Total Books', '$totalBooks', Icons.book, Colors.brown),
          _box('Currently Reading', '$reading', Icons.auto_stories,
              Colors.orange),
          _box('Finished Books', '$finished', Icons.check_circle, Colors.green),
          _box('Wishlist Books', '$wishlist', Icons.bookmark, Colors.amber),
          _box('Already Read', '$alreadyRead', Icons.history, Colors.deepOrange),
          _box('Favorite Books', '$favorite', Icons.favorite, Colors.pink),
          _box('Pages Read', '$pagesRead', Icons.pages, Colors.teal),
          _box('Average Rating', avgRating.toStringAsFixed(1), Icons.star,
              Colors.deepOrange),

          // Overall progress
          const SizedBox(height: 20),
          const Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 14,
            color: Colors.amber,
            backgroundColor: Colors.amberAccent,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% of all saved pages completed',
            style: const TextStyle(fontSize: 16),
          ),

          // Session stats
          const SizedBox(height: 28),
          const Text(
            'Reading Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 12),
          if (totalSessions == 0)
            Container(
              padding: const EdgeInsets.all(20),
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
                    'No sessions yet.\nStart reading a book!',
                    style: TextStyle(color: Colors.brown, fontSize: 15),
                  ),
                ],
              ),
            )
          else ...[
            _box('Total Sessions', '$totalSessions', Icons.timer,
                Colors.indigo),
            _box(
              'Total Reading Time',
              totalHours > 0
                  ? '${totalHours}h ${remainingMin}m'
                  : '${totalMinutes}m',
              Icons.schedule,
              Colors.teal,
            ),
            _box('Pages This Week', '$weekPages', Icons.trending_up,
                Colors.green),
            _box('Avg Session', '${avgSession}m', Icons.bar_chart,
                Colors.purple),
            const SizedBox(height: 20),
            const Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 8),
            ..._sessions.take(5).map((s) => _sessionCard(s)),
          ],
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _box(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(ReadingSession s) {
    final date =
        '${s.startedAt.day}/${s.startedAt.month}/${s.startedAt.year}';
    return Card(
      color: const Color(0xFFFFFBF0),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.menu_book, color: Colors.white, size: 20),
        ),
        title: Text(
          s.bookTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$date  •  ${s.durationMinutes}m  •  ${s.pagesRead} pages'),
        trailing: Text(
          '${s.pagesRead}p',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}
