import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/game_provider.dart';
import '../providers/eye_tracking_provider.dart';
import '../models/game_state.dart';
import '../widgets/track_painter.dart';
import '../widgets/game_hud.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  Timer? _gameTimer;
  int _elapsedMilliseconds = 0;

  late AnimationController _feverAnimationController;

  @override
  void initState() {
    super.initState();

    _feverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    // 게임 타이머 시작
    _startGameTimer();

    // 시선 추적 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EyeTrackingProvider>().startTracking();
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final gameProvider = context.read<GameProvider>();

      if (gameProvider.gameState == GameState.playing) {
        setState(() {
          _elapsedMilliseconds += 50;
        });

        gameProvider.updateElapsedTime(_elapsedMilliseconds);

        // 진행도 업데이트 (시간 기반 또는 트랙 기반)
        _updateGameProgress();

        // 시선 추적 체크
        _checkGazeOnTrack();
      }
    });
  }

  void _updateGameProgress() {
    final gameProvider = context.read<GameProvider>();

    // 시간 기반 진행 (예: 60초 게임)
    // 또는 트랙 완주 기반
    final timeBasedProgress = _elapsedMilliseconds / 60000.0; // 60초
    gameProvider.updateProgress(timeBasedProgress * gameProvider.speedMultiplier);

    if (gameProvider.progress >= 1.0) {
      _endGame();
    }
  }

  void _checkGazeOnTrack() {
    final gameProvider = context.read<GameProvider>();
    final eyeTracking = context.read<EyeTrackingProvider>();
    final track = gameProvider.currentTrack;

    if (track == null || eyeTracking.gazePosition == null) {
      return;
    }

    // 시선이 트랙 위에 있는지 확인
    final tolerance = gameProvider.difficulty.trackWidth / 2;
    final isOnTrack = track.isPointOnTrack(
      eyeTracking.gazePosition!,
      tolerance,
    );

    gameProvider.checkOnTrack(isOnTrack);
  }

  void _endGame() {
    _gameTimer?.cancel();
    context.read<EyeTrackingProvider>().stopTracking();
    context.read<GameProvider>().endGame();

    // 결과 화면으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }

  void _pauseGame() {
    context.read<GameProvider>().pauseGame();
  }

  void _resumeGame() {
    context.read<GameProvider>().resumeGame();
  }

  void _quitGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('게임 종료'),
        content: const Text('정말로 게임을 종료하시겠습니까?\n진행 상황이 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _gameTimer?.cancel();
              context.read<EyeTrackingProvider>().stopTracking();
              context.read<GameProvider>().returnToMenu();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _feverAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, EyeTrackingProvider>(
      builder: (context, gameProvider, eyeTracking, child) {
        return Scaffold(
          body: Stack(
            children: [
              // 배경 (테마별 다른 배경)
              _buildBackground(gameProvider.theme),

              // 트랙 렌더링
              if (gameProvider.currentTrack != null)
                CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: TrackPainter(
                    track: gameProvider.currentTrack!,
                    progress: gameProvider.progress,
                    trackWidth: gameProvider.difficulty.trackWidth,
                    theme: gameProvider.theme,
                    isFeverMode: gameProvider.isFeverMode,
                    feverAnimation: _feverAnimationController,
                  ),
                ),

              // 시선 포인터
              if (eyeTracking.gazePosition != null)
                Positioned(
                  left: eyeTracking.gazePosition!.dx - 15,
                  top: eyeTracking.gazePosition!.dy - 15,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: gameProvider.isOnTrack
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gameProvider.isOnTrack ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                  ),
                ),

              // HUD (점수, 콤보, 게이지 등)
              GameHUD(
                score: gameProvider.score,
                combo: gameProvider.combo,
                accuracy: gameProvider.accuracy,
                progress: gameProvider.progress,
                feverGauge: gameProvider.feverGauge,
                isFeverMode: gameProvider.isFeverMode,
                elapsedTime: _elapsedMilliseconds,
              ),

              // 일시정지/설정 버튼
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white, size: 32),
                  onPressed: _pauseGame,
                ),
              ),

              // 일시정지 오버레이
              if (gameProvider.gameState == GameState.paused)
                _buildPauseOverlay(),

              // 피버 모드 효과
              if (gameProvider.isFeverMode)
                _buildFeverModeEffect(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground(GameTheme theme) {
    Color color1, color2;

    switch (theme) {
      case GameTheme.constellation:
        color1 = const Color(0xFF0F0D1A);
        color2 = const Color(0xFF1E1B4B);
        break;
      case GameTheme.jungle:
        color1 = const Color(0xFF0A1F0F);
        color2 = const Color(0xFF1B4D3E);
        break;
      case GameTheme.cityDrive:
        color1 = const Color(0xFF0D0A1A);
        color2 = const Color(0xFF2D1B4E);
        break;
      case GameTheme.underwater:
        color1 = const Color(0xFF0A1A2E);
        color2 = const Color(0xFF16213E);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pause_circle, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                '일시정지',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _resumeGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text(
                  '계속하기',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _quitGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text(
                  '종료',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeverModeEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _feverAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.yellow.withOpacity(_feverAnimationController.value * 0.5),
                  width: 10,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
