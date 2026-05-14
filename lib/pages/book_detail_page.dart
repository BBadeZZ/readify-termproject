import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reading_session.dart';
import '../models/book_status.dart';
import '../services/firestore_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/book_cover_widget.dart';
import '../l10n/app_localizations.dart';
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

  List<ReadingSession> _sessions = [];
  bool _sessionsError = false;
  StreamSubscription<List<ReadingSession>>? _sessionsSub;
  final TextEditingController _newNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    book = widget.book;
    pageController = TextEditingController(text: book.currentPage.toString());
    noteController = TextEditingController(text: book.note);
    _restoreActiveSession();
    _sessionsSub = firestoreService.getSessions().listen(
      (all) {
        if (mounted) {
          setState(() {
            _sessionsError = false;
            _sessions = all
                .where((s) => s.bookId == book.id)
                .toList()
              ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _sessionsError = true);
      },
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sessionsSub?.cancel();
    pageController.dispose();
    noteController.dispose();
    _newNoteController.dispose();
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

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
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

    try {
      await firestoreService.addSession(session);
      await settingsService.clearActiveSession();

      final newStatus = endPage >= book.totalPages
          ? BookStatus.alreadyRead
          : endPage > 0
              ? BookStatus.reading
              : book.status;
      setState(() {
        book = book.copyWith(currentPage: endPage, status: newStatus);
        pageController.text = endPage.toString();
        _sessionActive = false;
        _sessionStart = null;
        _elapsed = Duration.zero;
      });

      await firestoreService.updateBook(book);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.detailSessionSaved(durationMinutes, pagesRead)),
            backgroundColor: AppColors.completedGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.detailErrSaveSession),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<int?> _showFinishDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: book.currentPage.toString());
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.detailFinishDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailDuration(_formatDuration(_elapsed)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(l10n.detailWhatPage),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.fieldCurrentPage,
                hintText: '1 – ${book.totalPages}',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(l10n.detailCancel),
          ),
          ElevatedButton(
            onPressed: () {
              int page = int.tryParse(controller.text) ?? book.currentPage;
              page = page.clamp(0, book.totalPages);
              Navigator.pop(ctx, page);
            },
            child: Text(l10n.detailSaveSession),
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
    final l10n = AppLocalizations.of(context)!;
    final original = book;
    int newPage = int.tryParse(pageController.text) ?? book.currentPage;
    newPage = newPage.clamp(0, book.totalPages);
    final newNote = noteController.text.trim();
    final newStatus = newPage >= book.totalPages
        ? BookStatus.alreadyRead
        : newPage > 0
            ? BookStatus.reading
            : BookStatus.wishlist;

    setState(() {
      book = book.copyWith(currentPage: newPage, note: newNote, status: newStatus);
    });

    try {
      await firestoreService.updateBook(book);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.detailProgressSaved),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        book = original;
        pageController.text = original.currentPage.toString();
        noteController.text = original.note;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.detailErrProgress),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void toggleFavorite() async {
    final original = book;
    setState(() => book = book.copyWith(favorite: !book.favorite));
    try {
      await firestoreService.updateBook(book);
    } catch (e) {
      setState(() => book = original);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.detailErrFavorite),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _setRating(int rating) async {
    final original = book;
    setState(() => book = book.copyWith(rating: rating));
    try {
      await firestoreService.updateBook(book);
    } catch (e) {
      setState(() => book = original);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.detailErrRating),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _addNote() async {
    final text = _newNoteController.text.trim();
    if (text.isEmpty) return;
    final updated = List<String>.from(book.notes)..add(text);
    setState(() { book = book.copyWith(notes: updated); });
    _newNoteController.clear();
    try {
      await firestoreService.updateBook(book);
    } catch (_) {
      final rollback = List<String>.from(book.notes)..removeLast();
      setState(() { book = book.copyWith(notes: rollback); });
    }
  }

  void _deleteNote(int index) async {
    final previous = List<String>.from(book.notes);
    final updated = List<String>.from(book.notes)..removeAt(index);
    setState(() { book = book.copyWith(notes: updated); });
    try {
      await firestoreService.updateBook(book);
    } catch (_) {
      setState(() { book = book.copyWith(notes: previous); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detailTitle),
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
            _buildSessionBanner(cs, l10n),
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
                  label: AppColors.localizeStatus(book.status, l10n),
                  color: AppColors.forStatus(book.status).withValues(alpha: 0.15),
                  textColor: AppColors.forStatus(book.status),
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.import_contacts_outlined,
                  label: l10n.detailPages(book.totalPages),
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
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: book.progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, animValue, _) {
                    final animPercent = (animValue * 100).toInt();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.detailReadingProgress, style: tt.titleMedium),
                            Text(
                              '$animPercent%',
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
                            value: animValue,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.pagesProgress(book.currentPage, book.totalPages),
                          style: tt.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Page + Note inputs
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                TextField(
                  controller: pageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.fieldCurrentPage,
                    prefixIcon: const Icon(Icons.bookmark_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.fieldNote,
                    prefixIcon: const Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: Icon(Icons.notes_rounded),
                      ),
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
                    label: Text(l10n.detailSaveProgress),
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
              label: Text(l10n.detailStartSession),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.completedGreen,
                side: const BorderSide(color: AppColors.completedGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _finishSession,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(l10n.detailFinishSession),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.completedGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

          const SizedBox(height: 24),
          _buildSessionHistory(l10n, tt, cs),

          const SizedBox(height: 24),
          _buildNotesSection(l10n, tt, cs),
        ],
      ),
    );
  }

  Widget _buildSessionHistory(AppLocalizations l10n, TextTheme tt, ColorScheme cs) {
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
          Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(l10n.detailSessionHistory, style: tt.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (_sessionsError)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, size: 16, color: cs.error),
                  const SizedBox(width: 8),
                  Text(
                    l10n.librarySomethingWrong,
                    style: tt.bodyMedium?.copyWith(color: cs.error),
                  ),
                ],
              ),
            )
          else if (_sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  l10n.analyticsNoSessions,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            )
          else
            ...(_sessions.take(5).map((s) {
              final date = '${s.startedAt.day}.${s.startedAt.month.toString().padLeft(2, '0')}.${s.startedAt.year}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.menu_book_rounded, size: 16, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date, style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                          Text(l10n.detailSessionFormat(s.durationMinutes, s.pagesRead), style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })),
        ],
      ),
    );
  }

  Widget _buildNotesSection(AppLocalizations l10n, TextTheme tt, ColorScheme cs) {
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
          Row(
            children: [
              Icon(Icons.sticky_note_2_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(l10n.detailNotes, style: tt.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (book.notes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.detailAddNote,
                style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.45)),
              ),
            )
          else
            ...book.notes.asMap().entries.map((entry) {
              final i = entry.key;
              final note = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(note, style: tt.bodyMedium)),
                    GestureDetector(
                      onTap: () => _deleteNote(i),
                      child: Icon(Icons.close_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newNoteController,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: l10n.detailNoteHint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _addNote,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.detailNoteSave),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionBanner(ColorScheme cs, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.completedGreenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.completedGreen, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.completedGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_rounded, color: AppColors.completedGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.detailSessionInProgress,
                style: const TextStyle(color: AppColors.completedGreen, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                _formatDuration(_elapsed),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.completedGreen, height: 1.1),
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
              color: star <= rating ? AppColors.starYellow : Theme.of(context).colorScheme.outline,
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
