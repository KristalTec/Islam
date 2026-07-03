import 'package:flutter/foundation.dart';

import '../data/models/hadith_model.dart';
import '../data/repositories/hadith_repository.dart';

class HadithProvider extends ChangeNotifier {
  List<HadithModel> _displayed = [];
  String _activeTab = 'all';
  String _searchQuery = '';

  List<HadithModel> get displayed => _displayed;
  String get activeTab => _activeTab;

  HadithProvider() {
    _refresh();
  }

  void switchTab(String book) {
    _activeTab = book;
    _searchQuery = '';
    _refresh();
  }

  void search(String query) {
    _searchQuery = query;
    _refresh();
  }

  void _refresh() {
    if (_searchQuery.isNotEmpty) {
      _displayed = HadithRepository.instance.search(
        _searchQuery,
        book: _activeTab == 'all' ? null : _activeTab,
      );
    } else if (_activeTab == 'all') {
      _displayed = HadithRepository.instance.getAll();
    } else {
      _displayed = HadithRepository.instance.getByBook(_activeTab);
    }
    notifyListeners();
  }
}
