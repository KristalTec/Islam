class AyahEntity {
  final String text;
  final int numberInSurah;

  const AyahEntity({
    required this.text,
    required this.numberInSurah,
  });
}

class SurahEntity {
  final int number;
  final String name;
  final String englishName;
  final int numberOfAyahs;

  const SurahEntity({
    required this.number,
    required this.name,
    required this.englishName,
    required this.numberOfAyahs,
  });
}

class QuranHistoryEntity {
  final int surahNumber;
  final String surahName;
  final String date;

  const QuranHistoryEntity({
    required this.surahNumber,
    required this.surahName,
    required this.date,
  });
}
