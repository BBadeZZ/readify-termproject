import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../services/firestore_service.dart';
import '../services/google_books_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../l10n/app_localizations.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController currentPageController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController coverUrlController = TextEditingController();

  String selectedGenre = 'Novel';
  String selectedStatus = BookStatus.reading;
  int rating = 3;
  bool favorite = false;
  bool argsLoaded = false;
  bool _saving = false;

  final List<String> genres = [
    'Novel',
    'Science',
    'History',
    'Programming',
    'Personal Development',
    'Finance',
    'Dystopian',
    'Productivity',
    'Classic',
    'Romance',
    'Turkish Classic',
    'Turkish Modern Classic',
    'Other',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!argsLoaded) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        titleController.text = args['title'] ?? '';
        authorController.text = args['author'] ?? '';
        totalPagesController.text = args['totalPages'] ?? '';
        currentPageController.text = args['currentPage'] ?? '0';
        noteController.text = args['note'] ?? '';
        coverUrlController.text = args['coverUrl'] ?? '';

        final comingGenre = args['genre'] ?? 'Novel';
        selectedGenre = genres.contains(comingGenre) ? comingGenre : 'Other';
        selectedStatus = args['status'] ?? BookStatus.wishlist;
        if (!BookStatus.all.contains(selectedStatus)) {
          selectedStatus = BookStatus.wishlist;
        }
        rating = (args['rating'] ?? 3).clamp(1, 5);
        favorite = args['favorite'] ?? false;
      }
      argsLoaded = true;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    totalPagesController.dispose();
    currentPageController.dispose();
    noteController.dispose();
    coverUrlController.dispose();
    super.dispose();
  }

  void _autoFill(GoogleBooksResult result) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      titleController.text = result.title;
      if (result.author.isNotEmpty) authorController.text = result.author;
      if (result.pageCount > 0) {
        totalPagesController.text = result.pageCount.toString();
      }
      if (result.coverUrl.isNotEmpty) coverUrlController.text = result.coverUrl;

      final matched = genres.firstWhere(
        (g) => result.genre.toLowerCase().contains(g.toLowerCase()),
        orElse: () => 'Other',
      );
      selectedGenre = matched;
    });

    final missingAuthor = result.author.isEmpty;
    final missingPages = result.pageCount == 0;

    if (missingAuthor || missingPages) {
      final missing = [
        if (missingAuthor) l10n.fieldAuthor,
        if (missingPages) l10n.fieldTotalPages,
      ].join(' / ');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addBookPartialFill(result.title, missing)),
          backgroundColor: AppColors.wishlistAmber,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addBookAutoFill(result.title)),
          backgroundColor: AppColors.completedGreen,
        ),
      );
    }
  }

  Future<void> _showBookSearchSheet() async {
    final result = await showModalBottomSheet<GoogleBooksResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _BookSearchSheet(),
    );
    if (result == null) return;

    if (result.author.isEmpty || result.pageCount == 0) {
      final retry = await GoogleBooksService.search(result.title);
      if (retry.isNotEmpty) {
        final better = retry.first;
        final enriched = GoogleBooksResult(
          title: result.title.isNotEmpty ? result.title : better.title,
          author: result.author.isNotEmpty ? result.author : better.author,
          pageCount: result.pageCount > 0 ? result.pageCount : better.pageCount,
          coverUrl: result.coverUrl.isNotEmpty ? result.coverUrl : better.coverUrl,
          genre: result.genre != 'Other' ? result.genre : better.genre,
        );
        _autoFill(enriched);
        return;
      }
    }

    _autoFill(result);
  }

  void saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final title = titleController.text.trim();
    final author = authorController.text.trim();
    int totalPages = int.tryParse(totalPagesController.text) ?? 0;
    int currentPage = int.tryParse(currentPageController.text) ?? 0;

    setState(() => _saving = true);

    currentPage = currentPage.clamp(0, totalPages);

    String finalStatus = selectedStatus;
    if (selectedStatus == BookStatus.wishlist) {
      currentPage = 0;
    } else if (selectedStatus == BookStatus.alreadyRead) {
      currentPage = totalPages;
    } else if (selectedStatus == BookStatus.reading && currentPage == totalPages) {
      finalStatus = BookStatus.alreadyRead;
    }

    final book = Book(
      id: '',
      title: title,
      author: author,
      genre: selectedGenre,
      totalPages: totalPages,
      currentPage: currentPage,
      status: finalStatus,
      rating: rating,
      note: noteController.text.trim(),
      favorite: favorite,
      coverUrl: coverUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await firestoreService.addBook(book);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.addBookSuccess)),
        );
        Navigator.pushReplacementNamed(context, '/library');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.addBookFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _inputField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 17),
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primary),
          labelText: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Add Book'),
      appBar: AppBar(title: Text(l10n.addBookTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Google Books search card
          GestureDetector(
            onTap: _showBookSearchSheet,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addBookSearchCardTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          l10n.addBookSearchCardSub,
                          style: TextStyle(fontSize: 13, color: cs.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: cs.primary),
                ],
              ),
            ),
          ),

          _inputField(context, l10n.fieldBookTitle, titleController, Icons.title,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validatorTitleRequired : null),
          _inputField(context, l10n.fieldAuthor, authorController, Icons.person,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validatorAuthorRequired : null),
          _inputField(context, l10n.fieldCoverUrlOptional, coverUrlController, Icons.image),
          _inputField(context, l10n.fieldTotalPages, totalPagesController, Icons.pages,
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return l10n.validatorPagesRequired;
                return null;
              }),
          _inputField(context, l10n.fieldCurrentPage, currentPageController, Icons.bookmark,
              keyboardType: TextInputType.number),

          // Genre dropdown
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.fieldGenre,
                prefixIcon: Icon(Icons.category_outlined, color: cs.primary),
              ),
              child: DropdownButton<String>(
                value: selectedGenre,
                isExpanded: true,
                underline: const SizedBox(),
                items: genres
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => selectedGenre = value!),
              ),
            ),
          ),

          Text(
            l10n.fieldReadingStatus,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: cs.onSurface),
          ),
          RadioGroup<String>(
            groupValue: selectedStatus,
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
                if (selectedStatus == BookStatus.wishlist) {
                  currentPageController.text = '0';
                } else if (selectedStatus == BookStatus.alreadyRead) {
                  currentPageController.text = totalPagesController.text;
                } else if (selectedStatus == BookStatus.reading &&
                    currentPageController.text == totalPagesController.text) {
                  currentPageController.text = '0';
                }
              });
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.statusReading, style: const TextStyle(fontSize: 17)),
                  value: BookStatus.reading,
                ),
                RadioListTile<String>(
                  title: Text(l10n.statusWishlist, style: const TextStyle(fontSize: 17)),
                  value: BookStatus.wishlist,
                ),
                RadioListTile<String>(
                  title: Text(l10n.statusAlreadyRead, style: const TextStyle(fontSize: 17)),
                  value: BookStatus.alreadyRead,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Text(
            l10n.fieldRating(rating),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: cs.onSurface),
          ),
          Slider(
            value: rating.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: rating.toString(),
            onChanged: (value) => setState(() => rating = value.toInt()),
          ),

          CheckboxListTile(
            title: Text(l10n.fieldFavorite, style: const TextStyle(fontSize: 17)),
            value: favorite,
            onChanged: (value) => setState(() => favorite = value!),
          ),

          _inputField(context, l10n.fieldNote, noteController, Icons.note, maxLines: 3),

          ElevatedButton.icon(
            onPressed: _saving ? null : saveBook,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: Text(_saving ? l10n.addBookSaving : l10n.addBookSave),
          ),
        ],
      ),
      ),
    );
  }
}

// Bottom sheet widget for searching Google Books
class _BookSearchSheet extends StatefulWidget {
  const _BookSearchSheet();

  @override
  State<_BookSearchSheet> createState() => _BookSearchSheetState();
}

class _BookSearchSheetState extends State<_BookSearchSheet> {
  final _controller = TextEditingController();
  List<GoogleBooksResult> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() => _results = []);
        return;
      }
      setState(() => _loading = true);
      final results = await GoogleBooksService.search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHintSheet,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _results = []);
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            if (!_loading && _results.isEmpty && _controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.searchNoResults,
                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final r = _results[i];
                  return ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 56,
                      child: r.coverUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                r.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
                              ),
                            )
                          : Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      r.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${r.author}${r.pageCount > 0 ? ' • ${l10n.detailPages(r.pageCount)}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.pop(context, r),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
