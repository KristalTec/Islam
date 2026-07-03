import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/feed_item_model.dart';
import '../data/models/quran_model.dart';
import '../data/repositories/feed_repository.dart';
import '../data/services/notification_service.dart';
import '../core/utils/date_utils.dart';

class HomeProvider extends ChangeNotifier {
  String _currentDate = '';
  List<FeedItemModel> _feedItems = [];
  bool _isLoading = true;
  bool _notifActive = false;
  int _visitCount = 0;
  int _onlineCount = 1;
  Timer? _updateTimer;
  List<QuranHistoryItem> _readingHistory = [];

  String get currentDate => _currentDate;
  List<FeedItemModel> get feedItems => _feedItems;
  bool get isLoading => _isLoading;
  bool get notifActive => _notifActive;
  int get visitCount => _visitCount;
  int get onlineCount => _onlineCount;
  List<QuranHistoryItem> get readingHistory => _readingHistory;

  HomeProvider() {
    _init();
  }

  Future<void> _init() async {
    _currentDate = AppDateUtils.getFormattedDate();
    await _loadPrefs();
    await _loadFeed();
    _startLiveUpdates();
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Visit counter
    _visitCount = (prefs.getInt('total_site_visits') ?? 0) + 1;
    await prefs.setInt('total_site_visits', _visitCount);

    // Notification preference
    _notifActive = prefs.getBool('isNotifActive') ?? false;
  }

  Future<void> _loadFeed() async {
    _isLoading = true;
    notifyListeners();

    _feedItems = await FeedRepository.instance.loadFromStorage();

    if (_feedItems.isEmpty) {
      // Generate initial content
      await _addInitialContent();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _addInitialContent() async {
    final fallback1 = FeedRepository.instance.localFallback('hadith');
    final fallback2 = FeedRepository.instance.localFallback('info');
    _feedItems = [fallback2, fallback1];

    // Try loading a random ayah
    final ayah = await FeedRepository.instance.fetchNewItem('ayah');
    if (ayah != null) {
      _feedItems.insert(0, ayah);
    }

    await FeedRepository.instance.saveToStorage(_feedItems);
    notifyListeners();
  }

  void _startLiveUpdates() {
    // First update after 30s, then every 5 minutes
    Future.delayed(const Duration(seconds: 30), () => triggerUpdate());
    _updateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => triggerUpdate(),
    );
  }

  Future<void> triggerUpdate() async {
    final types = ['hadith', 'dua', 'name', 'info', 'ayah'];
    final type = types[Random().nextInt(types.length)];
    final item = await FeedRepository.instance.fetchNewItem(type);
    if (item == null) return;

    _feedItems.insert(0, item);
    if (_feedItems.length > 50) _feedItems.removeLast();
    await FeedRepository.instance.saveToStorage(_feedItems);

    if (_notifActive) {
      String title = '🌙 زانیاری نوێ';
      String body = 'نوێکرایەوە';
      if (type == 'hadith') title = '📿 فەرموودەی نوێ';
      else if (type == 'dua') title = '🤲 دوعای ڕۆژ';
      else if (type == 'name') title = '✨ ناوی خودای گەورە';
      else if (type == 'ayah') title = '📖 ئایەتی نوێ';

      if (item.content is String) {
        final contentStr = item.content as String;
        body = contentStr
            .replaceAll(RegExp(r'<[^>]+>'), '')
            .substring(0, min(60, contentStr.length));
      } else if (item.content is Map) {
        final m = item.content as Map;
        body = m['name'] != null
            ? '${m['name']}: ${m['meaning']}'
            : (m['text'] ?? '').toString().substring(
                0, min(60, (m['text'] ?? '').toString().length));
      }

      await NotificationService.showFeedNotification(title: title, body: body);
    }

    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    if (_notifActive) {
      _notifActive = false;
    } else {
      await NotificationService.requestPermission();
      _notifActive = true;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotifActive', _notifActive);
    notifyListeners();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quran_history');
    if (raw == null) {
      _readingHistory = [];
    } else {
      try {
        final decoded =
            (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
        _readingHistory = decoded
            .map((e) => QuranHistoryItem.fromJson(e))
            .toList();
      } catch (_) {
        _readingHistory = [];
      }
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quran_history');
    _readingHistory = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
