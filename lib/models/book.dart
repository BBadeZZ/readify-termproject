class Book {
  String id;
  String title;
  String author;
  String genre;
  int totalPages;
  int currentPage;
  String status;
  int rating;
  String note;
  List<String> notes;
  bool favorite;
  String coverUrl;
  DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.totalPages,
    required this.currentPage,
    required this.status,
    required this.rating,
    required this.note,
    List<String>? notes,
    required this.favorite,
    required this.coverUrl,
    required this.createdAt,
  }) : notes = notes ?? [];

  double get progress {
    if (totalPages == 0) return 0;
    return currentPage / totalPages;
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    int? totalPages,
    int? currentPage,
    String? status,
    int? rating,
    String? note,
    List<String>? notes,
    bool? favorite,
    String? coverUrl,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      notes: notes ?? this.notes,
      favorite: favorite ?? this.favorite,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status,
      'rating': rating,
      'note': note,
      'notes': notes,
      'favorite': favorite,
      'coverUrl': coverUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      genre: data['genre'] ?? '',
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['currentPage'] ?? 0,
      status: data['status'] ?? 'Reading',
      rating: data['rating'] ?? 1,
      note: data['note'] ?? '',
      notes: List<String>.from(data['notes'] ?? []),
      favorite: data['favorite'] ?? false,
      coverUrl: data['coverUrl'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}