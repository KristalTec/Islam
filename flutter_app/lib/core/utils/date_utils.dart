import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Returns the current date formatted in Arabic (Iraqi) locale.
  static String getFormattedDate() {
    final now = DateTime.now();
    // intl doesn't natively support ar-IQ weekday names the same way JS does,
    // so we build a human-readable Arabic string manually.
    final weekdays = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday، ${now.day} $month ${now.year}';
  }

  /// Formats a "HH:mm" time string from 24h to 12h if requested.
  static String formatTime(String time24, {bool use12h = false}) {
    if (!use12h) return time24;
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    int hours = int.tryParse(parts[0]) ?? 0;
    final minutes = parts[1];
    final ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    if (hours == 0) hours = 12;
    return '$hours:$minutes $ampm';
  }

  /// Returns "HH:mm" from the current local time.
  static String getCurrentHHMM() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Converts a Gregorian date string "DD-MM-YYYY" to Hijri approximation.
  /// The actual Hijri date is provided by the API response; this is a fallback.
  static String toHijriLabel(String hijriDay, String hijriMonthEn) {
    return '$hijriDay $hijriMonthEn';
  }
}
