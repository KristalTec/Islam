class ApiConstants {
  ApiConstants._();

  // Prayer times (aladhan.com)
  static const String aladhanBase = 'https://api.aladhan.com/v1';
  static const String prayerTimingsCity =
      '$aladhanBase/timingsByCity?city={city}&country=Iraq&method=3';
  static const String prayerTimingsCoords =
      '$aladhanBase/timings?latitude={lat}&longitude={lng}&method=3';

  // Quran API
  static const String alquranBase = 'https://api.alquran.cloud/v1';
  static const String surahList = '$alquranBase/surah';
  static const String surahDetail = '$alquranBase/surah/{number}/editions/quran-uthmani';
  static const String randomAyah = '$alquranBase/ayah/{id}/editions/quran-uthmani';

  // Library APIs
  static const String openLibrarySearch =
      'https://openlibrary.org/search.json?q={query}&page={page}&limit=10&fields=key,title,author_name,cover_i,first_publish_year,language';
  static const String openLibraryCover =
      'https://covers.openlibrary.org/b/id/{id}-M.jpg';
  static const String openLibraryBook = 'https://openlibrary.org{key}';

  static const String googleBooksSearch =
      'https://www.googleapis.com/books/v1/volumes?q={query}&startIndex={start}&maxResults=10';

  static const String archiveSearch =
      'https://archive.org/advancedsearch.php?q={query}&fl[]=identifier,title,creator,subject,description&rows=10&page={page}&output=json&mediatype=texts';
  static const String archiveItemUrl = 'https://archive.org/details/{id}';

  // AI Worker (Claude via Cloudflare Workers)
  static const String aiWorkerUrl =
      'https://islam-online-ai.muhammadibrahimrasul.workers.dev';

  // Adhan audio sources
  static const Map<String, String> adhanSounds = {
    'makkah': 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    'madina': 'https://www.islamcan.com/audio/adhan/azan3.mp3',
    'aqsa': 'https://www.islamcan.com/audio/adhan/azan6.mp3',
    'mishary': 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    'abdulbasit': 'https://www.islamcan.com/audio/adhan/azan10.mp3',
  };

  // Notification sound
  static const String notifSoundUrl =
      'https://www.islamcan.com/audio/adhan/bismillah.mp3';

  // IP geolocation
  static const String ipApiUrl = 'https://ipapi.co/json/';

  // WebSocket presence
  static const String wsChannelUrl =
      'wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self=1';
}
