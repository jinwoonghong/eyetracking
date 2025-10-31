import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/eye_tracking_provider.dart';
import '../models/game_state.dart';
import '../models/track.dart';
import 'calibration_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 로고 및 제목
              Icon(
                Icons.remove_red_eye,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Star Tracer',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '시선으로 별자리를 연결하세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),

              const Spacer(),

              // 메뉴 버튼들
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _MenuButton(
                      label: '게임 시작',
                      icon: Icons.play_arrow,
                      onPressed: () => _startGame(context),
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: '난이도 선택',
                      icon: Icons.tune,
                      onPressed: () => _showDifficultyDialog(context),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: '테마 선택',
                      icon: Icons.palette,
                      onPressed: () => _showThemeDialog(context),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: '기록 보기',
                      icon: Icons.leaderboard,
                      onPressed: () => _showHighScores(context),
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: '설정',
                      icon: Icons.settings,
                      onPressed: () => _openSettings(context),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 하단 정보
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context) async {
    final eyeTracking = context.read<EyeTrackingProvider>();
    final gameProvider = context.read<GameProvider>();

    // 카메라 초기화
    if (!eyeTracking.isCameraInitialized) {
      await eyeTracking.initializeCamera();
    }

    // 캘리브레이션 확인
    if (!eyeTracking.isCalibrated) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CalibrationScreen()),
        );
      }
    } else {
      // 트랙 생성 및 게임 시작
      final track = Track.createSampleTrack(
        id: 'track_1',
        name: '초보자 코스',
        difficulty: gameProvider.difficulty,
        theme: gameProvider.theme,
        screenSize: MediaQuery.of(context).size,
      );

      gameProvider.startGame(track);

      if (context.mounted) {
        Navigator.of(context).pushNamed('/game');
      }
    }
  }

  void _showDifficultyDialog(BuildContext context) {
    final gameProvider = context.read<GameProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('난이도 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((difficulty) {
            return ListTile(
              title: Text(difficulty.displayName),
              leading: Radio<Difficulty>(
                value: difficulty,
                groupValue: gameProvider.difficulty,
                onChanged: (value) {
                  if (value != null) {
                    gameProvider.setDifficulty(value);
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final gameProvider = context.read<GameProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GameTheme.values.map((theme) {
            return ListTile(
              title: Text(theme.displayName),
              subtitle: Text(
                theme.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              leading: Radio<GameTheme>(
                value: theme,
                groupValue: gameProvider.theme,
                onChanged: (value) {
                  if (value != null) {
                    gameProvider.setTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHighScores(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final scores = gameProvider.highScores;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('최고 기록'),
        content: scores.isEmpty
            ? const Text('아직 기록이 없습니다.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final result = scores[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('${result.score}점'),
                      subtitle: Text(
                        '정확도: ${result.accuracy.toStringAsFixed(1)}% | ${result.formattedTime}',
                      ),
                      trailing: Text(
                        result.grade,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          foregroundColor: isPrimary
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isPrimary ? 8 : 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
