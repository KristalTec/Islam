import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/feed_item_model.dart';

class FeedCardWidget extends StatelessWidget {
  final FeedItemModel item;

  const FeedCardWidget({super.key, required this.item});

  Color get _tagColor {
    switch (item.type) {
      case FeedItemType.hadith:
        return AppColors.tagHadith;
      case FeedItemType.dua:
        return AppColors.tagDua;
      case FeedItemType.name:
        return AppColors.tagName;
      case FeedItemType.info:
        return AppColors.tagInfo;
      case FeedItemType.ayah:
        return AppColors.tagAyah;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _tagColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.tagLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.isNew) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text(
                      'تازە',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 15),
            // Content
            Text(
              item.displayContent,
              style: const TextStyle(
                fontSize: 17,
                height: 1.8,
                color: Color(0xFF444444),
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            // Source divider
            const Divider(
              color: Color(0xFFEEEEEE),
              height: 1,
            ),
            const SizedBox(height: 5),
            Text(
              item.sourceLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
