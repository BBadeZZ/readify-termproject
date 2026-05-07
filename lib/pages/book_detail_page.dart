import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../widgets/book_cover_widget.dart';
import 'edit_book_page.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final FirestoreService service = FirestoreService();

  late Book book;
  late TextEditingController pageController;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();

    book = widget.book;
    pageController = TextEditingController(text: book.currentPage.toString());
    noteController = TextEditingController(text: book.note);
  }

  @override
  void dispose() {
    pageController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void updateProgress() async {
    int newPage = int.tryParse(pageController.text) ?? book.currentPage;

    if (newPage < 0) {
      newPage = 0;
    }

    if (newPage > book.totalPages) {
      newPage = book.totalPages;
    }

    setState(() {
      book.currentPage = newPage;
      book.note = noteController.text.trim();

      if (book.currentPage == book.totalPages) {
        book.status = 'Already Read';
      } else if (book.currentPage > 0) {
        book.status = 'Reading';
      } else {
        book.status = 'Wishlist';
      }
    });

    await service.updateBook(book);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book updated.')),
    );
  }

  void toggleFavorite() async {
    setState(() {
      book.favorite = !book.favorite;
    });

    await service.updateBook(book);
  }

  @override
  Widget build(BuildContext context) {
    int percent = (book.progress * 100).toInt();

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
                MaterialPageRoute(
                  builder: (context) {
                    return EditBookPage(book: book);
                  },
                ),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE29A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                BookCoverWidget(
                  title: book.title,
                  coverUrl: book.coverUrl,
                  width: 110,
                  height: 155,
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
                  style: const TextStyle(
                    color: Colors.brown,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: const Color(0xFFFFFBF0),
            child: ListTile(
              leading: const Icon(Icons.category, color: Colors.brown),
              title: const Text(
                'Genre',
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                book.genre,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Card(
            color: const Color(0xFFFFFBF0),
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.brown),
              title: const Text(
                'Status',
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                book.status,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Card(
            color: const Color(0xFFFFFBF0),
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.deepOrange),
              title: const Text(
                'Rating',
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                '${book.rating} / 5',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
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
            decoration: const InputDecoration(
              labelText: 'Current Page',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 4,
            style: const TextStyle(fontSize: 17),
            decoration: const InputDecoration(
              labelText: 'Personal Note',
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: updateProgress,
            icon: const Icon(Icons.update),
            label: const Text('Update Progress'),
          ),
        ],
      ),
    );
  }
}