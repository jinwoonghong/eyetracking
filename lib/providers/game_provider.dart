import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track.dart';
import '../models/game_state.dart';
import '../models/game_result.dart';
import '../services/audio_service.dart';

class GameProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  // 게임 상태
  GameState _gameState = GameState.menu;
  GameState get gameState => _gameState;

  // 현재 트랙
  Track? _currentTrack;
  Track? get currentTrack => _currentTrack;

  // 게임 진행 상태
  double _progress = 0.0; // 0.0 ~ 1.0
  double get progress => _progress;

  int _score = 0;
  int get score => _score;

  int _combo = 0;
  int get combo => _combo;

  double _accuracy = 100.0; // 0.0 ~ 100.0
  double get accuracy => _accuracy;

  // 페널티/보상
  double _speedMultiplier = 1.0;
  double get speedMultiplier => _speedMultiplier;

  double _feverGauge = 0.0; // 0.0 ~ 100.0
  double get feverGauge => _feverGauge;

  bool _isFeverMode = false;
  bool get isFeverMode => _isFeverMode;

  // 난이도
  Difficulty _difficulty = Difficulty.beginner;
  Difficulty get difficulty => _difficulty;

  // 테마
  GameTheme _theme = GameTheme.constellation;
  GameTheme get theme => _theme;

  // 추적 상태
  bool _isOnTrack = true;
  bool get isOnTrack => _isOnTrack;

  // 타이머
  int _elapsedTime = 0; // milliseconds
  int get elapsedTime => _elapsedTime;

  // 최고 기록
  List<GameResult> _highScores = [];
  List<GameResult> get highScores => _highScores;

  GameProvider() {
    _loadHighScores();
  }

  // 게임 시작
  void startGame(Track track) {
    _currentTrack = track;
    _gameState = GameState.playing;
    _progress = 0.0;
    _score = 0;
    _combo = 0;
    _accuracy = 100.0;
    _speedMultiplier = 1.0;
    _feverGauge = 0.0;
    _isFeverMode = false;
    _isOnTrack = true;
    _elapsedTime = 0;

    // 게임 음악 재생
    _audioService.playGameMusic();

    notifyListeners();
  }

  // 게임 일시정지
  void pauseGame() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      _audioService.pauseMusic();
      notifyListeners();
    }
  }

  // 게임 재개
  void resumeGame() {
    if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      _audioService.resumeMusic();
      notifyListeners();
    }
  }

  // 게임 종료
  void endGame() {
    _gameState = GameState.finished;
    _saveGameResult();

    // 완료 사운드 및 음악 정지
    _audioService.playGameComplete();
    _audioService.stopMusic();

    notifyListeners();
  }

  // 메뉴로 돌아가기
  void returnToMenu() {
    _gameState = GameState.menu;
    _currentTrack = null;

    // 음악 정지
    _audioService.stopMusic();

    notifyListeners();
  }

  // 진행도 업데이트
  void updateProgress(double progress) {
    _progress = progress.clamp(0.0, 1.0);

    if (_progress >= 1.0) {
      endGame();
    }

    notifyListeners();
  }

  // 트랙 위 여부 체크
  void checkOnTrack(bool onTrack) {
    if (_gameState != GameState.playing) return;

    final wasOnTrack = _isOnTrack;
    _isOnTrack = onTrack;

    if (!onTrack && wasOnTrack) {
      // 트랙 이탈
      _applyPenalty();
    } else if (onTrack && !wasOnTrack) {
      // 트랙 복귀
      _applyReward();
    } else if (onTrack) {
      // 트랙 유지
      _maintainOnTrack();
    }

    notifyListeners();
  }

  // 페널티 적용
  void _applyPenalty() {
    // 속도 감소
    _speedMultiplier = 0.5;

    // 콤보 및 피버 초기화
    _combo = 0;
    _feverGauge = 0;
    _isFeverMode = false;

    // 정확도 감소
    _accuracy = (_accuracy - 5.0).clamp(0.0, 100.0);

    // 사운드 및 진동
    _audioService.playOffTrack();

    debugPrint('Penalty applied - Speed: $_speedMultiplier, Accuracy: $_accuracy');
  }

  // 보상 적용
  void _applyReward() {
    // 속도 복구
    _speedMultiplier = 1.0;

    debugPrint('Reward applied - Speed restored');
  }

  // 트랙 유지 시 보상
  void _maintainOnTrack() {
    // 콤보 증가
    _combo++;

    // 피버 게이지 충전
    _feverGauge = (_feverGauge + 1.0).clamp(0.0, 100.0);

    // 점수 증가
    final baseScore = 10;
    final multiplier = _isFeverMode ? 2.0 : 1.0;
    _score += (baseScore * multiplier).toInt();

    // 콤보 사운드 (매 5 콤보마다)
    if (_combo % 5 == 0) {
      _audioService.playCombo(_combo);
    }

    // 피버 모드 체크
    if (_feverGauge >= 100.0 && !_isFeverMode) {
      _activateFeverMode();
    }

    // 정확도 미세 증가
    _accuracy = (_accuracy + 0.1).clamp(0.0, 100.0);
  }

  // 피버 모드 활성화
  void _activateFeverMode() {
    _isFeverMode = true;
    _speedMultiplier = 1.5;

    // 사운드 및 진동
    _audioService.playFeverStart();
    _audioService.playFeverMusic();

    debugPrint('FEVER MODE ACTIVATED!');

    // 10초 후 피버 모드 종료
    Future.delayed(const Duration(seconds: 10), () {
      _deactivateFeverMode();
    });
  }

  // 피버 모드 비활성화
  void _deactivateFeverMode() {
    _isFeverMode = false;
    _speedMultiplier = 1.0;
    _feverGauge = 0;

    // 사운드
    _audioService.playFeverEnd();
    _audioService.playGameMusic(); // 일반 게임 음악으로 복귀

    notifyListeners();
    debugPrint('Fever mode ended');
  }

  // 시간 업데이트
  void updateElapsedTime(int milliseconds) {
    _elapsedTime = milliseconds;
    notifyListeners();
  }

  // 난이도 설정
  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  // 테마 설정
  void setTheme(GameTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  // 게임 결과 저장
  Future<void> _saveGameResult() async {
    if (_currentTrack == null) return;

    final result = GameResult(
      trackId: _currentTrack!.id,
      score: _score,
      accuracy: _accuracy,
      maxCombo: _combo,
      elapsedTime: _elapsedTime,
      difficulty: _difficulty,
      theme: _theme,
      timestamp: DateTime.now(),
    );

    _highScores.add(result);
    _highScores.sort((a, b) => b.score.compareTo(a.score));

    // 상위 10개만 유지
    if (_highScores.length > 10) {
      _highScores = _highScores.sublist(0, 10);
    }

    await _saveHighScoresToStorage();
  }

  // 최고 기록 로드
  Future<void> _loadHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = prefs.getStringList('high_scores') ?? [];

      _highScores = scoresJson.map((json) {
        // TODO: JSON 파싱 구현
        return GameResult.fromJson(json);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading high scores: $e');
    }
  }

  // 최고 기록 저장
  Future<void> _saveHighScoresToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = _highScores.map((result) => result.toJson()).toList();
      await prefs.setStringList('high_scores', scoresJson);
    } catch (e) {
      debugPrint('Error saving high scores: $e');
    }
  }

  // 통계 가져오기
  GameStats getStats() {
    if (_highScores.isEmpty) {
      return GameStats(
        totalGames: 0,
        highestScore: 0,
        averageAccuracy: 0,
        totalPlayTime: 0,
      );
    }

    return GameStats(
      totalGames: _highScores.length,
      highestScore: _highScores.first.score,
      averageAccuracy: _highScores.map((r) => r.accuracy).reduce((a, b) => a + b) / _highScores.length,
      totalPlayTime: _highScores.map((r) => r.elapsedTime).reduce((a, b) => a + b),
    );
  }
}

// 게임 통계
class GameStats {
  final int totalGames;
  final int highestScore;
  final double averageAccuracy;
  final int totalPlayTime; // milliseconds

  GameStats({
    required this.totalGames,
    required this.highestScore,
    required this.averageAccuracy,
    required this.totalPlayTime,
  });
}
