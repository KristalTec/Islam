import '../entities/book_entity.dart';

abstract class LibraryRepository {
  Future<List<BookEntity>> searchOpenLibrary(String query, int page);

  Future<List<BookEntity>> searchGoogleBooks(String query, int startIndex);

  Future<List<BookEntity>> searchArchive(String query, int page);
}
