import 'package:flutter/material.dart';
import '../data/recommended_books.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';
import '../l10n/app_localizations.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  String normalize(String value) {
    return value.trim().toLowerCase();
  }

  bool isAlreadyReadRecommendation(
      RecommendedBook recommendedBook,
      List<Book> userBooks,
      ) {
    return userBooks.any((book) {
      bool sameTitle =
          normalize(book.title) == normalize(recommendedBook.title);
      bool sameAuthor =
          normalize(book.author) == normalize(recommendedBook.author);
      bool alreadyRead = book.status == BookStatus.alreadyRead;

      return sameTitle && sameAuthor && alreadyRead;
    });
  }

  void sendBookToAddPage(
      BuildContext context,
      RecommendedBook book, {
        required bool favorite,
      }) {
    Navigator.pop(context);

    Navigator.pushNamed(
      context,
      '/add',
      arguments: {
        'title': book.title,
        'author': book.author,
        'genre': book.genre,
        'totalPages': book.pages.toString(),
        'currentPage': '0',
        'note': book.description,
        'status': BookStatus.wishlist,
        'rating': book.rating.round(),
        'favorite': favorite,
        'coverUrl': book.coverUrl,
      },
    );
  }

  void showBookDetail(BuildContext context, RecommendedBook book) {
    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(
            book.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                BookCoverWidget(
                  title: book.title,
                  coverUrl: book.coverUrl,
                  width: 100,
                  height: 145,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.recsAuthor(book.author),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: cs.primary),
                ),
                const SizedBox(height: 8),
                Text(l10n.recsGenre(book.genre), style: const TextStyle(fontSize: 16)),
                Text(l10n.recsPages(book.pages), style: const TextStyle(fontSize: 16)),
                Text(l10n.recsRating(book.rating.toString()), style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  book.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.recsClose),
            ),
            ElevatedButton.icon(
              onPressed: () => sendBookToAddPage(context, book, favorite: false),
              icon: const Icon(Icons.add),
              label: Text(l10n.recsAddBook),
            ),
            ElevatedButton.icon(
              onPressed: () => sendBookToAddPage(context, book, favorite: true),
              icon: const Icon(Icons.favorite),
              label: Text(l10n.recsAddFavorite),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Recommendations'),
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.recsTitle)),
      body: StreamBuilder<List<Book>>(
        stream: firestoreService.getBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Book> userBooks = snapshot.data!;

          List<RecommendedBook> visibleRecommendations =
          recommendedBooks.where((recommendedBook) {
            return !isAlreadyReadRecommendation(
              recommendedBook,
              userBooks,
            );
          }).toList();

          final cs = Theme.of(context).colorScheme;
          final l10n = AppLocalizations.of(context)!;

          if (visibleRecommendations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.recsAllRead,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: cs.primary, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: visibleRecommendations.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.66,
            ),
            itemBuilder: (context, index) {
              final book = visibleRecommendations[index];

              return InkWell(
                onTap: () => showBookDetail(context, book),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.outlineVariant, width: 2),
                    boxShadow: [
                      BoxShadow(blurRadius: 6, color: cs.primary.withValues(alpha: 0.08), offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      BookCoverWidget(
                        title: book.title,
                        coverUrl: book.coverUrl,
                        width: 90,
                        height: 125,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.primary),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        book.author,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${book.rating} ★',
                        style: const TextStyle(color: AppColors.starYellow, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}