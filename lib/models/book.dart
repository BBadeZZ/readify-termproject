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
    required this.favorite,
    required this.coverUrl,
    required this.createdAt,
  });

  double get progress {
    if (totalPages == 0) return 0;
    return currentPage / totalPages;
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
      favorite: data['favorite'] ?? false,
      coverUrl: data['coverUrl'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}