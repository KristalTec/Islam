import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/prayer_times_model.dart';
import '../../core/constants/api_constants.dart';

class PrayerTimesService {
  PrayerTimesService._();
  static const PrayerTimesService instance = PrayerTimesService._();

  Future<PrayerTimesModel?> fetchByCity(String city) async {
    final url = ApiConstants.prayerTimingsCity.replaceFirst('{city}', city);
    return _fetch(url);
  }

  Future<PrayerTimesModel?> fetchByCoords(
      double latitude, double longitude) async {
    final url = ApiConstants.prayerTimingsCoords
        .replaceFirst('{lat}', latitude.toStringAsFixed(4))
        .replaceFirst('{lng}', longitude.toStringAsFixed(4));
    return _fetch(url);
  }

  Future<PrayerTimesModel?> _fetch(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['code'] == 200) {
          return PrayerTimesModel.fromJson(
              json['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }
}
