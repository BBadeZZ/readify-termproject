import 'package:flutter/material.dart';
import '../data/recommended_books.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';

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
      bool alreadyRead = book.status == 'Already Read';

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
        'status': 'Wishlist',
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
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFBF0),
          title: Text(
            book.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
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
                  'Author: ${book.author}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Genre: ${book.genre}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Pages: ${book.pages}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Rating: ${book.rating}',
                  style: const TextStyle(fontSize: 16),
                ),
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.brown),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                sendBookToAddPage(
                  context,
                  book,
                  favorite: false,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add This Book'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                sendBookToAddPage(
                  context,
                  book,
                  favorite: true,
                );
              },
              icon: const Icon(Icons.favorite),
              label: const Text('Add to Favorites'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService service = FirestoreService();

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Recommendations'),
      appBar: AppBar(title: const Text('Book Recommendations')),
      body: StreamBuilder<List<Book>>(
        stream: service.getBooks(),
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

          if (visibleRecommendations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'You have already read all recommended books 💛',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
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
                onTap: () {
                  showBookDetail(context, book);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFF7D774),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black12,
                        offset: Offset(0, 4),
                      ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.brown,
                        ),
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
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 15,
                        ),
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