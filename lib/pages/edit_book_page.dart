import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../services/firestore_service.dart';
import '../l10n/app_localizations.dart';

class EditBookPage extends StatefulWidget {
  final Book book;

  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {

  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController totalPagesController;
  late TextEditingController currentPageController;
  late TextEditingController noteController;
  late TextEditingController coverUrlController;

  late String selectedGenre;
  late String selectedStatus;
  late int rating;
  late bool favorite;
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
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.book.title);
    authorController = TextEditingController(text: widget.book.author);
    totalPagesController =
        TextEditingController(text: widget.book.totalPages.toString());
    currentPageController =
        TextEditingController(text: widget.book.currentPage.toString());
    noteController = TextEditingController(text: widget.book.note);
    coverUrlController = TextEditingController(text: widget.book.coverUrl);

    selectedGenre = genres.contains(widget.book.genre) ? widget.book.genre : 'Other';

    if (BookStatus.all.contains(widget.book.status)) {
      selectedStatus = widget.book.status;
    } else {
      selectedStatus = BookStatus.alreadyRead;
    }

    rating = widget.book.rating;
    favorite = widget.book.favorite;
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

  bool get _isDirty =>
      titleController.text.trim() != widget.book.title ||
      authorController.text.trim() != widget.book.author ||
      totalPagesController.text.trim() != widget.book.totalPages.toString() ||
      currentPageController.text.trim() != widget.book.currentPage.toString() ||
      noteController.text.trim() != widget.book.note ||
      coverUrlController.text.trim() != widget.book.coverUrl ||
      selectedGenre !=
          (genres.contains(widget.book.genre) ? widget.book.genre : 'Other') ||
      selectedStatus !=
          (BookStatus.all.contains(widget.book.status)
              ? widget.book.status
              : BookStatus.alreadyRead) ||
      rating != widget.book.rating ||
      favorite != widget.book.favorite;

  Future<bool> _showDiscardDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.discardChangesTitle),
            content: Text(l10n.discardChangesMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.discardChangesStay),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.discardChangesLeave,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void updateBook() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    String title = titleController.text.trim();
    String author = authorController.text.trim();
    int totalPages = int.tryParse(totalPagesController.text) ?? 0;
    int currentPage = int.tryParse(currentPageController.text) ?? 0;

    setState(() => _saving = true);

    if (currentPage < 0) currentPage = 0;
    if (currentPage > totalPages) currentPage = totalPages;

    String finalStatus = selectedStatus;

    if (selectedStatus == BookStatus.wishlist) {
      currentPage = 0;
      finalStatus = BookStatus.wishlist;
    } else if (selectedStatus == BookStatus.alreadyRead) {
      currentPage = totalPages;
      finalStatus = BookStatus.alreadyRead;
    } else if (selectedStatus == BookStatus.reading) {
      finalStatus = BookStatus.reading;
      if (currentPage == totalPages) {
        finalStatus = BookStatus.alreadyRead;
      }
    }

    Book updatedBook = Book(
      id: widget.book.id,
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
      createdAt: widget.book.createdAt,
    );

    try {
      await firestoreService.updateBook(updatedBook);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.editBookSuccess)),
        );
        Navigator.pop(context, updatedBook);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.editBookFailed),
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

  Widget inputField(
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

  void _onStatusChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      selectedStatus = newValue;
      if (selectedStatus == BookStatus.wishlist) {
        currentPageController.text = '0';
      } else if (selectedStatus == BookStatus.alreadyRead) {
        currentPageController.text = totalPagesController.text;
      } else if (selectedStatus == BookStatus.reading) {
        if (currentPageController.text == totalPagesController.text) {
          currentPageController.text = '0';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_isDirty) return;
        final leave = await _showDiscardDialog();
        if (leave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n.editBookTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          inputField(context, l10n.fieldBookTitle, titleController, Icons.title,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validatorTitleRequired : null),
          inputField(context, l10n.fieldAuthor, authorController, Icons.person,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validatorAuthorRequired : null),
          inputField(context, l10n.fieldCoverUrl, coverUrlController, Icons.image),
          inputField(
            context,
            l10n.fieldTotalPages,
            totalPagesController,
            Icons.pages,
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n <= 0) return l10n.validatorPagesRequired;
              return null;
            },
          ),
          inputField(
            context,
            l10n.fieldCurrentPage,
            currentPageController,
            Icons.bookmark,
            keyboardType: TextInputType.number,
          ),
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
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: cs.onSurface,
            ),
          ),
          RadioGroup<String>(
            groupValue: selectedStatus,
            onChanged: _onStatusChanged,
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
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: cs.onSurface,
            ),
          ),
          Slider(
            value: rating.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) {
              setState(() {
                rating = value.toInt();
              });
            },
          ),
          CheckboxListTile(
            title: Text(l10n.fieldFavoriteShort),
            value: favorite,
            onChanged: (value) {
              setState(() {
                favorite = value!;
              });
            },
          ),
          inputField(
            context,
            l10n.fieldNote,
            noteController,
            Icons.note,
            maxLines: 3,
          ),
          ElevatedButton.icon(
            onPressed: _saving ? null : updateBook,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.edit),
            label: Text(_saving ? l10n.editBookSaving : l10n.editBookUpdate),
          ),
        ],
      ),
      ),
    ),
    );
  }
}
