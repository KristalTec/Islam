import '../entities/prayer_times_entity.dart';

abstract class PrayerRepository {
  Future<PrayerTimesEntity?> fetchByCity(String city);

  Future<PrayerTimesEntity?> fetchByCoords(double latitude, double longitude);
}
