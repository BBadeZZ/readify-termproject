import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/book_cover_widget.dart';
import '../l10n/app_localizations.dart';
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

  static const _filters = [
    'All',
    BookStatus.reading,
    BookStatus.wishlist,
    BookStatus.alreadyRead,
    'Favorites'
  ];

  static const _sortOptions = [
    'Date Added',
    'Title',
    'Author',
    'Progress'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['filter'] != null) {
        final incoming = args['filter'] as String;

        if ([
          'All',
          BookStatus.reading,
          BookStatus.wishlist,
          BookStatus.alreadyRead,
          'Pages Read',
          'Favorite Books'
        ].contains(incoming)) {
          filter = incoming == 'Favorite Books'
              ? 'Favorites'
              : incoming == 'Pages Read'
              ? 'All'
              : incoming;
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

    if (filter == BookStatus.reading) {
      result = result.where((b) => b.status == BookStatus.reading).toList();
    } else if (filter == BookStatus.wishlist) {
      result = result.where((b) => b.status == BookStatus.wishlist).toList();
    } else if (filter == BookStatus.alreadyRead) {
      result = result.where((b) => b.status == BookStatus.alreadyRead).toList();
    } else if (filter == 'Favorites') {
      result = result.where((b) => b.favorite).toList();
    }

    if (searchText.trim().isNotEmpty) {
      final q = searchText.toLowerCase().trim();

      result = result.where((b) {
        return b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q) ||
            b.genre.toLowerCase().contains(q) ||
            b.note.toLowerCase().contains(q);
      }).toList();
    }

    switch (sortBy) {
      case 'Title':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Author':
        result.sort((a, b) => a.author.compareTo(b.author));
        break;
      case 'Progress':
        result.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result;
  }

  String _emptyMessage(AppLocalizations l10n) {
    if (searchText.isNotEmpty) {
      return l10n.libraryNoResults(searchText);
    }

    switch (filter) {
      case 'Favorites':
        return l10n.libraryEmptyFavorites;
      case BookStatus.reading:
        return l10n.libraryEmptyReading;
      case BookStatus.wishlist:
        return l10n.libraryEmptyWishlist;
      case BookStatus.alreadyRead:
        return l10n.libraryEmptyAlreadyRead;
      default:
        return l10n.libraryEmptyDefault;
    }
  }

  String _filterLabel(String f, AppLocalizations l10n) {
    switch (f) {
      case 'All':
        return l10n.libraryFilterAll;
      case BookStatus.reading:
        return l10n.statusReading;
      case BookStatus.wishlist:
        return l10n.statusWishlist;
      case BookStatus.alreadyRead:
        return l10n.statusAlreadyRead;
      case 'Favorites':
        return l10n.libraryFilterFavorites;
      default:
        return f;
    }
  }

  String _sortLabel(String s, AppLocalizations l10n) {
    switch (s) {
      case 'Date Added':
        return l10n.librarySortDateAdded;
      case 'Title':
        return l10n.librarySortTitle;
      case 'Author':
        return l10n.librarySortAuthor;
      case 'Progress':
        return l10n.librarySortProgress;
      default:
        return s;
    }
  }

  IconData _emptyIcon() {
    switch (filter) {
      case 'Favorites':
        return Icons.favorite_border_rounded;
      case BookStatus.wishlist:
        return Icons.bookmark_border_rounded;
      case BookStatus.alreadyRead:
        return Icons.menu_book_rounded;
      default:
        return Icons.library_books_outlined;
    }
  }

  void _showAutoCloseSnackBar({
    required BuildContext context,
    required SnackBar snackBar,
    Duration closeAfter = const Duration(seconds: 5),
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    final controller = messenger.showSnackBar(snackBar);

    Future.delayed(closeAfter, () {
      controller.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Library'),
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            initialValue: sortBy,
            onSelected: (v) => setState(() => sortBy = v),
            itemBuilder: (_) {
              return _sortOptions.map((o) {
                return PopupMenuItem(
                  value: o,
                  child: Row(
                    children: [
                      Icon(
                        sortBy == o ? Icons.check_rounded : null,
                        size: 18,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(_sortLabel(o, l10n)),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: cs.primary,
                ),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      searchText = '';
                      searchController.clear();
                    });
                  },
                )
                    : null,
                hintText: l10n.librarySearchHint,
              ),
            ),
          ),
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
                  label: Text(_filterLabel(item, l10n)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => filter = item);
                  },
                  showCheckmark: false,
                  avatar: selected
                      ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: cs.onPrimaryContainer,
                  )
                      : null,
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: firestoreService.getBooks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(l10n.librarySomethingWrong),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final allBooks = snapshot.data!;
                final books = applyFilter(allBooks);

                final favCount = allBooks.where((b) => b.favorite).length;
                final readingCount = allBooks
                    .where((b) => b.status == BookStatus.reading)
                    .length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            l10n.libraryBooksCount(books.length),
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          _SummaryChip(
                            icon: Icons.library_books_rounded,
                            value: allBooks.length,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 6),
                          _SummaryChip(
                            icon: Icons.favorite_rounded,
                            value: favCount,
                            color: Colors.pink,
                          ),
                          const SizedBox(width: 6),
                          _SummaryChip(
                            icon: Icons.auto_stories_rounded,
                            value: readingCount,
                            color: AppColors.readingBlue,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: books.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _emptyIcon(),
                              size: 72,
                              color: cs.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _emptyMessage(l10n),
                              textAlign: TextAlign.center,
                              style: tt.titleMedium?.copyWith(
                                color: cs.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                          : _BookAnimatedList(
                        key: ValueKey('$filter|$sortBy|$searchText'),
                        books: books,
                        itemBuilder: (ctx, book) {
                          return _BookCard(
                            book: book,
                            statusColor: AppColors.forStatus(book.status),
                            onTap: () {
                              Navigator.push(
                                ctx,
                                SlidePageRoute(
                                  page: BookDetailPage(book: book),
                                ),
                              );
                            },
                            onFavorite: () async {
                              final updated = book.copyWith(
                                favorite: !book.favorite,
                              );

                              try {
                                await firestoreService.updateBook(updated);
                              } catch (e) {
                                if (ctx.mounted) {
                                  _showAutoCloseSnackBar(
                                    context: ctx,
                                    snackBar: SnackBar(
                                      content: Text(
                                        AppLocalizations.of(ctx)!
                                            .libraryErrFavorite,
                                      ),
                                      duration: const Duration(days: 1),
                                      backgroundColor:
                                      Theme.of(ctx).colorScheme.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            onDelete: () async {
                              final deletedBook = book;

                              try {
                                await firestoreService.deleteBook(deletedBook.id);
                              } catch (e) {
                                if (ctx.mounted) {
                                  _showAutoCloseSnackBar(
                                    context: ctx,
                                    snackBar: SnackBar(
                                      content: Text(
                                        AppLocalizations.of(ctx)!
                                            .libraryErrDelete,
                                      ),
                                      duration: const Duration(days: 1),
                                      backgroundColor:
                                      Theme.of(ctx).colorScheme.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              if (ctx.mounted) {
                                final l = AppLocalizations.of(ctx)!;
                                final messenger = ScaffoldMessenger.of(ctx);

                                messenger.clearSnackBars();

                                ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;

                                controller = messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l.libraryDeleted(deletedBook.title),
                                    ),
                                    duration: const Duration(days: 1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    action: SnackBarAction(
                                      label: l.libraryUndo,
                                      onPressed: () async {
                                        controller?.close();

                                        try {
                                          await firestoreService.addBook(deletedBook);
                                        } catch (e) {
                                          if (ctx.mounted) {
                                            _showAutoCloseSnackBar(
                                              context: ctx,
                                              snackBar: SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(ctx)!
                                                      .libraryErrRestore,
                                                ),
                                                duration: const Duration(days: 1),
                                                backgroundColor:
                                                Theme.of(ctx)
                                                    .colorScheme
                                                    .error,
                                                behavior:
                                                SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );

                                Future.delayed(const Duration(seconds: 2), () {
                                  controller?.close();
                                });
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

  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.color,
  });

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
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookAnimatedList extends StatefulWidget {
  final List<Book> books;
  final Widget Function(BuildContext, Book) itemBuilder;

  const _BookAnimatedList({
    super.key,
    required this.books,
    required this.itemBuilder,
  });

  @override
  State<_BookAnimatedList> createState() => _BookAnimatedListState();
}

class _BookAnimatedListState extends State<_BookAnimatedList> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<Book> _books;

  @override
  void initState() {
    super.initState();
    _books = List.from(widget.books);
  }

  @override
  void didUpdateWidget(_BookAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncList(widget.books);
  }

  void _syncList(List<Book> newBooks) {
    for (int i = _books.length - 1; i >= 0; i--) {
      if (!newBooks.any((b) => b.id == _books[i].id)) {
        final removed = _books.removeAt(i);

        _listKey.currentState?.removeItem(
          i,
              (ctx, anim) {
            return SizeTransition(
              sizeFactor: anim,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: anim,
                child: widget.itemBuilder(ctx, removed),
              ),
            );
          },
          duration: const Duration(milliseconds: 280),
        );
      }
    }

    for (int i = 0; i < newBooks.length; i++) {
      if (!_books.any((b) => b.id == newBooks[i].id)) {
        _books.insert(i, newBooks[i]);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 350),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      initialItemCount: _books.length,
      itemBuilder: (ctx, index, animation) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: widget.itemBuilder(ctx, _books[index]),
          ),
        );
      },
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

  Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.libraryDeleteConfirmTitle),
          content: Text(l10n.libraryDeleteConfirmMsg(book.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.libraryDeleteConfirmNo),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              child: Text(l10n.libraryDeleteConfirmYes),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: Key(book.id),
      direction: DismissDirection.startToEnd,
      background: Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: cs.error,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.libraryDelete,
                  style: TextStyle(
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      confirmDismiss: (_) async {
        final confirmed = await _confirmDelete(context);

        if (confirmed) {
          onDelete();
        }

        return false;
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
                  child: BookCoverWidget(
                    title: book.title,
                    coverUrl: book.coverUrl,
                    width: 54,
                    height: 78,
                  ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AppColors.localizeStatus(book.status, l10n),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              book.genre,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          book.favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(book.favorite),
                          color: book.favorite ? Colors.pink : cs.outline,
                          size: 22,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (await _confirmDelete(context)) {
                          onDelete();
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: cs.error.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}