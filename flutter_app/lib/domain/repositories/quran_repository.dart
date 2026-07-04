import '../entities/quran_entity.dart';

abstract class QuranRepository {
  Future<List<SurahEntity>> fetchSurahList();

  Future<List<AyahEntity>> fetchSurah(int surahNumber);

  Future<Map<String, dynamic>?> fetchRandomAyah();

  Future<List<QuranHistoryEntity>> loadHistory();

  Future<void> saveHistory(List<QuranHistoryEntity> items);
}
