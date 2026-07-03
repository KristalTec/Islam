import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/feed_item_model.dart';
import '../services/ai_content_service.dart';
import '../services/quran_service.dart';

/// Local fallback data matching index.html's db object.
class FeedRepository {
  FeedRepository._();
  static const FeedRepository instance = FeedRepository._();

  static const List<String> _hadiths = [
    'پێغەمبەر (د.خ) دەفەرموێت: باشترینتان ئەوەیە کە قورئان فێر دەبێت و فێری خەڵکیشی دەکات.',
    'پێکەنین بە ڕووی براکەتدا سەدەقەیە.',
    'پاکوخاوێنی بەشێکە لە ئیمان.',
    'کەسێکتان ئیمانی تەواو نییە تا ئەوەی بۆ خۆی پێی خۆشە بۆ براکەشی پێی خۆش نەبێت.',
    'وشەی پاک سەدەقەیە.',
    'خودا جوانە و جوانی خۆشدەوێت.',
  ];

  static const List<String> _duas = [
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً',
    'اللهم إني أسألك الهدى والتقى والعفاف والغنى',
    'يا مقلب القلوب ثبت قلبي على دينك',
    'اللهم إنك عفو تحب العفو فاعف عني',
    'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
  ];

  static const List<Map<String, String>> _names = [
    {'name': 'الرحمن', 'meaning': 'بەخشندە'},
    {'name': 'الرحيم', 'meaning': 'بەبەزەیی'},
    {'name': 'الملك', 'meaning': 'پاشا'},
    {'name': 'القدوس', 'meaning': 'پاک'},
    {'name': 'السلام', 'meaning': 'ئاشتی'},
  ];

  static const List<String> _info = [
    'یەکەم مزگەوت لە ئیسلامدا مزگەوتی قوبائە.',
    'قورئانی پیرۆز لە ١١٤ سورەت پێکهاتووە.',
    'درێژترین سورەتی قورئان سورەتی بەقەرەیە.',
    'کورتترین سورەت الکوثرە.',
  ];

  static const String _storageKey = 'islam_feed_data';

  Future<List<FeedItemModel>> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FeedItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveToStorage(List<FeedItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// Returns a random local fallback item for the given type.
  FeedItemModel localFallback(String type) {
    final rng = Random();
    switch (type) {
      case 'hadith':
        return FeedItemModel(
          type: FeedItemType.hadith,
          content: _hadiths[rng.nextInt(_hadiths.length)],
          createdAt: DateTime.now(),
        );
      case 'dua':
        return FeedItemModel(
          type: FeedItemType.dua,
          content: _duas[rng.nextInt(_duas.length)],
          createdAt: DateTime.now(),
        );
      case 'name':
        return FeedItemModel(
          type: FeedItemType.name,
          content: _names[rng.nextInt(_names.length)],
          createdAt: DateTime.now(),
        );
      default:
        return FeedItemModel(
          type: FeedItemType.info,
          content: _info[rng.nextInt(_info.length)],
          createdAt: DateTime.now(),
        );
    }
  }

  /// Fetches a new feed item: tries AI worker first, then falls back to
  /// local data or Quran API.
  Future<FeedItemModel?> fetchNewItem(String type) async {
    dynamic aiResult = await AiContentService.instance.fetchContent(type);

    if (aiResult != null) {
      final itemType = FeedItemType.values
          .firstWhere((e) => e.name == type, orElse: () => FeedItemType.info);
      return FeedItemModel(
        type: itemType,
        content: aiResult,
        isNew: true,
        createdAt: DateTime.now(),
      );
    }

    // Fallback for 'ayah': use Quran API
    if (type == 'ayah') {
      final ayah = await QuranService.instance.fetchRandomAyah();
      if (ayah != null) {
        return FeedItemModel(
          type: FeedItemType.ayah,
          content: ayah,
          isNew: true,
          createdAt: DateTime.now(),
        );
      }
    }

    // Local fallback for other types
    if (type != 'ayah') {
      final item = localFallback(type);
      return FeedItemModel(
        type: item.type,
        content: item.content,
        isNew: true,
        createdAt: DateTime.now(),
      );
    }

    return null;
  }
}
