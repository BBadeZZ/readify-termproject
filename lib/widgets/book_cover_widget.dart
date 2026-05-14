import 'package:flutter/material.dart';

class BookCoverWidget extends StatelessWidget {
  final String title;
  final String? coverUrl;
  final double width;
  final double height;

  const BookCoverWidget({
    super.key,
    required this.title,
    required this.coverUrl,
    this.width = 90,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    if (coverUrl != null && coverUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          coverUrl!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          cacheWidth: (width * 2).toInt(),
          cacheHeight: (height * 2).toInt(),
          errorBuilder: (context, error, stackTrace) => _placeholderCover(context),
        ),
      );
    }
    return _placeholderCover(context);
  }

  Widget _placeholderCover(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final smallCover = width <= 60;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(smallCover ? 4 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: smallCover
          ? Center(child: Icon(Icons.menu_book, color: cs.primary, size: width * 0.55))
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, color: cs.primary, size: 34),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: width - 20,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
