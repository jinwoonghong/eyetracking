import 'package:flutter/material.dart';

class GameHUD extends StatelessWidget {
  final int score;
  final int combo;
  final double accuracy;
  final double progress;
  final double feverGauge;
  final bool isFeverMode;
  final int elapsedTime;

  const GameHUD({
    super.key,
    required this.score,
    required this.combo,
    required this.accuracy,
    required this.progress,
    required this.feverGauge,
    required this.isFeverMode,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 점수, 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 점수
                _buildStatCard(
                  icon: Icons.star,
                  label: '점수',
                  value: score.toString(),
                  color: Colors.amber,
                ),

                // 시간
                _buildTimeCard(),
              ],
            ),

            const SizedBox(height: 12),

            // 진행 바
            _buildProgressBar(context),

            const SizedBox(height: 12),

            // 콤보 & 정확도
            Row(
              children: [
                if (combo > 0)
                  _buildComboIndicator(context),

                const Spacer(),

                _buildAccuracyIndicator(),
              ],
            ),

            const Spacer(),

            // 피버 게이지 (하단)
            _buildFeverGauge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    final seconds = elapsedTime ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(
            timeString,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '진행도',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComboIndicator(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.red,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.whatshot, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${combo}x COMBO',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccuracyIndicator() {
    Color accuracyColor;
    if (accuracy >= 90) {
      accuracyColor = Colors.green;
    } else if (accuracy >= 80) {
      accuracyColor = Colors.yellow;
    } else if (accuracy >= 70) {
      accuracyColor = Colors.orange;
    } else {
      accuracyColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accuracyColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.track_changes, color: accuracyColor, size: 16),
          const SizedBox(width: 4),
          Text(
            '${accuracy.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: accuracyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeverGauge(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on,
              color: isFeverMode ? Colors.yellow : Colors.white.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isFeverMode ? 'FEVER MODE!' : 'FEVER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isFeverMode ? Colors.yellow : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFeverMode
                  ? Colors.yellow
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: feverGauge / 100,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFeverMode
                        ? Colors.yellow
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (isFeverMode)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.yellow.withOpacity(0.3),
                              Colors.orange.withOpacity(0.3),
                              Colors.yellow.withOpacity(0.3),
                            ],
                            stops: [value - 0.3, value, value + 0.3],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
