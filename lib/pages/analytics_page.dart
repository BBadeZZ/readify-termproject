import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';

class AnalyticsPage extends StatelessWidget {
  final FirestoreService service = FirestoreService();

  AnalyticsPage({super.key});

  Widget analyticsBox(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Analytics'),
      appBar: AppBar(title: const Text('Reading Analytics')),
      body: StreamBuilder<List<Book>>(
        stream: service.getBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Book> books = snapshot.data!;

          int totalBooks = books.length;
          int finished = books.where((b) => b.status == 'Finished').length;
          int reading = books.where((b) => b.status == 'Reading').length;
          int wishlist = books.where((b) => b.status == 'Wishlist').length;
          int alreadyRead = books.where((b) => b.status == 'Already Read').length;
          int favorite = books.where((b) => b.favorite).length;

          int pagesRead = 0;
          int totalPages = 0;
          int ratingSum = 0;

          for (Book b in books) {
            pagesRead += b.currentPage;
            totalPages += b.totalPages;
            ratingSum += b.rating;
          }

          double avgRating = totalBooks == 0 ? 0 : ratingSum / totalBooks;
          double progress = totalPages == 0 ? 0 : pagesRead / totalPages;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Your Reading Summary',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 16),
              analyticsBox('Total Books', '$totalBooks', Icons.book, Colors.brown),
              analyticsBox('Currently Reading', '$reading', Icons.auto_stories, Colors.orange),
              analyticsBox('Finished Books', '$finished', Icons.check_circle, Colors.green),
              analyticsBox('Wishlist Books', '$wishlist', Icons.bookmark, Colors.amber),
              analyticsBox('Already Read', '$alreadyRead', Icons.history, Colors.deepOrange),
              analyticsBox('Favorite Books', '$favorite', Icons.favorite, Colors.pink),
              analyticsBox('Pages Read', '$pagesRead', Icons.pages, Colors.teal),
              analyticsBox('Average Rating', avgRating.toStringAsFixed(1), Icons.star, Colors.deepOrange),
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
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}