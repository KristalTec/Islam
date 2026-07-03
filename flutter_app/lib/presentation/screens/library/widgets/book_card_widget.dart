import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/book_model.dart';

class BookCardWidget extends StatelessWidget {
  final BookModel book;
  final VoidCallback onRead;

  const BookCardWidget({
    super.key,
    required this.book,
    required this.onRead,
  });

  Color get _sourceTagColor {
    switch (book.source) {
      case 'openlibrary':
        return const Color(0xFF2E7D32);
      case 'google':
        return const Color(0xFF1565C0);
      case 'archive':
        return const Color(0xFFE65100);
      default:
        return Colors.grey;
    }
  }

  Color get _sourceTagBg {
    switch (book.source) {
      case 'openlibrary':
        return const Color(0xFFE8F5E9);
      case 'google':
        return const Color(0xFFE3F2FD);
      case 'archive':
        return const Color(0xFFFFF3E0);
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10)),
            child: book.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: book.coverUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.book,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text('📖',
                            style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text('📖',
                          style: TextStyle(fontSize: 40)),
                    ),
                  ),
          ),

          // Book info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Source tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _sourceTagBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      book.sourceTag,
                      style: TextStyle(
                        fontSize: 11,
                        color: _sourceTagColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 5),

                  // Author
                  Text(
                    book.author.isNotEmpty ? book.author : 'نووسەر نادیارە',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Read button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: onRead,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          AppStrings.libraryRead,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
