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

    await firestoreService.addSession(session);
    await settingsService.clearActiveSession();

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

    await firestoreService.updateBook(book);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session saved! ${durationMinutes}m · $pagesRead pages read'),
          backgroundColor: const Color(0xFF1E8040),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    await firestoreService.updateBook(book);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Progress saved.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void toggleFavorite() async {
    setState(() => book.favorite = !book.favorite);
    await firestoreService.updateBook(book);
  }

  void _setRating(int rating) async {
    setState(() => book.rating = rating);
    await firestoreService.updateBook(book);
  }

  Color _statusColor(BuildContext context) {
    switch (book.status) {
      case 'Reading':
        return const Color(0xFF1A6FA8);
      case 'Already Read':
        return const Color(0xFF1E8040);
      case 'Wishlist':
        return const Color(0xFFB8740A);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = (book.progress * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Detail'),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                book.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(book.favorite),
                color: book.favorite ? Colors.pink : cs.onSurface.withValues(alpha: 0.6),
              ),
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
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // Session banner
          if (_sessionActive) ...[
            const SizedBox(height: 12),
            _buildSessionBanner(cs),
          ],

          const SizedBox(height: 16),

          // Book header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'book-cover-${book.id}',
                  child: BookCoverWidget(
                    title: book.title,
                    coverUrl: book.coverUrl,
                    width: 100,
                    height: 142,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall?.copyWith(color: cs.onPrimaryContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  textAlign: TextAlign.center,
                  style: tt.bodyLarge?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 14),
                // Star rating
                _StarRating(rating: book.rating, onRate: _setRating),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info pills row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _InfoPill(
                  icon: Icons.category_outlined,
                  label: book.genre,
                  color: cs.tertiaryContainer,
                  textColor: cs.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.circle,
                  label: book.status,
                  color: _statusColor(context).withValues(alpha: 0.15),
                  textColor: _statusColor(context),
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.import_contacts_outlined,
                  label: '${book.totalPages} pages',
                  color: cs.surfaceContainerHighest,
                  textColor: cs.onSurface,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Progress section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reading Progress', style: tt.titleMedium),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: book.progress,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${book.currentPage} of ${book.totalPages} pages',
                  style: tt.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Page + Note inputs
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                TextField(
                  controller: pageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Page',
                    prefixIcon: Icon(Icons.bookmark_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Personal Note',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.notes_rounded),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: updateProgress,
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: const Text('Save Progress'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Reading session button
          if (!_sessionActive)
            OutlinedButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Start Reading Session'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E8040),
                side: const BorderSide(color: Color(0xFF1E8040), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _finishSession,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Finish Reading Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8040),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionBanner(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCF5E4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E8040), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E8040).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_rounded, color: Color(0xFF1E8040), size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session in progress',
                style: TextStyle(color: Color(0xFF1E8040), fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                _formatDuration(_elapsed),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E8040), height: 1.1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRate;

  const _StarRating({required this.rating, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => onRate(star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: star <= rating ? const Color(0xFFE8A020) : Colors.grey.shade400,
              size: 30,
            ),
          ),
        );
      }),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _InfoPill({required this.icon, required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}
