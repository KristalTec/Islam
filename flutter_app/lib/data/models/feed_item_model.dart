enum FeedItemType { hadith, dua, name, info, ayah }

class FeedItemModel {
  final FeedItemType type;
  /// For simple text content types (hadith, dua, info): plain string.
  /// For 'name': Map<String,String> with keys 'name' and 'meaning'.
  /// For 'ayah': Map<String,String> with keys 'text' and 'source'.
  final dynamic content;
  final bool isNew;
  final DateTime createdAt;

  const FeedItemModel({
    required this.type,
    required this.content,
    this.isNew = false,
    required this.createdAt,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'info';
    return FeedItemModel(
      type: FeedItemType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => FeedItemType.info,
      ),
      content: json['content'],
      isNew: json['isNew'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'content': content,
        'isNew': isNew,
        'createdAt': createdAt.toIso8601String(),
      };

  String get tagLabel {
    switch (type) {
      case FeedItemType.hadith:
        return 'فەرموودە';
      case FeedItemType.dua:
        return 'دوعای ڕۆژ';
      case FeedItemType.name:
        return 'ناوی خوای گەورە';
      case FeedItemType.info:
        return 'زانیاری';
      case FeedItemType.ayah:
        return 'ئایەتی ڕۆژ';
    }
  }

  String get sourceLabel {
    switch (type) {
      case FeedItemType.hadith:
        return 'پێغەمبەر (د.خ) دەفەرموێت';
      case FeedItemType.dua:
        return 'دوعا و پاڕانەوە';
      case FeedItemType.name:
        return 'ئەسمائی حوسنا';
      case FeedItemType.info:
        return 'رۆشنبیری ئیسلامی';
      case FeedItemType.ayah:
        if (content is Map) {
          return (content as Map)['source'] as String? ?? 'قورئانی پیرۆز';
        }
        return 'قورئانی پیرۆز';
    }
  }

  String get displayContent {
    if (content == null) return '';
    switch (type) {
      case FeedItemType.name:
        if (content is Map) {
          final m = content as Map;
          return '${m['name']}: ${m['meaning']}';
        }
        return content.toString();
      case FeedItemType.ayah:
        if (content is Map) {
          final m = content as Map;
          return '"${m['text'] ?? ''}"';
        }
        return content.toString();
      default:
        return content.toString();
    }
  }
}
