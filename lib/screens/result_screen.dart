import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final score = gameProvider.score;
    final accuracy = gameProvider.accuracy;
    final combo = gameProvider.combo;
    final elapsedTime = gameProvider.elapsedTime;

    final minutes = elapsedTime ~/ 60000;
    final seconds = (elapsedTime % 60000) ~/ 1000;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final grade = _getGrade(accuracy);

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

              // 제목
              const Text(
                '게임 결과',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 등급 표시
              _buildGradeBadge(grade, context),

              const SizedBox(height: 40),

              // 결과 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _ResultItem(
                          label: '점수',
                          value: score.toString(),
                          icon: Icons.star,
                        ),
                        const Divider(height: 32),
                        _ResultItem(
                          label: '정확도',
                          value: '${accuracy.toStringAsFixed(1)}%',
                          icon: Icons.track_changes,
                        ),
                        const Divider(height: 32),
                        _ResultItem(
                          label: '최고 콤보',
                          value: combo.toString(),
                          icon: Icons.whatshot,
                        ),
                        const Divider(height: 32),
                        _ResultItem(
                          label: '플레이 시간',
                          value: timeString,
                          icon: Icons.timer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 버튼들
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _playAgain(context),
                        icon: const Icon(Icons.replay),
                        label: const Text(
                          '다시 하기',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _shareResult(context),
                        icon: const Icon(Icons.share),
                        label: const Text(
                          '공유하기',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => _returnToMenu(context),
                        icon: const Icon(Icons.home),
                        label: const Text(
                          '메인 메뉴',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeBadge(String grade, BuildContext context) {
    Color gradeColor;
    switch (grade) {
      case 'S':
        gradeColor = Colors.amber;
        break;
      case 'A':
        gradeColor = Colors.green;
        break;
      case 'B':
        gradeColor = Colors.blue;
        break;
      case 'C':
        gradeColor = Colors.orange;
        break;
      default:
        gradeColor = Colors.grey;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: gradeColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          grade,
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: gradeColor,
          ),
        ),
      ),
    );
  }

  String _getGrade(double accuracy) {
    if (accuracy >= 95) return 'S';
    if (accuracy >= 90) return 'A';
    if (accuracy >= 80) return 'B';
    if (accuracy >= 70) return 'C';
    return 'D';
  }

  void _playAgain(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final track = gameProvider.currentTrack;

    if (track != null) {
      gameProvider.startGame(track);
      Navigator.of(context).pushReplacementNamed('/game');
    }
  }

  void _shareResult(BuildContext context) {
    // TODO: 소셜 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 준비 중입니다')),
    );
  }

  void _returnToMenu(BuildContext context) {
    context.read<GameProvider>().returnToMenu();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ResultItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
