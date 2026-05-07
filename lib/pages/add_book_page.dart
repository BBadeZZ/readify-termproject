import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';

class AddBookPage extends StatefulWidget {
  AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final FirestoreService service = FirestoreService();

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

        String comingGenre = args['genre'] ?? 'Novel';

        if (genres.contains(comingGenre)) {
          selectedGenre = comingGenre;
        } else {
          selectedGenre = 'Other';
        }

        selectedStatus = args['status'] ?? 'Wishlist';

        if (!['Reading', 'Wishlist', 'Already Read'].contains(selectedStatus)) {
          selectedStatus = 'Wishlist';
        }

        rating = args['rating'] ?? 3;

        if (rating < 1) rating = 1;
        if (rating > 5) rating = 5;

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

  void saveBook() async {
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

    if (currentPage < 0) {
      currentPage = 0;
    }

    if (currentPage > totalPages) {
      currentPage = totalPages;
    }

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

    Book book = Book(
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

    await service.addBook(book);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book added successfully.')),
    );

    Navigator.pushReplacementNamed(context, '/library');
  }

  Widget inputField(
      String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.brown),
          labelText: label,
        ),
      ),
    );
  }

  Widget statusRadio(String title, String value) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
      value: value,
      groupValue: selectedStatus,
      activeColor: Colors.brown,
      onChanged: (newValue) {
        setState(() {
          selectedStatus = newValue!;

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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Add Book'),
      appBar: AppBar(title: const Text('Add Book')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          inputField('Book Title', titleController, Icons.title),
          inputField('Author', authorController, Icons.person),
          inputField(
            'Cover URL (optional)',
            coverUrlController,
            Icons.image,
          ),
          inputField(
            'Total Pages',
            totalPagesController,
            Icons.pages,
            keyboardType: TextInputType.number,
          ),
          inputField(
            'Current Page',
            currentPageController,
            Icons.bookmark,
            keyboardType: TextInputType.number,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown.shade200),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              value: selectedGenre,
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 17, color: Colors.brown),
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
          const Text(
            'Reading Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.brown,
            ),
          ),
          statusRadio('Reading', 'Reading'),
          statusRadio('Wishlist', 'Wishlist'),
          statusRadio('Already Read', 'Already Read'),
          const SizedBox(height: 10),
          Text(
            'Rating: $rating / 5',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.brown,
            ),
          ),
          Slider(
            activeColor: Colors.amber,
            inactiveColor: Colors.amberAccent,
            value: rating.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: rating.toString(),
            onChanged: (value) {
              setState(() {
                rating = value.toInt();
              });
            },
          ),
          CheckboxListTile(
            title: const Text(
              'Add to favorites',
              style: TextStyle(fontSize: 17),
            ),
            activeColor: Colors.pinkAccent,
            value: favorite,
            onChanged: (value) {
              setState(() {
                favorite = value!;
              });
            },
          ),
          inputField(
            'Personal Note',
            noteController,
            Icons.note,
            maxLines: 3,
          ),
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