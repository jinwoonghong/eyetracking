import 'dart:convert';
import 'game_state.dart';

class GameResult {
  final String trackId;
  final int score;
  final double accuracy;
  final int maxCombo;
  final int elapsedTime; // milliseconds
  final Difficulty difficulty;
  final GameTheme theme;
  final DateTime timestamp;

  GameResult({
    required this.trackId,
    required this.score,
    required this.accuracy,
    required this.maxCombo,
    required this.elapsedTime,
    required this.difficulty,
    required this.theme,
    required this.timestamp,
  });

  // 플레이 시간 (포맷팅)
  String get formattedTime {
    final seconds = elapsedTime ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 등급 계산
  String get grade {
    if (accuracy >= 95) return 'S';
    if (accuracy >= 90) return 'A';
    if (accuracy >= 80) return 'B';
    if (accuracy >= 70) return 'C';
    return 'D';
  }

  // JSON 변환
  String toJson() {
    final map = {
      'trackId': trackId,
      'score': score,
      'accuracy': accuracy,
      'maxCombo': maxCombo,
      'elapsedTime': elapsedTime,
      'difficulty': difficulty.index,
      'theme': theme.index,
      'timestamp': timestamp.toIso8601String(),
    };
    return jsonEncode(map);
  }

  factory GameResult.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return GameResult(
      trackId: map['trackId'],
      score: map['score'],
      accuracy: map['accuracy'],
      maxCombo: map['maxCombo'],
      elapsedTime: map['elapsedTime'],
      difficulty: Difficulty.values[map['difficulty']],
      theme: GameTheme.values[map['theme']],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
