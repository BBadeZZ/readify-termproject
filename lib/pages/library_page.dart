import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';
import 'book_detail_page.dart';
import '../utils/page_transitions.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {

  String filter = 'All';
  String searchText = '';
  String sortBy = 'Date Added';
  bool argsLoaded = false;
  Timer? _debounce;

  final TextEditingController searchController = TextEditingController();

  static const _filters = ['All', 'Reading', 'Wishlist', 'Already Read', 'Favorites'];
  static const _sortOptions = ['Date Added', 'Title', 'Author', 'Progress'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['filter'] != null) {
        final incoming = args['filter'] as String;
        if (['All', 'Reading', 'Wishlist', 'Already Read', 'Pages Read', 'Favorite Books'].contains(incoming)) {
          // Map legacy filter names to new ones
          filter = incoming == 'Favorite Books' ? 'Favorites' : incoming == 'Pages Read' ? 'All' : incoming;
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
    List<Book> result = books;
    if (filter == 'Reading') result = result.where((b) => b.status == 'Reading').toList();
    else if (filter == 'Wishlist') result = result.where((b) => b.status == 'Wishlist').toList();
    else if (filter == 'Already Read') result = result.where((b) => b.status == 'Already Read').toList();
    else if (filter == 'Favorites') result = result.where((b) => b.favorite).toList();

    if (searchText.trim().isNotEmpty) {
      final q = searchText.toLowerCase().trim();
      result = result.where((b) =>
        b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        b.genre.toLowerCase().contains(q) ||
        b.note.toLowerCase().contains(q)
      ).toList();
    }

    switch (sortBy) {
      case 'Title': result.sort((a, b) => a.title.compareTo(b.title));
      case 'Author': result.sort((a, b) => a.author.compareTo(b.author));
      case 'Progress': result.sort((a, b) => b.progress.compareTo(a.progress));
      default: result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }


  String _emptyMessage() {
    if (searchText.isNotEmpty) return 'No results for "$searchText"';
    switch (filter) {
      case 'Favorites': return 'No favorites yet.\nTap the heart icon on any book.';
      case 'Reading': return 'Not reading anything right now.';
      case 'Wishlist': return 'Your wishlist is empty.';
      case 'Already Read': return 'No completed books yet.';
      default: return 'No books found. Add one!';
    }
  }

  IconData _emptyIcon() {
    switch (filter) {
      case 'Favorites': return Icons.favorite_border_rounded;
      case 'Wishlist': return Icons.bookmark_border_rounded;
      case 'Already Read': return Icons.menu_book_rounded;
      default: return Icons.library_books_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Library'),
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            initialValue: sortBy,
            onSelected: (v) => setState(() => sortBy = v),
            itemBuilder: (_) => _sortOptions.map((o) => PopupMenuItem(
              value: o,
              child: Row(children: [
                Icon(sortBy == o ? Icons.check_rounded : null, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(o),
              ]),
            )).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() => searchText = value);
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          searchText = '';
                          searchController.clear();
                        }),
                      )
                    : null,
                hintText: 'Search title, author, genre…',
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _filters[index];
                final selected = filter == item;
                return FilterChip(
                  label: Text(item),
                  selected: selected,
                  onSelected: (_) => setState(() => filter = item),
                  showCheckmark: false,
                  avatar: selected ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimaryContainer) : null,
                );
              },
            ),
          ),

          // Book list
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: firestoreService.getBooks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBooks = snapshot.data!;
                final books = applyFilter(allBooks);

                // Summary bar
                final favCount = allBooks.where((b) => b.favorite).length;
                final readingCount = allBooks.where((b) => b.status == 'Reading').length;

                return Column(
                  children: [
                    // Summary row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            '${books.length} book${books.length == 1 ? '' : 's'}',
                            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          _SummaryChip(icon: Icons.library_books_rounded, value: allBooks.length, color: cs.primary),
                          const SizedBox(width: 6),
                          _SummaryChip(icon: Icons.favorite_rounded, value: favCount, color: Colors.pink),
                          const SizedBox(width: 6),
                          _SummaryChip(icon: Icons.auto_stories_rounded, value: readingCount, color: const Color(0xFF1A6FA8)),
                        ],
                      ),
                    ),

                    Expanded(
                      child: books.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_emptyIcon(), size: 72, color: cs.outlineVariant),
                                  const SizedBox(height: 16),
                                  Text(_emptyMessage(), textAlign: TextAlign.center, style: tt.titleMedium?.copyWith(color: cs.outline)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return _BookCard(
                                  book: book,
                                  statusColor: AppColors.forStatus(book.status),
                                  onTap: () => Navigator.push(context, SlidePageRoute(page: BookDetailPage(book: book))),
                                  onFavorite: () {
                                    setState(() => book.favorite = !book.favorite);
                                    firestoreService.updateBook(book);
                                  },
                                  onDelete: () async {
                                    final deletedBook = book;
                                    try {
                                      await firestoreService.deleteBook(deletedBook.id);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Failed to delete book.'),
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('"${deletedBook.title}" deleted.'),
                                          duration: const Duration(seconds: 5),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () async {
                                              try {
                                                await firestoreService.addBook(deletedBook);
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: const Text('Could not restore book.'),
                                                      backgroundColor: Theme.of(context).colorScheme.error,
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  },
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
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const _SummaryChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text('$value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const _BookCard({
    required this.book,
    required this.statusColor,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(book.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // StreamBuilder handles visual removal after Firestore confirms
      },
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'book-cover-${book.id}',
                  child: BookCoverWidget(title: book.title, coverUrl: book.coverUrl, width: 54, height: 78),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.2),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              book.status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              book.genre,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.7)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: book.progress,
                                minHeight: 5,
                                backgroundColor: cs.surfaceContainerHighest,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(book.progress * 100).toInt()}%',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onFavorite,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      book.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      key: ValueKey(book.favorite),
                      color: book.favorite ? Colors.pink : cs.outline,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
