import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reading_session.dart';
import '../services/firestore_service.dart';
import '../services/settings_service.dart';
import '../widgets/book_cover_widget.dart';
import 'edit_book_page.dart';
import '../utils/page_transitions.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final FirestoreService _service = FirestoreService();

  late Book book;
  late TextEditingController pageController;
  late TextEditingController noteController;

  bool _sessionActive = false;
  DateTime? _sessionStart;
  int _sessionStartPage = 0;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    pageController = TextEditingController(text: book.currentPage.toString());
    noteController = TextEditingController(text: book.note);
    _restoreActiveSession();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    pageController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _restoreActiveSession() {
    final savedBookId = settingsService.activeSessionBookId;
    final savedStart = settingsService.activeSessionStartTime;
    if (savedBookId == book.id && savedStart != null) {
      _sessionStart = savedStart;
      _sessionStartPage = settingsService.activeSessionStartPage;
      _sessionActive = true;
      _elapsed = DateTime.now().difference(_sessionStart!);
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_sessionStart!);
      });
    });
  }

  void _startSession() async {
    final now = DateTime.now();
    await settingsService.saveActiveSession(book.id, now, book.currentPage);
    setState(() {
      _sessionActive = true;
      _sessionStart = now;
      _sessionStartPage = book.currentPage;
      _elapsed = Duration.zero;
    });
    _startTicker();
  }

  void _finishSession() async {
    _ticker?.cancel();
    _ticker = null;

    final endPage = await _showFinishDialog();
    if (endPage == null) {
      // User cancelled — resume ticker
      _startTicker();
      return;
    }

    final endedAt = DateTime.now();
    final durationMinutes = _elapsed.inMinutes;
    final pagesRead = (endPage - _sessionStartPage).clamp(0, book.totalPages);

    final session = ReadingSession(
      id: '',
      bookId: book.id,
      bookTitle: book.title,
      startedAt: _sessionStart!,
      endedAt: endedAt,
      pagesRead: pagesRead,
      durationMinutes: durationMinutes,
    );

    await _service.addSession(session);
    await settingsService.clearActiveSession();

    // Update book progress with new page
    setState(() {
      book.currentPage = endPage;
      pageController.text = endPage.toString();
      if (book.currentPage >= book.totalPages) {
        book.status = 'Already Read';
      } else if (book.currentPage > 0) {
        book.status = 'Reading';
      }
      _sessionActive = false;
      _sessionStart = null;
      _elapsed = Duration.zero;
    });

    await _service.updateBook(book);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Session saved! ${durationMinutes}m • $pagesRead pages read',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<int?> _showFinishDialog() async {
    final controller = TextEditingController(text: book.currentPage.toString());
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Finish Reading Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration: ${_formatDuration(_elapsed)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('What page did you reach?'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Page',
                hintText: '1 – ${book.totalPages}',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              int page = int.tryParse(controller.text) ?? book.currentPage;
              page = page.clamp(0, book.totalPages);
              Navigator.pop(ctx, page);
            },
            child: const Text('Save Session'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void updateProgress() async {
    int newPage = int.tryParse(pageController.text) ?? book.currentPage;
    newPage = newPage.clamp(0, book.totalPages);

    setState(() {
      book.currentPage = newPage;
      book.note = noteController.text.trim();
      if (book.currentPage >= book.totalPages) {
        book.status = 'Already Read';
      } else if (book.currentPage > 0) {
        book.status = 'Reading';
      } else {
        book.status = 'Wishlist';
      }
    });

    await _service.updateBook(book);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book updated.')),
      );
    }
  }

  void toggleFavorite() async {
    setState(() => book.favorite = !book.favorite);
    await _service.updateBook(book);
  }

  @override
  Widget build(BuildContext context) {
    final percent = (book.progress * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Detail'),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              book.favorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.pinkAccent,
            ),
          ),
          IconButton(
            onPressed: () async {
              final updatedBook = await Navigator.push<Book>(
                context,
                SlidePageRoute(page: EditBookPage(book: book)),
              );
              if (updatedBook != null) {
                setState(() {
                  book = updatedBook;
                  pageController.text = book.currentPage.toString();
                  noteController.text = book.note;
                });
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active session banner
          if (_sessionActive) _buildSessionBanner(),

          // Book header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE29A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'book-cover-${book.id}',
                  child: BookCoverWidget(
                    title: book.title,
                    coverUrl: book.coverUrl,
                    width: 110,
                    height: 155,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.brown,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  book.author,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.brown, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _infoCard(Icons.category, 'Genre', book.genre),
          _infoCard(Icons.info, 'Status', book.status),
          _infoCard(Icons.star, 'Rating', '${book.rating} / 5',
              iconColor: Colors.deepOrange),

          const SizedBox(height: 18),
          Text(
            'Reading Progress: $percent%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: book.progress,
            minHeight: 12,
            color: Colors.amber,
            backgroundColor: Colors.amberAccent,
          ),
          const SizedBox(height: 18),

          TextField(
            controller: pageController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 17),
            decoration: const InputDecoration(labelText: 'Current Page'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 4,
            style: const TextStyle(fontSize: 17),
            decoration: const InputDecoration(labelText: 'Personal Note'),
          ),
          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: updateProgress,
            icon: const Icon(Icons.update),
            label: const Text('Update Progress'),
          ),
          const SizedBox(height: 12),

          // Reading session button
          if (!_sessionActive)
            OutlinedButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Start Reading Session'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _finishSession,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Finish Reading Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSessionBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.green),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reading session in progress',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDuration(_elapsed),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value,
      {Color iconColor = Colors.brown}) {
    return Card(
      color: const Color(0xFFFFFBF0),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
