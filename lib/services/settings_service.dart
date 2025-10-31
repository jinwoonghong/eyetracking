import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // 초기화
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
    _musicEnabled = prefs.getBool(_keyMusicEnabled) ?? true;
    _vibrationEnabled = prefs.getBool(_keyVibrationEnabled) ?? true;
  }

  // 사운드 설정
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, value);
  }

  // 음악 설정
  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusicEnabled, value);
  }

  // 진동 설정
  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibrationEnabled, value);
  }
}
