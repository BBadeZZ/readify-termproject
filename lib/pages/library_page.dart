import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';
import 'book_detail_page.dart';
import '../utils/page_transitions.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final FirestoreService service = FirestoreService();

  String filter = 'All';
  String searchText = '';
  String sortBy = 'Date Added';
  bool argsLoaded = false;
  String infoMessage = '';
  Timer? _debounce;

  final TextEditingController searchController = TextEditingController();

  static const _sortOptions = ['Date Added', 'Title', 'Author', 'Progress'];

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
    _debounce?.cancel();
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
            book.status.toLowerCase().contains(query) ||
            book.note.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    switch (sortBy) {
      case 'Title':
        filteredBooks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Author':
        filteredBooks.sort((a, b) => a.author.compareTo(b.author));
        break;
      case 'Progress':
        filteredBooks.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      default: // Date Added
        filteredBooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filteredBooks;
  }

  String pageTitle() {
    if (filter == 'All') return 'All Books';
    if (filter == 'Reading') return 'Currently Reading';
    if (filter == 'Already Read') return 'Completed Books';
    if (filter == 'Pages Read') return 'Pages Read Details';
    if (filter == 'Wishlist') return 'Wishlist Books';
    if (filter == 'Favorite Books') return 'Favorite Books ❤️';

    return 'My Library';
  }

  String emptyMessage() {
    if (filter == 'Favorite Books') {
      return 'No favorite books yet.\nTap the heart icon to add books here.';
    }

    if (filter == 'Reading') {
      return 'No reading books found.';
    }

    if (filter == 'Wishlist') {
      return 'Your wishlist is empty.';
    }

    if (filter == 'Already Read') {
      return 'No completed books yet.';
    }

    return 'No books found.';
  }

  IconData emptyIcon() {
    if (filter == 'Favorite Books') {
      return Icons.favorite_border;
    }

    if (filter == 'Wishlist') {
      return Icons.bookmark_border;
    }

    if (filter == 'Already Read') {
      return Icons.menu_book;
    }

    return Icons.library_books_outlined;
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

  Widget buildFilterButton(String item, double fontSize) {
    bool selected = filter == item;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              filter = item;
              infoMessage = '';
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: selected ? Colors.brown.shade200 : Colors.white,
            side: BorderSide(
              color: selected ? Colors.brown : Colors.brown.shade200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 9),
          ),
          child: Text(
            item,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.brown : Colors.brown.shade500,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoIcon({
    required String message,
    required IconData icon,
    required Color color,
    required bool smallScreen,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          infoMessage = message;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: EdgeInsets.all(smallScreen ? 6 : 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade100),
        ),
        child: Icon(
          icon,
          color: color,
          size: smallScreen ? 15 : 17,
        ),
      ),
    );
  }

  Widget buildInfoRow(
      int visibleBooks,
      int totalBooks,
      int favoriteBooks,
      int readingBooks,
      bool smallScreen,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: smallScreen ? 14 : 18,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$visibleBooks books found',
                  style: TextStyle(
                    fontSize: smallScreen ? 12 : 14,
                    color: Colors.brown.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              buildInfoIcon(
                message: 'Total Books: $totalBooks',
                icon: Icons.library_books,
                color: Colors.brown,
                smallScreen: smallScreen,
              ),
              buildInfoIcon(
                message: 'Favorite Books: $favoriteBooks',
                icon: Icons.favorite,
                color: Colors.pinkAccent,
                smallScreen: smallScreen,
              ),
              buildInfoIcon(
                message: 'Reading Books: $readingBooks',
                icon: Icons.menu_book,
                color: Colors.green,
                smallScreen: smallScreen,
              ),
            ],
          ),
          if (infoMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.brown.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                infoMessage,
                style: TextStyle(
                  color: Colors.brown.shade700,
                  fontSize: smallScreen ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool smallScreen = screenWidth < 380;

    double coverWidth = smallScreen ? 48 : 55;
    double coverHeight = smallScreen ? 70 : 78;
    double titleFontSize = smallScreen ? 16 : 18;
    double normalFontSize = smallScreen ? 13 : 15;
    double filterFontSize = smallScreen ? 10 : 12;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Library'),
      appBar: AppBar(
        title: Text(pageTitle()),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            initialValue: sortBy,
            onSelected: (value) => setState(() => sortBy = value),
            itemBuilder: (_) => _sortOptions
                .map((o) => PopupMenuItem(
                      value: o,
                      child: Row(
                        children: [
                          if (sortBy == o)
                            const Icon(Icons.check,
                                size: 18, color: Colors.brown),
                          if (sortBy != o) const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(o),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(smallScreen ? 10 : 12),
            child: TextField(
              controller: searchController,
              enabled: true,
              readOnly: false,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontSize: smallScreen ? 15 : 17,
                color: Colors.brown,
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    searchText = value;
                    infoMessage = '';
                  });
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
                      infoMessage = '';
                      searchController.clear();
                    });
                  },
                )
                    : null,
                hintText: 'Search book, author or genre...',
                hintStyle: TextStyle(
                  color: Colors.brown,
                  fontSize: smallScreen ? 14 : 16,
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
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: smallScreen ? 8 : 12,
              vertical: 6,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    buildFilterButton('All', filterFontSize),
                    buildFilterButton('Reading', filterFontSize),
                    buildFilterButton('Wishlist', filterFontSize),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    buildFilterButton('Already Read', filterFontSize),
                    buildFilterButton('Pages Read', filterFontSize),
                    buildFilterButton('Favorite Books', filterFontSize),
                  ],
                ),
              ],
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<Book> allBooks = snapshot.data!;
                List<Book> books = applyFilter(allBooks);

                int totalBooks = allBooks.length;
                int favoriteBooks =
                    allBooks.where((book) => book.favorite == true).length;
                int readingBooks =
                    allBooks.where((book) => book.status == 'Reading').length;

                if (books.isEmpty) {
                  return Column(
                    children: [
                      buildInfoRow(
                        books.length,
                        totalBooks,
                        favoriteBooks,
                        readingBooks,
                        smallScreen,
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  emptyIcon(),
                                  size: smallScreen ? 65 : 80,
                                  color: Colors.brown.shade300,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  searchText.isNotEmpty
                                      ? 'No result found for "$searchText".'
                                      : emptyMessage(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: smallScreen ? 17 : 20,
                                    color: Colors.brown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    buildInfoRow(
                      books.length,
                      totalBooks,
                      favoriteBooks,
                      readingBooks,
                      smallScreen,
                    ),
                    Expanded(
                      child: ListView.builder(
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
                                    backgroundColor:
                                    const Color(0xFFFFFBF0),
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
                              elevation: 3,
                              shadowColor: Colors.brown.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: smallScreen ? 8 : 12,
                                vertical: 7,
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(
                                  smallScreen ? 10 : 12,
                                ),
                                leading: Hero(
                                  tag: 'book-cover-${book.id}',
                                  child: BookCoverWidget(
                                    title: book.title,
                                    coverUrl: book.coverUrl,
                                    width: coverWidth,
                                    height: coverHeight,
                                  ),
                                ),
                                title: Text(
                                  book.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: titleFontSize,
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
                                      style: TextStyle(
                                        fontSize: normalFontSize,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor(book.status)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              book.status,
                                              style: TextStyle(
                                                color:
                                                statusColor(book.status),
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                smallScreen ? 11 : 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.brown.shade100,
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              book.genre,
                                              style: TextStyle(
                                                color: Colors.brown,
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                smallScreen ? 10 : 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${book.currentPage} / ${book.totalPages} pages',
                                      style: TextStyle(
                                        fontSize: smallScreen ? 12 : 13,
                                        color: Colors.brown.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${(book.progress * 100).toInt()}% completed',
                                      style: TextStyle(
                                        fontSize: smallScreen ? 12 : 13,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: book.progress,
                                      minHeight: 6,
                                      backgroundColor: Colors.brown.shade100,
                                      color: statusColor(book.status),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      book.favorite = !book.favorite;
                                      infoMessage = '';
                                    });
                                    service.updateBook(book);
                                  },
                                  icon: AnimatedSwitcher(
                                    duration:
                                    const Duration(milliseconds: 250),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child: Icon(
                                      book.favorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      key: ValueKey<bool>(book.favorite),
                                      color: book.favorite
                                          ? Colors.pinkAccent
                                          : Colors.brown,
                                      size: smallScreen ? 24 : 28,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlidePageRoute(
                                      page: BookDetailPage(book: book),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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