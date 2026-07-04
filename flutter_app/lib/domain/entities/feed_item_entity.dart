enum FeedContentType { hadith, dua, name, info, ayah }

class FeedItemEntity {
  final FeedContentType type;
  final Object? content;
  final bool isNew;
  final DateTime createdAt;

  const FeedItemEntity({
    required this.type,
    required this.content,
    required this.createdAt,
    this.isNew = false,
  });

  FeedItemEntity copyWith({
    FeedContentType? type,
    Object? content,
    bool? isNew,
    DateTime? createdAt,
  }) {
    return FeedItemEntity(
      type: type ?? this.type,
      content: content ?? this.content,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
