class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String gregorianDate;
  final String hijriDay;
  final String hijriMonthEn;

  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.gregorianDate,
    required this.hijriDay,
    required this.hijriMonthEn,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    final gregorian = date['gregorian'] as Map<String, dynamic>;

    String cleanTime(String t) => t.split(' ').first;

    return PrayerTimesModel(
      fajr: cleanTime(timings['Fajr'] as String? ?? ''),
      sunrise: cleanTime(timings['Sunrise'] as String? ?? ''),
      dhuhr: cleanTime(timings['Dhuhr'] as String? ?? ''),
      asr: cleanTime(timings['Asr'] as String? ?? ''),
      maghrib: cleanTime(timings['Maghrib'] as String? ?? ''),
      isha: cleanTime(timings['Isha'] as String? ?? ''),
      gregorianDate: gregorian['date'] as String? ?? '',
      hijriDay: hijri['day'] as String? ?? '',
      hijriMonthEn:
          (hijri['month'] as Map<String, dynamic>?)?['en'] as String? ?? '',
    );
  }

  Map<String, String> get timingsMap => {
        'Fajr': fajr,
        'Sunrise': sunrise,
        'Dhuhr': dhuhr,
        'Asr': asr,
        'Maghrib': maghrib,
        'Isha': isha,
      };
}
