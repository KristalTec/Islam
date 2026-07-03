import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/quran_model.dart';
import '../../core/constants/api_constants.dart';

class QuranService {
  QuranService._();
  static const QuranService instance = QuranService._();

  Future<List<SurahModel>> fetchSurahList() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.surahList))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as List<dynamic>;
        return data
            .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<AyahModel>> fetchSurah(int surahNumber) async {
    final url =
        ApiConstants.surahDetail.replaceFirst('{number}', '$surahNumber');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final editions = json['data'] as List<dynamic>;
        if (editions.isNotEmpty) {
          final ayahs = (editions[0] as Map<String, dynamic>)['ayahs']
              as List<dynamic>;
          return ayahs
              .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> fetchRandomAyah() async {
    final id = (DateTime.now().millisecondsSinceEpoch % 6236) + 1;
    final url = ApiConstants.randomAyah.replaceFirst('{id}', '$id');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final editions = json['data'] as List<dynamic>;
        if (editions.isNotEmpty) {
          final ayah = editions[0] as Map<String, dynamic>;
          final surah = ayah['surah'] as Map<String, dynamic>;
          return {
            'text': ayah['text'] as String,
            'source': 'سورة ${surah['name'] as String}',
          };
        }
      }
    } catch (_) {}
    return null;
  }
}
