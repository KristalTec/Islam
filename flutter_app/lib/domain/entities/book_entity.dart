class BookEntity {
  final String title;
  final String author;
  final String? coverUrl;
  final String? readUrl;
  final String source;
  final String? publishYear;
  final String? description;

  const BookEntity({
    required this.title,
    required this.author,
    this.coverUrl,
    this.readUrl,
    required this.source,
    this.publishYear,
    this.description,
  });

  BookEntity copyWith({
    String? title,
    String? author,
    String? coverUrl,
    String? readUrl,
    String? source,
    String? publishYear,
    String? description,
  }) {
    return BookEntity(
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      readUrl: readUrl ?? this.readUrl,
      source: source ?? this.source,
      publishYear: publishYear ?? this.publishYear,
      description: description ?? this.description,
    );
  }
}
