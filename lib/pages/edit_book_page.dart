import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';

class EditBookPage extends StatefulWidget {
  final Book book;

  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {

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

    if (['Reading', 'Wishlist', 'Already Read'].contains(widget.book.status)) {
      selectedStatus = widget.book.status;
    } else {
      selectedStatus = 'Already Read';
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

  void updateBook() async {
    String title = titleController.text.trim();
    String author = authorController.text.trim();

    int totalPages = int.tryParse(totalPagesController.text) ?? 0;
    int currentPage = int.tryParse(currentPageController.text) ?? 0;

    if (title.isEmpty || author.isEmpty || totalPages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid book information.')),
      );
      return;
    }

    if (currentPage < 0) currentPage = 0;
    if (currentPage > totalPages) currentPage = totalPages;

    String finalStatus = selectedStatus;

    if (selectedStatus == 'Wishlist') {
      currentPage = 0;
      finalStatus = 'Wishlist';
    } else if (selectedStatus == 'Already Read') {
      currentPage = totalPages;
      finalStatus = 'Already Read';
    } else if (selectedStatus == 'Reading') {
      finalStatus = 'Reading';

      if (currentPage == totalPages) {
        finalStatus = 'Already Read';
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
          const SnackBar(content: Text('Book updated successfully.')),
        );
        Navigator.pop(context, updatedBook);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update book. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget inputField(
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

  Widget statusRadio(String title, String value) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 17)),
      value: value,
    );
  }

  void _onStatusChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      selectedStatus = newValue;
      if (selectedStatus == 'Wishlist') {
        currentPageController.text = '0';
      } else if (selectedStatus == 'Already Read') {
        currentPageController.text = totalPagesController.text;
      } else if (selectedStatus == 'Reading') {
        if (currentPageController.text == totalPagesController.text) {
          currentPageController.text = '0';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          inputField(context, 'Book Title', titleController, Icons.title),
          inputField(context, 'Author', authorController, Icons.person),
          inputField(context, 'Cover URL', coverUrlController, Icons.image),
          inputField(
            context,
            'Total Pages',
            totalPagesController,
            Icons.pages,
            keyboardType: TextInputType.number,
          ),
          inputField(
            context,
            'Current Page',
            currentPageController,
            Icons.bookmark,
            keyboardType: TextInputType.number,
          ),
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
              items: genres.map((genre) {
                return DropdownMenuItem<String>(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGenre = value!;
                });
              },
            ),
          ),
          Text(
            'Reading Status',
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
                statusRadio('Reading', 'Reading'),
                statusRadio('Wishlist', 'Wishlist'),
                statusRadio('Already Read', 'Already Read'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Rating: $rating / 5',
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
            title: const Text('Favorite'),
            value: favorite,
            onChanged: (value) {
              setState(() {
                favorite = value!;
              });
            },
          ),
          inputField(
            context,
            'Personal Note',
            noteController,
            Icons.note,
            maxLines: 3,
          ),
          ElevatedButton.icon(
            onPressed: updateBook,
            icon: const Icon(Icons.edit),
            label: const Text('Update Book'),
          ),
        ],
      ),
    );
  }
}