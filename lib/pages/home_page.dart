import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';

class HomePage extends StatelessWidget {
  final FirestoreService service = FirestoreService();

  HomePage({super.key});

  Widget statCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      String libraryFilter,
      ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/library',
          arguments: {
            'filter': libraryFilter,
          },
        );
      },
      child: Container(
        width: 155,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.brown,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.brown, size: 34),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.brown,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.brown,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Home'),
      appBar: AppBar(title: const Text('Readify Home')),
      body: StreamBuilder<List<Book>>(
        stream: service.getBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Book> books = snapshot.data!;

          int totalBooks = books.length;
          int reading = books.where((b) => b.status == 'Reading').length;
          int finished = books.where((b) => b.status == 'Finished').length;
          int alreadyRead =
              books.where((b) => b.status == 'Already Read').length;

          int pagesRead = 0;

          for (Book b in books) {
            pagesRead += b.currentPage;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Welcome to Readify 💛',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your books, covers, reading progress, notes and cozy statistics.',
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 18),

              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  statCard(
                    context,
                    'Books',
                    '$totalBooks',
                    Icons.book,
                    const Color(0xFFFFE29A),
                    'All',
                  ),
                  statCard(
                    context,
                    'Reading',
                    '$reading',
                    Icons.auto_stories,
                    const Color(0xFFFFD6A5),
                    'Reading',
                  ),
                  statCard(
                    context,
                    'Finished',
                    '$finished',
                    Icons.check_circle,
                    const Color(0xFFCDE7BE),
                    'Finished',
                  ),
                  statCard(
                    context,
                    'Already Read',
                    '$alreadyRead',
                    Icons.history,
                    const Color(0xFFFFE6C7),
                    'Already Read',
                  ),
                  statCard(
                    context,
                    'Pages Read',
                    '$pagesRead',
                    Icons.pages,
                    const Color(0xFFFFC8DD),
                    'Pages Read',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/add');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Book'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/library',
                    arguments: {
                      'filter': 'All',
                    },
                  );
                },
                icon: const Icon(Icons.library_books),
                label: const Text('Go to My Library'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}