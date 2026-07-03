class BookModel {
  final String title;
  final String author;
  final String? coverUrl;
  final String? readUrl;
  final String source; // 'openlibrary', 'google', 'archive'
  final String? publishYear;
  final String? description;

  const BookModel({
    required this.title,
    required this.author,
    this.coverUrl,
    this.readUrl,
    required this.source,
    this.publishYear,
    this.description,
  });

  factory BookModel.fromOpenLibrary(Map<String, dynamic> json) {
    final coverId = json['cover_i'];
    final authors = (json['author_name'] as List?)?.join(', ') ?? '';
    return BookModel(
      title: json['title'] as String? ?? '',
      author: authors,
      coverUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : null,
      readUrl: json['key'] != null
          ? 'https://openlibrary.org${json['key']}'
          : null,
      source: 'openlibrary',
      publishYear: json['first_publish_year']?.toString(),
    );
  }

  factory BookModel.fromGoogle(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final authors = (volumeInfo['authors'] as List?)?.join(', ') ?? '';
    final thumbnail =
        (volumeInfo['imageLinks'] as Map<String, dynamic>?)?['thumbnail']
            as String?;
    final accessInfo = json['accessInfo'] as Map<String, dynamic>? ?? {};
    final webReaderLink =
        (accessInfo['webReaderLink']) as String?;
    return BookModel(
      title: volumeInfo['title'] as String? ?? '',
      author: authors,
      coverUrl: thumbnail,
      readUrl: webReaderLink,
      source: 'google',
      publishYear: (() {
        final publishedDate = volumeInfo['publishedDate'] as String?;
        if (publishedDate == null || publishedDate.isEmpty) return null;
        final end = publishedDate.length < 4 ? publishedDate.length : 4;
        return publishedDate.substring(0, end);
      })(),
    );
  }

  factory BookModel.fromArchive(Map<String, dynamic> json) {
    final id = json['identifier'] as String? ?? '';
    return BookModel(
      title: json['title'] as String? ?? '',
      author: json['creator'] as String? ?? '',
      coverUrl: id.isNotEmpty
          ? 'https://archive.org/services/img/$id'
          : null,
      readUrl: id.isNotEmpty ? 'https://archive.org/details/$id' : null,
      source: 'archive',
      description: json['description'] as String?,
    );
  }

  String get sourceTag {
    switch (source) {
      case 'openlibrary':
        return 'Open Library';
      case 'google':
        return 'Google Books';
      case 'archive':
        return 'Archive.org';
      default:
        return source;
    }
  }
}
