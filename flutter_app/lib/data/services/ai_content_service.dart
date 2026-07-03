import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AiContentService {
  AiContentService._();
  static const AiContentService instance = AiContentService._();

  static const Map<String, String> _prompts = {
    'hadith':
        'بنووسە یەک فەرموودەی پێغەمبەر (د.خ) بە زمانی کوردی سۆرانی، کورت و بەمانا. تەنها متنی فەرموودەکە بنووسە، بێ سەرپووتان یان شیکاری زیاتر.',
    'dua':
        'بنووسە یەک دوعای ئیسلامی بە عەرەبی، پاشان وەرگێڕانی بۆ کوردی سۆرانی لە کێژیدا. فۆرمات: عەرەبی لەسەر، کوردی لەژێر، بە لایینێک جیاکردنەوە.',
    'name':
        'یەکێک لە ناوە جوانەکانی خودا (ئەسمائی حوسنا) هەڵبژێرە و مانای بە کوردی سۆرانی بنووسە. فۆرمات JSON: {"name": "...", "meaning": "..."}',
    'info':
        'بنووسە یەک زانیاری ئیسلامی سوودمەند و نوێ بە کوردی سۆرانی، کورت و ئاڵۆز. تەنها زانیاریەکە بنووسە.',
    'ayah':
        'یەک ئایەتی قورئانی بە عەرەبی هەڵبژێرە (نا دووبارە، نوێ بێت). پاشان سورەتەکەی تێدا بنووسە. فۆرمات JSON: {"text": "...", "source": "سورة ..."}',
  };

  bool _fetching = false;

  Future<dynamic> fetchContent(String type) async {
    if (_fetching) return null;
    _fetching = true;
    try {
      final prompt = _prompts[type] ?? _prompts['info']!;
      final response = await http
          .post(
            Uri.parse(ApiConstants.aiWorkerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (data['content'] as String? ?? '').trim();
      if (text.isEmpty) return null;

      if (type == 'name' || type == 'ayah') {
        try {
          final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();
          return jsonDecode(clean) as Map<String, dynamic>;
        } catch (_) {
          return text;
        }
      }
      return text;
    } catch (_) {
      return null;
    } finally {
      _fetching = false;
    }
  }
}
