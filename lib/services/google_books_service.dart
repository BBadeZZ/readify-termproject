import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBooksResult {
  final String title;
  final String author;
  final int pageCount;
  final String coverUrl;
  final String genre;

  GoogleBooksResult({
    required this.title,
    required this.author,
    required this.pageCount,
    required this.coverUrl,
    required this.genre,
  });

  factory GoogleBooksResult.fromJson(Map<String, dynamic> json) {
    final info = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final authors = (info['authors'] as List?)?.cast<String>() ?? [];
    final imageLinks = info['imageLinks'] as Map<String, dynamic>? ?? {};
    final categories = (info['categories'] as List?)?.cast<String>() ?? [];

    String cover = imageLinks['thumbnail'] ?? '';
    // Google Books API returns http, Flutter requires https
    cover = cover.replaceFirst('http://', 'https://');

    return GoogleBooksResult(
      title: info['title'] ?? '',
      author: authors.join(', '),
      pageCount: info['pageCount'] ?? 0,
      coverUrl: cover,
      genre: categories.isNotEmpty ? categories.first : 'Other',
    );
  }
}

class GoogleBooksService {
  static const _base = 'https://www.googleapis.com/books/v1/volumes';

  static Future<List<GoogleBooksResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
        '$_base?q=${Uri.encodeComponent(query)}&maxResults=10&printType=books');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List? ?? [];

      return items
          .map((item) =>
              GoogleBooksResult.fromJson(item as Map<String, dynamic>))
          .where((r) => r.title.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
