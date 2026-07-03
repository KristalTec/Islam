import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/prayer_times_model.dart';
import '../data/services/prayer_times_service.dart';
import '../data/services/notification_service.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/date_utils.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerTimesModel? _prayerTimes;
  bool _isLoading = false;
  bool _hasError = false;
  String _currentCity = 'Sulaymaniyah';
  String _currentSound = 'makkah';
  double _volume = 1.0;
  bool _isMuted = false;
  bool _use12h = false;
  String? _activePrayer;
  bool _showAdhanAlert = false;
  String? _adhanAlertPrayer;
  double? _userLat;
  double? _userLng;
  String _lastPlayedTime = '';

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _checkTimer;

  PrayerTimesModel? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get currentCity => _currentCity;
  String get currentSound => _currentSound;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  bool get use12h => _use12h;
  String? get activePrayer => _activePrayer;
  bool get showAdhanAlert => _showAdhanAlert;
  String? get adhanAlertPrayer => _adhanAlertPrayer;

  PrayerProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadPrefs();
    await _detectLocation();
    _startTimeLoop();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCity = prefs.getString('selectedCity') ?? 'Sulaymaniyah';
    _currentSound = prefs.getString('selectedSound') ?? 'makkah';
    _volume = prefs.getDouble('adhanVolume') ?? 1.0;
    _use12h = prefs.getString('timeFormat') == '12';
    _userLat = prefs.getDouble('userLat');
    _userLng = prefs.getDouble('userLng');
    notifyListeners();
  }

  Future<void> _detectLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      _userLat = double.parse(pos.latitude.toStringAsFixed(4));
      _userLng = double.parse(pos.longitude.toStringAsFixed(4));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('userLat', _userLat!);
      await prefs.setDouble('userLng', _userLng!);
    } catch (_) {}
    await fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    PrayerTimesModel? result;
    if (_userLat != null && _userLng != null) {
      result = await PrayerTimesService.instance
          .fetchByCoords(_userLat!, _userLng!);
    }
    result ??= await PrayerTimesService.instance.fetchByCity(_currentCity);

    if (result != null) {
      _prayerTimes = result;
      _hasError = false;
    } else {
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeCity(String city) async {
    _currentCity = city;
    _userLat = null;
    _userLng = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
    await prefs.remove('userLat');
    await prefs.remove('userLng');
    notifyListeners();
    await fetchPrayerTimes();
  }

  Future<void> changeSound(String key) async {
    _currentSound = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSound', key);
    final url = ApiConstants.adhanSounds[key]!;
    await _audioPlayer.setUrl(url);
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v;
    _audioPlayer.setVolume(v);
    SharedPreferences.getInstance()
        .then((p) => p.setDouble('adhanVolume', v));
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _audioPlayer.setVolume(_isMuted ? 0 : _volume);
    notifyListeners();
  }

  Future<void> toggleTimeFormat() async {
    _use12h = !_use12h;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timeFormat', _use12h ? '12' : '24');
    notifyListeners();
  }

  String formatTime(String time24) =>
      AppDateUtils.formatTime(time24, use12h: _use12h);

  void _startTimeLoop() {
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkCurrentPrayer();
    });
    _checkCurrentPrayer();
  }

  void _checkCurrentPrayer() {
    if (_prayerTimes == null) return;
    final now = AppDateUtils.getCurrentHHMM();
    final map = _prayerTimes!.timingsMap;

    String? active;
    for (final entry in map.entries) {
      if (entry.value == now) {
        active = entry.key;
        if (entry.key != 'Sunrise' && _lastPlayedTime != now) {
          _triggerAdhan(entry.key);
          _lastPlayedTime = now;
        }
        break;
      }
    }
    _activePrayer = active;
    notifyListeners();
  }

  Future<void> _triggerAdhan(String prayerKey) async {
    const nameMap = {
      'Fajr': 'بەیانی',
      'Dhuhr': 'نیوەڕۆ',
      'Asr': 'عەسر',
      'Maghrib': 'مەغریب',
      'Isha': 'عیشا',
    };

    _adhanAlertPrayer = nameMap[prayerKey] ?? prayerKey;
    _showAdhanAlert = true;
    notifyListeners();

    if (!_isMuted) {
      final url = ApiConstants.adhanSounds[_currentSound]!;
      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play();
      } catch (_) {}
    }

    await NotificationService.showPrayerNotification(
      prayerName: _adhanAlertPrayer!,
      body: 'بانگی ${_adhanAlertPrayer!} - الله أكبر',
    );

    // Hide alert after 5 minutes
    Future.delayed(const Duration(minutes: 5), () {
      _showAdhanAlert = false;
      _audioPlayer.pause();
      notifyListeners();
    });
  }

  void dismissAdhanAlert() {
    _showAdhanAlert = false;
    _audioPlayer.pause();
    notifyListeners();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
