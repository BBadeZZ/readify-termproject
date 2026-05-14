import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/book.dart';

class ExportService {
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String _buildCsv(List<Book> books) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Title,Author,Genre,Status,Rating,Current Page,Total Pages,Progress %,Favorite,Date Added');
    for (final b in books) {
      final progress =
          b.totalPages > 0 ? (b.progress * 100).toStringAsFixed(1) : '0';
      buffer.writeln([
        _escapeCsv(b.title),
        _escapeCsv(b.author),
        _escapeCsv(b.genre),
        _escapeCsv(b.status),
        b.rating.toString(),
        b.currentPage.toString(),
        b.totalPages.toString(),
        progress,
        b.favorite ? 'Yes' : 'No',
        _escapeCsv(b.createdAt.toIso8601String().substring(0, 10)),
      ].join(','));
    }
    return buffer.toString();
  }

  Future<void> exportBooks(List<Book> books) async {
    if (kIsWeb) throw UnsupportedError('Export not supported on web.');
    final csv = _buildCsv(books);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/readify_library.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Readify Library Export',
    );
  }
}

final exportService = ExportService();
