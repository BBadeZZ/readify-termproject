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
  static const _booksBase = 'https://www.googleapis.com/books/v1/volumes';
  static const _serperKey = '043b515fa7be3dd33ef89b0157e53080c6e6750e';
  static const _serperUrl = 'https://google.serper.dev/search';

  static Future<List<GoogleBooksResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final primary = await _searchGoogleBooks(query);
    if (primary.isNotEmpty) return primary;

    // Fallback: Google Search via Serper
    return _searchSerper(query);
  }

  static Future<List<GoogleBooksResult>> _searchGoogleBooks(
      String query) async {
    final uri = Uri.parse(
        '$_booksBase?q=${Uri.encodeComponent(query)}&maxResults=10&printType=books');
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

  static Future<List<GoogleBooksResult>> _searchSerper(String query) async {
    try {
      final response = await http
          .post(
            Uri.parse(_serperUrl),
            headers: {
              'X-API-KEY': _serperKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'q': '$query book', 'num': 10}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = <GoogleBooksResult>[];

      // Knowledge Graph — tek kitap sonucu (en doğru veri)
      final kg = data['knowledgeGraph'] as Map<String, dynamic>?;
      if (kg != null) {
        final type = (kg['type'] as String? ?? '').toLowerCase();
        if (type.contains('book') || type.contains('novel')) {
          final attrs = kg['attributes'] as Map<String, dynamic>? ?? {};
          final pageStr = attrs['Page count'] as String? ?? '';
          final pageCount =
              int.tryParse(pageStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final genreRaw = attrs['Genres'] as String? ?? '';
          final genre =
              genreRaw.isNotEmpty ? genreRaw.split(',').first.trim() : 'Other';

          results.add(GoogleBooksResult(
            title: kg['title'] ?? '',
            author: attrs['Author'] ?? attrs['Authors'] ?? '',
            pageCount: pageCount,
            coverUrl: kg['imageUrl'] ?? '',
            genre: genre,
          ));
        }
      }

      // Organic sonuçlar — snippet'ten yazar çıkar
      final organic = data['organic'] as List? ?? [];
      for (final item in organic.take(6)) {
        final map = item as Map<String, dynamic>;
        final title = map['title'] as String? ?? '';
        if (title.isEmpty) continue;

        final snippet = map['snippet'] as String? ?? '';
        String author = '';
        final byMatch = RegExp(r'by ([A-Z][^,\.·]+)').firstMatch(snippet);
        if (byMatch != null) author = byMatch.group(1)?.trim() ?? '';

        results.add(GoogleBooksResult(
          title: title,
          author: author,
          pageCount: 0,
          coverUrl: map['imageUrl'] ?? '',
          genre: 'Other',
        ));
      }

      return results.where((r) => r.title.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}
