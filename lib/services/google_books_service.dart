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

  factory GoogleBooksResult.fromOpenLibrary(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? '';

    final authorList = json['author_name'];
    final authors = authorList is List
        ? authorList.map((e) => e.toString()).toList()
        : <String>[];

    final pageRaw = json['number_of_pages_median'];
    final pageCount = int.tryParse(pageRaw?.toString() ?? '') ?? 0;

    String coverUrl = '';
    final coverId = json['cover_i'];
    if (coverId != null) {
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }

    final subjectList = json['subject'];
    final subjects = subjectList is List
        ? subjectList.map((e) => e.toString()).toList()
        : <String>[];

    return GoogleBooksResult(
      title: title,
      author: authors.join(', '),
      pageCount: pageCount,
      coverUrl: coverUrl,
      genre: subjects.isNotEmpty ? subjects.first : 'Other',
    );
  }
}

class GoogleBooksService {
  static Future<List<GoogleBooksResult>> search(String query) async {
    final searchText = query.trim();

    if (searchText.isEmpty) return [];

    return _searchOpenLibrary(searchText);
  }

  static Future<List<GoogleBooksResult>> _searchOpenLibrary(
      String query,
      ) async {
    final uri = Uri.https(
      'openlibrary.org',
      '/search.json',
      {
        'q': query,
        'limit': '20',
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      final docs = decoded['docs'];

      if (docs is! List) {
        return [];
      }

      return docs
          .whereType<Map<String, dynamic>>()
          .map((item) => GoogleBooksResult.fromOpenLibrary(item))
          .where((book) => book.title.trim().isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }
}