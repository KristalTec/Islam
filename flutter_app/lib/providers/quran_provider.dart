import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/models/quran_model.dart';
import '../data/services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  List<SurahModel> _surahList = [];
  List<AyahModel> _currentAyahs = [];
  int _currentSurahNumber = 1;
  String _currentSurahName = 'سورة الفاتحة';
  bool _isLoading = false;
  bool _hasError = false;

  // Speech recognition
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _liveCaption = 'ئامادەیە بۆ گوێگرتن...';

  // Word-by-word tracking
  int _currentAyahIndex = 0;
  int _currentWordIndex = 0;
  List<String> _currentWords = [];

  // Highlighted words: Map<"ayahIdx-wordIdx", bool>
  final Map<String, bool> _highlightedWords = {};

  List<SurahModel> get surahList => _surahList;
  List<AyahModel> get currentAyahs => _currentAyahs;
  int get currentSurahNumber => _currentSurahNumber;
  String get currentSurahName => _currentSurahName;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isListening => _isListening;
  bool get speechAvailable => _speechAvailable;
  String get liveCaption => _liveCaption;
  int get currentAyahIndex => _currentAyahIndex;
  Map<String, bool> get highlightedWords => _highlightedWords;

  QuranProvider() {
    _init();
  }

  // Hardcoded Al-Fatiha (offline fallback)
  static const List<Map<String, dynamic>> _fatihaData = [
    {'text': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', 'numberInSurah': 1},
    {'text': 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ', 'numberInSurah': 2},
    {'text': 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', 'numberInSurah': 3},
    {'text': 'مَٰلِكِ يَوْمِ ٱلدِّينِ', 'numberInSurah': 4},
    {'text': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', 'numberInSurah': 5},
    {'text': 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ', 'numberInSurah': 6},
    {
      'text':
          'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّالِّينَ',
      'numberInSurah': 7
    },
  ];

  Future<void> _init() async {
    _currentAyahs =
        _fatihaData.map((e) => AyahModel.fromJson(e)).toList();
    _prepareCurrentAyah();
    _fetchSurahList();
    _addToHistory(1, 'سورة الفاتحة');
    _speechAvailable = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    notifyListeners();
  }

  Future<void> _fetchSurahList() async {
    final list = await QuranService.instance.fetchSurahList();
    if (list.isNotEmpty) {
      _surahList = list;
      notifyListeners();
    }
  }

  Future<void> loadSurah(int number) async {
    _currentSurahNumber = number;
    if (_surahList.isNotEmpty) {
      final surah = _surahList.firstWhere(
        (s) => s.number == number,
        orElse: () => SurahModel(
            number: number,
            name: '',
            englishName: '',
            numberOfAyahs: 0),
      );
      _currentSurahName = surah.name;
    }
    _addToHistory(number, _currentSurahName);

    if (number == 1) {
      _currentAyahs = _fatihaData.map((e) => AyahModel.fromJson(e)).toList();
      _resetPosition();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final ayahs = await QuranService.instance.fetchSurah(number);
    if (ayahs.isNotEmpty) {
      _currentAyahs = ayahs;
      _hasError = false;
    } else {
      _hasError = true;
    }
    _isLoading = false;
    _resetPosition();
    notifyListeners();
  }

  void _resetPosition() {
    _currentAyahIndex = 0;
    _currentWordIndex = 0;
    _highlightedWords.clear();
    _prepareCurrentAyah();
  }

  void _prepareCurrentAyah() {
    if (_currentAyahIndex >= _currentAyahs.length) return;
    String text = _currentAyahs[_currentAyahIndex].text;
    // Remove basmala from first ayah (non-Fatiha, non-Tawbah)
    if (_currentSurahNumber != 1 &&
        _currentSurahNumber != 9 &&
        _currentAyahIndex == 0) {
      text = text
          .replaceFirst('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
          .trim();
    }
    _currentWords = text.split(' ');
    _currentWordIndex = 0;
  }

  // ==========================================
  // Speech recognition
  // ==========================================
  void toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    _isListening = true;
    _liveCaption = 'گوێدەگرێت...';
    notifyListeners();

    await _speech.listen(
      localeId: 'ar_SA',
      onResult: (result) {
        _liveCaption = result.recognizedWords;
        _checkMatch(result.recognizedWords);
        notifyListeners();
      },
      listenFor: const Duration(minutes: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    _isListening = false;
    _liveCaption = 'وەستا.';
    notifyListeners();
  }

  void _checkMatch(String spokenText) {
    if (_currentAyahIndex >= _currentAyahs.length) return;
    final spokenSkeleton = _getSkeleton(spokenText);
    for (int i = 0; i < 3; i++) {
      final idx = _currentWordIndex + i;
      if (idx >= _currentWords.length) break;
      final targetSkeleton = _getSkeleton(_currentWords[idx]);
      if (spokenSkeleton.contains(targetSkeleton)) {
        for (int j = 0; j <= i; j++) {
          _activateWord();
        }
        return;
      }
    }
  }

  void _activateWord() {
    final key = '$_currentAyahIndex-$_currentWordIndex';
    _highlightedWords[key] = true;
    _currentWordIndex++;
    if (_currentWordIndex >= _currentWords.length) {
      _nextAyah();
    }
    notifyListeners();
  }

  void _nextAyah() {
    _currentAyahIndex++;
    _liveCaption = '...';
    if (_currentAyahIndex < _currentAyahs.length) {
      _prepareCurrentAyah();
    } else {
      // Move to next surah
      final next = _currentSurahNumber + 1;
      if (next <= 114) {
        _liveCaption = 'تەواو بوو، دەچێتە سورەتی دواتر...';
        Future.delayed(const Duration(seconds: 1), () => loadSurah(next));
      } else {
        _liveCaption = 'پیرۆزە! هەموو قورئانت تەواو کرد.';
        _stopListening();
      }
    }
  }

  /// Normalises Arabic text by removing diacritics and unifying letter forms.
  String _getSkeleton(String text) {
    return text
        .replaceAll(
            RegExp(
                '[\u0610-\u061A\u064B-\u066F\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'),
            '')
        .replaceAll(RegExp('[اأإآٱٰ]'), '')
        .replaceAll(RegExp('(ى|ي|ئ)'), 'ي')
        .replaceAll(RegExp('(ة|ه)'), 'ه')
        .replaceAll(RegExp('(ؤ|و)'), 'و')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }

  // ==========================================
  // Bookmarks / Favorites
  // ==========================================
  Future<bool> saveToFavorites() async {
    if (_currentAyahs.isEmpty ||
        _currentAyahIndex >= _currentAyahs.length) return false;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quran_favorites') ?? '[]';
    List<dynamic> favs = [];
    try {
      favs = jsonDecode(raw) as List<dynamic>;
    } catch (_) {}

    final ayahNum = _currentAyahs[_currentAyahIndex].numberInSurah;
    final newFav = {
      'surahNum': _currentSurahNumber,
      'surahName': _currentSurahName,
      'ayahIndex': _currentAyahIndex,
      'ayahDisplayNum': ayahNum,
      'date': DateTime.now().toLocal().toString(),
    };

    final exists = favs.any((f) =>
        (f as Map)['surahNum'] == newFav['surahNum'] &&
        f['ayahIndex'] == newFav['ayahIndex']);

    if (!exists) {
      favs.insert(0, newFav);
      await prefs.setString('quran_favorites', jsonEncode(favs));
      return true;
    }
    return false;
  }

  Future<void> _addToHistory(int surahNum, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('quran_history') ?? '[]';
      List<dynamic> history = jsonDecode(raw) as List<dynamic>;
      history.removeWhere((h) => (h as Map)['number'] == surahNum);
      history.insert(0, {
        'number': surahNum,
        'name': name,
        'date': DateTime.now().toLocal().toIso8601String().split('T').first,
      });
      if (history.length > 10) history.removeLast();
      await prefs.setString('quran_history', jsonEncode(history));
    } catch (_) {}
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
