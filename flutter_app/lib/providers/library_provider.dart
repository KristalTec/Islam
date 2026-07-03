import 'package:flutter/foundation.dart';

import '../data/models/book_model.dart';
import '../data/services/library_service.dart';

enum LibrarySource { all, openlibrary, google, archive }

class LibraryProvider extends ChangeNotifier {
  final List<BookModel> _books = [];
  bool _isLoading = false;
  bool _isKurdishOnly = false;
  LibrarySource _source = LibrarySource.all;
  String _lastQuery = 'تەفسیری قورئان';
  String _resultsInfo = '';

  // Pagination state
  int _openLibPage = 1;
  int _googleStart = 0;
  int _archivePage = 1;
  bool _openLibDone = false;
  bool _googleDone = false;
  bool _archiveDone = false;

  // Search history
  final List<Map<String, String>> _searchHistory = [];

  List<BookModel> get books => List.unmodifiable(_books);
  bool get isLoading => _isLoading;
  bool get isKurdishOnly => _isKurdishOnly;
  LibrarySource get source => _source;
  String get resultsInfo => _resultsInfo;
  List<Map<String, String>> get searchHistory =>
      List.unmodifiable(_searchHistory);

  LibraryProvider() {
    initiateSearch();
  }

  void setSource(LibrarySource src) {
    _source = src;
    initiateSearch(keepQuery: true);
  }

  void toggleKurdishOnly() {
    _isKurdishOnly = !_isKurdishOnly;
    initiateSearch(keepQuery: true);
  }

  void initiateSearch({String? query, bool keepQuery = false}) {
    if (query != null && query.trim().isNotEmpty) {
      _lastQuery = query.trim();
      _addToHistory(query.trim());
    } else if (!keepQuery) {
      _lastQuery = _isKurdishOnly ? 'تەفسیری قورئان کوردی' : 'تفسير القرآن';
    }

    _resetPagination();
    _books.clear();
    _resultsInfo = '';
    notifyListeners();
    loadBooks();
  }

  void _resetPagination() {
    _openLibPage = 1;
    _googleStart = 0;
    _archivePage = 1;
    _openLibDone = false;
    _googleDone = false;
    _archiveDone = false;
  }

  Future<void> loadBooks() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final effectiveQuery =
        _isKurdishOnly ? '$_lastQuery Kurdish' : _lastQuery;

    try {
      switch (_source) {
        case LibrarySource.all:
          await Future.wait([
            _loadOpenLibrary(effectiveQuery),
            _loadGoogle(effectiveQuery),
            _loadArchive(effectiveQuery),
          ]);
          break;
        case LibrarySource.openlibrary:
          await _loadOpenLibrary(effectiveQuery);
          break;
        case LibrarySource.google:
          await _loadGoogle(effectiveQuery);
          break;
        case LibrarySource.archive:
          await _loadArchive(effectiveQuery);
          break;
      }
    } catch (_) {}

    _isLoading = false;
    if (_books.isEmpty) {
      _resultsInfo = 'هیچ کتێبێک نەدۆزرایەوە! هەوڵبدە وشەی گەڕانەکەت بگۆڕیت.';
    } else {
      _resultsInfo = '${_books.length} کتێب دۆزرایەوە';
    }
    notifyListeners();
  }

  Future<void> _loadOpenLibrary(String query) async {
    if (_openLibDone) return;
    final results = await LibraryService.instance
        .searchOpenLibrary(query, _openLibPage);
    if (results.isEmpty) {
      _openLibDone = true;
    } else {
      _books.addAll(results);
      _openLibPage++;
    }
  }

  Future<void> _loadGoogle(String query) async {
    if (_googleDone) return;
    final results = await LibraryService.instance
        .searchGoogleBooks(query, _googleStart);
    if (results.isEmpty) {
      _googleDone = true;
    } else {
      _books.addAll(results);
      _googleStart += 10;
    }
  }

  Future<void> _loadArchive(String query) async {
    if (_archiveDone) return;
    final results = await LibraryService.instance
        .searchArchive(query, _archivePage);
    if (results.isEmpty) {
      _archiveDone = true;
    } else {
      _books.addAll(results);
      _archivePage++;
    }
  }

  void _addToHistory(String query) {
    _searchHistory.removeWhere((h) => h['query'] == query);
    _searchHistory.insert(0, {
      'query': query,
      'time': DateTime.now().toLocal().toIso8601String(),
    });
    if (_searchHistory.length > 20) _searchHistory.removeLast();
  }

  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  void searchFromHistory(String query) {
    initiateSearch(query: query);
  }
}
