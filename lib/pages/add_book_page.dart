import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../services/google_books_service.dart';
import '../widgets/app_drawer.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController currentPageController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController coverUrlController = TextEditingController();

  String selectedGenre = 'Novel';
  String selectedStatus = 'Reading';
  int rating = 3;
  bool favorite = false;
  bool argsLoaded = false;

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
        selectedStatus = args['status'] ?? 'Wishlist';
        if (!['Reading', 'Wishlist', 'Already Read'].contains(selectedStatus)) {
          selectedStatus = 'Wishlist';
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
        if (missingAuthor) 'author',
        if (missingPages) 'page count',
      ].join(' and ');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '"${result.title}" partially filled. Please enter $missing manually.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${result.title}" filled in automatically.'),
          backgroundColor: Colors.green,
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

    // If Serper returned incomplete data, retry with Google Books using exact title
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
    final title = titleController.text.trim();
    final author = authorController.text.trim();
    int totalPages = int.tryParse(totalPagesController.text) ?? 0;
    int currentPage = int.tryParse(currentPageController.text) ?? 0;

    if (title.isEmpty || author.isEmpty || totalPages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid book information.')),
      );
      return;
    }

    currentPage = currentPage.clamp(0, totalPages);

    String finalStatus = selectedStatus;
    if (selectedStatus == 'Wishlist') {
      currentPage = 0;
    } else if (selectedStatus == 'Already Read') {
      currentPage = totalPages;
    } else if (selectedStatus == 'Reading' && currentPage == totalPages) {
      finalStatus = 'Already Read';
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
          const SnackBar(content: Text('Book added successfully.')),
        );
        Navigator.pushReplacementNamed(context, '/library');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save book. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _inputField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 17),
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
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Add Book'),
      appBar: AppBar(title: const Text('Add Book')),
      body: ListView(
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
                          'Search to auto-fill',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Find by title or author — fills form automatically',
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

          _inputField(context, 'Book Title', titleController, Icons.title),
          _inputField(context, 'Author', authorController, Icons.person),
          _inputField(context, 'Cover URL (optional)', coverUrlController, Icons.image),
          _inputField(context, 'Total Pages', totalPagesController, Icons.pages,
              keyboardType: TextInputType.number),
          _inputField(context, 'Current Page', currentPageController, Icons.bookmark,
              keyboardType: TextInputType.number),

          // Genre dropdown
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              value: selectedGenre,
              isExpanded: true,
              underline: const SizedBox(),
              style: TextStyle(fontSize: 17, color: cs.onSurface),
              items: genres
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) => setState(() => selectedGenre = value!),
            ),
          ),

          Text(
            'Reading Status',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: cs.onSurface),
          ),
          RadioGroup<String>(
            groupValue: selectedStatus,
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
                if (selectedStatus == 'Wishlist') {
                  currentPageController.text = '0';
                } else if (selectedStatus == 'Already Read') {
                  currentPageController.text = totalPagesController.text;
                } else if (selectedStatus == 'Reading' &&
                    currentPageController.text == totalPagesController.text) {
                  currentPageController.text = '0';
                }
              });
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('Reading', style: TextStyle(fontSize: 17)),
                  value: 'Reading',
                ),
                RadioListTile<String>(
                  title: Text('Wishlist', style: TextStyle(fontSize: 17)),
                  value: 'Wishlist',
                ),
                RadioListTile<String>(
                  title: Text('Already Read', style: TextStyle(fontSize: 17)),
                  value: 'Already Read',
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Text(
            'Rating: $rating / 5',
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
            title: const Text('Add to favorites',
                style: TextStyle(fontSize: 17)),
            value: favorite,
            onChanged: (value) => setState(() => favorite = value!),
          ),

          _inputField(context, 'Personal Note', noteController, Icons.note, maxLines: 3),

          ElevatedButton.icon(
            onPressed: saveBook,
            icon: const Icon(Icons.save),
            label: const Text('Save Book'),
          ),
        ],
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
                color: Colors.grey.shade300,
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
                  hintText: 'Search by title or author...',
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
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No results found.',
                    style: TextStyle(color: Colors.grey)),
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
                                    const Icon(Icons.book, color: Colors.brown),
                              ),
                            )
                          : const Icon(Icons.book, color: Colors.brown),
                    ),
                    title: Text(
                      r.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${r.author}${r.pageCount > 0 ? ' • ${r.pageCount} pages' : ''}',
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
