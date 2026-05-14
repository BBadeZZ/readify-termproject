import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../services/social_service.dart';
import '../services/firestore_service.dart';
import '../widgets/book_cover_widget.dart';

class FriendLibraryPage extends StatelessWidget {
  final String friendUid;
  final String friendName;

  const FriendLibraryPage({
    super.key,
    required this.friendUid,
    required this.friendName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.socialFriendLibrary(friendName)),
      ),
      body: StreamBuilder<List<Book>>(
        stream: socialService.getFriendBooks(friendUid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snap.data ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 56,
                    color: cs.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.socialEmptyLibrary,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, i) => _BookCard(
              book: books[i],
              friendUid: friendUid,
              friendName: friendName,
              cs: cs,
              l10n: l10n,
            ),
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final String friendUid;
  final String friendName;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _BookCard({
    required this.book,
    required this.friendUid,
    required this.friendName,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final progress = book.totalPages > 0
        ? (book.currentPage / book.totalPages).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCoverWidget(
              title: book.title,
              coverUrl: book.coverUrl,
              width: 56,
              height: 80,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatusChip(
                        status: book.status,
                        cs: cs,
                        l10n: l10n,
                      ),
                      if (book.totalPages > 0) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${book.currentPage}/${book.totalPages} p.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => _confirmAdd(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.library_add_rounded,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.socialAddToLibrary,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _confirmAdd(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.socialAddToLibrary),
        content: Text('"${book.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.detailCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.socialAddToLibrary),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final myBooks = await firestoreService.getBooks().first;

      final targetTitle = _normalize(book.title);
      final targetAuthor = _normalize(book.author);

      final alreadyExists = myBooks.any((myBook) {
        final myTitle = _normalize(myBook.title);
        final myAuthor = _normalize(myBook.author);

        if (myTitle != targetTitle) {
          return false;
        }

        if (targetAuthor.isEmpty || myAuthor.isEmpty) {
          return true;
        }

        return myAuthor == targetAuthor;
      });

      if (alreadyExists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'This book is already in your library.',
              ),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      final copy = Book(
        id: '',
        title: book.title,
        author: book.author,
        genre: book.genre,
        totalPages: book.totalPages,
        currentPage: 0,
        status: BookStatus.wishlist,
        rating: 1,
        note: '',
        favorite: false,
        coverUrl: book.coverUrl,
        createdAt: DateTime.now(),
      );

      await firestoreService.addBook(copy);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.socialBookAdded),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.librarySomethingWrong),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _StatusChip({
    required this.status,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;

    if (status == BookStatus.reading) {
      label = l10n.statusReading;
      bg = cs.primaryContainer;
    } else if (status == BookStatus.alreadyRead) {
      label = l10n.statusAlreadyRead;
      bg = cs.secondaryContainer;
    } else {
      label = l10n.statusWishlist;
      bg = cs.tertiaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}