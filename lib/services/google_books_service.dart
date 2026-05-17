import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBooksResult {
  final String title;
  final String author;
  final int pageCount;
  final String coverUrl;
  final String genre;
  final String openLibraryWorkKey;

  GoogleBooksResult({
    required this.title,
    required this.author,
    required this.pageCount,
    required this.coverUrl,
    required this.genre,
    this.openLibraryWorkKey = '',
  });

  factory GoogleBooksResult.fromGoogleBooks(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];

    if (volumeInfo is! Map<String, dynamic>) {
      return GoogleBooksResult(
        title: '',
        author: '',
        pageCount: 0,
        coverUrl: '',
        genre: 'Other',
      );
    }

    final title = volumeInfo['title']?.toString() ?? '';

    final authorList = volumeInfo['authors'];
    final authors = authorList is List
        ? authorList.map((e) => e.toString()).toList()
        : <String>[];

    final author = authors.join(', ');

    final pageRaw = volumeInfo['pageCount'];
    final pageCount = int.tryParse(pageRaw?.toString() ?? '') ?? 0;

    String coverUrl = '';
    final imageLinks = volumeInfo['imageLinks'];

    if (imageLinks is Map<String, dynamic>) {
      coverUrl = imageLinks['thumbnail']?.toString() ??
          imageLinks['smallThumbnail']?.toString() ??
          '';

      coverUrl = coverUrl.replaceFirst('http://', 'https://');
    }

    final categoryList = volumeInfo['categories'];
    final categories = categoryList is List
        ? categoryList.map((e) => e.toString()).toList()
        : <String>[];

    return GoogleBooksResult(
      title: title,
      author: author,
      pageCount: pageCount,
      coverUrl: coverUrl,
      genre: categories.isNotEmpty ? categories.first : 'Other',
    );
  }

  factory GoogleBooksResult.fromOpenLibrary(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? '';

    final authorList = json['author_name'];
    final authors = authorList is List
        ? authorList.map((e) => e.toString()).toList()
        : <String>[];

    final author = authors.join(', ');

    final pageRaw = json['number_of_pages_median'] ??
        json['number_of_pages'] ??
        json['page_count'] ??
        json['pages'];

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

    final key = json['key']?.toString() ?? '';

    return GoogleBooksResult(
      title: title,
      author: author,
      pageCount: pageCount,
      coverUrl: coverUrl,
      genre: subjects.isNotEmpty ? subjects.first : 'Other',
      openLibraryWorkKey: key,
    );
  }

  GoogleBooksResult copyWith({
    String? title,
    String? author,
    int? pageCount,
    String? coverUrl,
    String? genre,
    String? openLibraryWorkKey,
  }) {
    return GoogleBooksResult(
      title: title ?? this.title,
      author: author ?? this.author,
      pageCount: pageCount ?? this.pageCount,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
      openLibraryWorkKey: openLibraryWorkKey ?? this.openLibraryWorkKey,
    );
  }
}

class GoogleBooksService {
  static Future<List<GoogleBooksResult>> search(String query) async {
    final searchText = query.trim();

    if (searchText.isEmpty) return [];

    final googleResults = await _searchGoogleBooks(searchText);
    final openLibraryResults = await _searchOpenLibrary(searchText);

    final enrichedOpenLibraryResults = <GoogleBooksResult>[];

    for (final book in openLibraryResults) {
      if (book.pageCount > 0) {
        enrichedOpenLibraryResults.add(book);
      } else {
        final pages = await _getPagesFromOpenLibraryEditions(
          book.openLibraryWorkKey,
        );

        enrichedOpenLibraryResults.add(
          book.copyWith(pageCount: pages),
        );
      }
    }

    if (googleResults.isEmpty && enrichedOpenLibraryResults.isEmpty) {
      return [];
    }

    if (googleResults.isEmpty) {
      return enrichedOpenLibraryResults;
    }

    return googleResults.map((googleBook) {
      final matchedOpenBook = _findMatchingBook(
        googleBook,
        enrichedOpenLibraryResults,
      );

      final openPageCount = matchedOpenBook?.pageCount ?? 0;

      final finalPageCount = googleBook.pageCount > 0
          ? googleBook.pageCount
          : openPageCount > 0
          ? openPageCount
          : 0;

      return GoogleBooksResult(
        title: googleBook.title,
        author: googleBook.author.isNotEmpty
            ? googleBook.author
            : matchedOpenBook?.author ?? '',
        pageCount: finalPageCount,
        coverUrl: googleBook.coverUrl.isNotEmpty
            ? googleBook.coverUrl
            : matchedOpenBook?.coverUrl ?? '',
        genre: googleBook.genre != 'Other'
            ? googleBook.genre
            : matchedOpenBook?.genre ?? 'Other',
        openLibraryWorkKey: matchedOpenBook?.openLibraryWorkKey ?? '',
      );
    }).toList();
  }

  static GoogleBooksResult? _findMatchingBook(
      GoogleBooksResult googleBook,
      List<GoogleBooksResult> openLibraryResults,
      ) {
    final googleTitle = _normalize(googleBook.title);
    final googleAuthor = _normalize(googleBook.author);

    for (final openBook in openLibraryResults) {
      final openTitle = _normalize(openBook.title);
      final openAuthor = _normalize(openBook.author);

      if (googleTitle.isNotEmpty && googleTitle == openTitle) {
        return openBook;
      }

      if (googleTitle.isNotEmpty &&
          openTitle.isNotEmpty &&
          (googleTitle.contains(openTitle) || openTitle.contains(googleTitle))) {
        return openBook;
      }

      if (googleAuthor.isNotEmpty &&
          openAuthor.isNotEmpty &&
          (googleAuthor.contains(openAuthor) ||
              openAuthor.contains(googleAuthor))) {
        return openBook;
      }
    }

    return null;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9ğüşöçıİĞÜŞÖÇ ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static Future<List<GoogleBooksResult>> _searchGoogleBooks(String query) async {
    final uri = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes',
      {
        'q': query,
        'maxResults': '20',
        'printType': 'books',
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

      final items = decoded['items'];

      if (items is! List) {
        return [];
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => GoogleBooksResult.fromGoogleBooks(item))
          .where((book) => book.title.trim().isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<GoogleBooksResult>> _searchOpenLibrary(String query) async {
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

  static Future<int> _getPagesFromOpenLibraryEditions(String workKey) async {
    if (workKey.trim().isEmpty) return 0;

    final cleanKey = workKey.replaceFirst('/works/', '');

    final uri = Uri.https(
      'openlibrary.org',
      '/works/$cleanKey/editions.json',
      {
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
        return 0;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return 0;
      }

      final entries = decoded['entries'];

      if (entries is! List) {
        return 0;
      }

      final pageCounts = <int>[];

      for (final item in entries) {
        if (item is Map<String, dynamic>) {
          final rawPages = item['number_of_pages'];
          final pages = int.tryParse(rawPages?.toString() ?? '') ?? 0;

          if (pages > 0 && pages < 3000) {
            pageCounts.add(pages);
          }
        }
      }

      if (pageCounts.isEmpty) {
        return 0;
      }

      pageCounts.sort();

      return pageCounts[pageCounts.length ~/ 2];
    } catch (e) {
      return 0;
    }
  }
}