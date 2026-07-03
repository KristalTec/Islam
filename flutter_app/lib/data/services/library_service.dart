import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/book_model.dart';
import '../../core/constants/api_constants.dart';

class LibraryService {
  LibraryService._();
  static const LibraryService instance = LibraryService._();

  Future<List<BookModel>> searchOpenLibrary(
      String query, int page) async {
    final url = ApiConstants.openLibrarySearch
        .replaceFirst('{query}', Uri.encodeComponent(query))
        .replaceFirst('{page}', '$page');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = json['docs'] as List<dynamic>? ?? [];
        return docs
            .map((e) => BookModel.fromOpenLibrary(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<BookModel>> searchGoogleBooks(
      String query, int startIndex) async {
    final url = ApiConstants.googleBooksSearch
        .replaceFirst('{query}', Uri.encodeComponent(query))
        .replaceFirst('{start}', '$startIndex');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final items = json['items'] as List<dynamic>? ?? [];
        return items
            .map((e) => BookModel.fromGoogle(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<BookModel>> searchArchive(
      String query, int page) async {
    final url = ApiConstants.archiveSearch
        .replaceFirst('{query}', Uri.encodeComponent(query))
        .replaceFirst('{page}', '$page');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final response2 = json['response'] as Map<String, dynamic>? ?? {};
        final docs = (response2['docs'] as List<dynamic>?) ?? [];
        return docs
            .map((e) => BookModel.fromArchive(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
