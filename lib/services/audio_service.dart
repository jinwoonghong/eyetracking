import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _soundPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;

  // 설정
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  set soundEnabled(bool value) {
    _soundEnabled = value;
    if (!value) {
      _soundPlayer.stop();
    }
  }

  set musicEnabled(bool value) {
    _musicEnabled = value;
    if (!value) {
      _musicPlayer.stop();
    }
  }

  set vibrationEnabled(bool value) {
    _vibrationEnabled = value;
  }

  // 초기화
  Future<void> initialize() async {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _soundPlayer.setReleaseMode(ReleaseMode.release);
  }

  // ========================================
  // 사운드 효과
  // ========================================

  // 트랙 유지 사운드 (부드럽고 긍정적인 소리)
  Future<void> playOnTrack() async {
    if (!_soundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource('sounds/on_track.mp3'));
    } catch (e) {
      // 사운드 파일이 없는 경우 무시
      debugPrint('Sound file not found: $e');
    }
  }

  // 트랙 이탈 사운드 (경고음)
  Future<void> playOffTrack() async {
    if (!_soundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource('sounds/off_track.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }

    // 진동
    if (_vibrationEnabled) {
      _vibrate(duration: 200);
    }
  }

  // 콤보 증가 사운드
  Future<void> playCombo(int comboCount) async {
    if (!_soundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource('sounds/combo.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }

    // 콤보가 높을수록 강한 진동
    if (_vibrationEnabled && comboCount % 5 == 0) {
      _vibrate(duration: 100);
    }
  }

  // 피버 모드 시작 사운드
  Future<void> playFeverStart() async {
    if (!_soundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource('sounds/fever_start.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }

    // 강한 진동
    if (_vibrationEnabled) {
      _vibratePattern();
    }
  }

  // 피버 모드 종료 사운드
  Future<void> playFeverEnd() async {
    if (!_soundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource('sounds/fever_end.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }
  }

  // 게임 완료 사운드
  Future<void> playGameComplete() async {
    if (!_soundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource('sounds/game_complete.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }

    // 축하 진동 패턴
    if (_vibrationEnabled) {
      _vibratePattern(pattern: [0, 200, 100, 200]);
    }
  }

  // 버튼 클릭 사운드
  Future<void> playClick() async {
    if (!_soundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }
  }

  // ========================================
  // 배경 음악
  // ========================================

  // 메뉴 BGM
  Future<void> playMenuMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.play(AssetSource('sounds/menu_bgm.mp3'));
      _musicPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint('Music file not found: $e');
    }
  }

  // 게임 BGM
  Future<void> playGameMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.play(AssetSource('sounds/game_bgm.mp3'));
      _musicPlayer.setVolume(0.4);
    } catch (e) {
      debugPrint('Music file not found: $e');
    }
  }

  // 피버 BGM
  Future<void> playFeverMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.play(AssetSource('sounds/fever_bgm.mp3'));
      _musicPlayer.setVolume(0.6);
    } catch (e) {
      debugPrint('Music file not found: $e');
    }
  }

  // 음악 정지
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // 음악 일시정지
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  // 음악 재개
  Future<void> resumeMusic() async {
    await _musicPlayer.resume();
  }

  // ========================================
  // 진동
  // ========================================

  Future<void> _vibrate({int duration = 100}) async {
    if (!_vibrationEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  Future<void> _vibratePattern({List<int>? pattern}) async {
    if (!_vibrationEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(
          pattern: pattern ?? [0, 100, 50, 100],
        );
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  // ========================================
  // 정리
  // ========================================

  Future<void> dispose() async {
    await _soundPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
