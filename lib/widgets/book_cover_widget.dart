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
          errorBuilder: (context, error, stackTrace) {
            return _placeholderCover();
          },
        ),
      );
    }

    return _placeholderCover();
  }

  Widget _placeholderCover() {
    bool smallCover = width <= 60;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(smallCover ? 4 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE7A9),
            Color(0xFFFFC8DD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: smallCover
          ? const Center(
        child: Icon(
          Icons.menu_book,
          color: Colors.brown,
          size: 30,
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.menu_book,
            color: Colors.brown,
            size: 34,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}