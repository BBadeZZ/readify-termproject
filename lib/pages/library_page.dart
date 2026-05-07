import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';
import 'book_detail_page.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final FirestoreService service = FirestoreService();

  String filter = 'All';
  String searchText = '';
  bool argsLoaded = false;

  final TextEditingController searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argsLoaded) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['filter'] != null) {
        String incomingFilter = args['filter'];

        if ([
          'All',
          'Reading',
          'Wishlist',
          'Already Read',
          'Pages Read',
          'Favorite Books',
        ].contains(incomingFilter)) {
          filter = incomingFilter;
        } else {
          filter = 'All';
        }
      }

      argsLoaded = true;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Book> applyFilter(List<Book> books) {
    List<Book> filteredBooks = books;

    if (filter == 'Reading') {
      filteredBooks =
          filteredBooks.where((book) => book.status == 'Reading').toList();
    } else if (filter == 'Wishlist') {
      filteredBooks =
          filteredBooks.where((book) => book.status == 'Wishlist').toList();
    } else if (filter == 'Already Read') {
      filteredBooks =
          filteredBooks.where((book) => book.status == 'Already Read').toList();
    } else if (filter == 'Pages Read') {
      filteredBooks =
          filteredBooks.where((book) => book.currentPage > 0).toList();
    } else if (filter == 'Favorite Books') {
      filteredBooks =
          filteredBooks.where((book) => book.favorite == true).toList();
    }

    if (searchText.trim().isNotEmpty) {
      filteredBooks = filteredBooks.where((book) {
        final query = searchText.toLowerCase().trim();

        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.genre.toLowerCase().contains(query) ||
            book.status.toLowerCase().contains(query);
      }).toList();
    }

    return filteredBooks;
  }

  String pageTitle() {
    if (filter == 'All') return 'All Books';
    if (filter == 'Reading') return 'Currently Reading Books';
    if (filter == 'Already Read') return 'Already Read Books';
    if (filter == 'Pages Read') return 'Pages Read Details';
    if (filter == 'Wishlist') return 'Wishlist Books';
    if (filter == 'Favorite Books') return 'Favorite Books';

    return 'My Library';
  }

  Color statusColor(String status) {
    if (status == 'Reading') {
      return Colors.blue;
    } else if (status == 'Wishlist') {
      return Colors.orange;
    } else if (status == 'Already Read') {
      return Colors.green;
    }

    return Colors.brown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Library'),
      appBar: AppBar(
        title: Text(pageTitle()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              enabled: true,
              readOnly: false,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.brown,
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.brown,
                ),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.brown,
                  ),
                  onPressed: () {
                    setState(() {
                      searchText = '';
                      searchController.clear();
                    });
                  },
                )
                    : null,
                hintText: 'Search book, author or genre...',
                hintStyle: const TextStyle(
                  color: Colors.brown,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.brown.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.brown,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown.shade200),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              value: filter,
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(
                fontSize: 17,
                color: Colors.brown,
              ),
              items: [
                'All',
                'Reading',
                'Wishlist',
                'Already Read',
                'Pages Read',
                'Favorite Books',
              ].map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text('Show: $item'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  filter = value!;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: service.getBooks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Something went wrong while loading books.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Book> books = applyFilter(snapshot.data!);

                if (books.isEmpty) {
                  return Center(
                    child: Text(
                      searchText.isNotEmpty
                          ? 'No result found for "$searchText".'
                          : 'No books found for "$filter".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    Book book = books[index];

                    return Dismissible(
                      key: Key(book.id),
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFFFFFBF0),
                              title: const Text('Delete Book'),
                              content: const Text(
                                'Do you want to delete this book?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ) ??
                            false;
                      },
                      onDismissed: (direction) {
                        service.deleteBook(book.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Book deleted.'),
                          ),
                        );
                      },
                      child: Card(
                        color: const Color(0xFFFFFBF0),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: BookCoverWidget(
                            title: book.title,
                            coverUrl: book.coverUrl,
                            width: 55,
                            height: 78,
                          ),
                          title: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.brown,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  statusColor(book.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  book.status,
                                  style: TextStyle(
                                    color: statusColor(book.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${(book.progress * 100).toInt()}% completed',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: book.progress,
                                minHeight: 6,
                                backgroundColor: Colors.brown.shade100,
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ],
                          ),
                          trailing: book.favorite
                              ? const Icon(
                            Icons.favorite,
                            color: Colors.pinkAccent,
                          )
                              : const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return BookDetailPage(book: book);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}