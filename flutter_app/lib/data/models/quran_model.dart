class AyahModel {
  final String text;
  final int numberInSurah;

  const AyahModel({required this.text, required this.numberInSurah});

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      text: json['text'] as String? ?? '',
      numberInSurah: json['numberInSurah'] as int? ?? 0,
    );
  }
}

class SurahModel {
  final int number;
  final String name;
  final String englishName;
  final int numberOfAyahs;

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.numberOfAyahs,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      numberOfAyahs: json['numberOfAyahs'] as int? ?? 0,
    );
  }

  String get displayName => '$number. $name';
}

class QuranHistoryItem {
  final int surahNumber;
  final String surahName;
  final String date;

  const QuranHistoryItem({
    required this.surahNumber,
    required this.surahName,
    required this.date,
  });

  factory QuranHistoryItem.fromJson(Map<String, dynamic> json) {
    return QuranHistoryItem(
      surahNumber: json['number'] as int? ?? 0,
      surahName: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'number': surahNumber,
        'name': surahName,
        'date': date,
      };
}
