import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/game_result.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  // 게임 결과 공유
  Future<void> shareGameResult(GameResult result, BuildContext context) async {
    final text = _generateShareText(result);

    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        text,
        subject: 'Star Tracer 게임 결과',
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  // 공유 텍스트 생성
  String _generateShareText(GameResult result) {
    final emoji = _getGradeEmoji(result.grade);

    return '''
🌟 Star Tracer 게임 결과 $emoji

📊 점수: ${result.score}점
🎯 정확도: ${result.accuracy.toStringAsFixed(1)}%
🔥 최고 콤보: ${result.maxCombo}
⏱️ 플레이 시간: ${result.formattedTime}
🏆 등급: ${result.grade}

난이도: ${result.difficulty.displayName}
테마: ${result.theme.displayName}

#StarTracer #시선추적게임 #눈운동
    ''';
  }

  String _getGradeEmoji(String grade) {
    switch (grade) {
      case 'S':
        return '🏆';
      case 'A':
        return '🥇';
      case 'B':
        return '🥈';
      case 'C':
        return '🥉';
      default:
        return '⭐';
    }
  }

  // 리더보드 공유
  Future<void> shareLeaderboard(List<GameResult> topScores) async {
    final text = _generateLeaderboardText(topScores);

    try {
      await Share.share(
        text,
        subject: 'Star Tracer 리더보드',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  String _generateLeaderboardText(List<GameResult> topScores) {
    final buffer = StringBuffer();
    buffer.writeln('🏆 Star Tracer 리더보드 🏆\n');

    for (int i = 0; i < topScores.length && i < 10; i++) {
      final result = topScores[i];
      final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}.';
      buffer.writeln('$medal ${result.score}점 (${result.grade}등급) - ${result.accuracy.toStringAsFixed(0)}%');
    }

    buffer.writeln('\n#StarTracer #시선추적게임');
    return buffer.toString();
  }

  // 초대 공유
  Future<void> shareInvite() async {
    const text = '''
👁️ Star Tracer - 시선으로 즐기는 게임!

눈으로 별자리를 연결하는 신개념 웰니스 게임
🎯 시선 추적 기술
🌟 15개의 다양한 트랙
🔥 피버 모드
🏆 글로벌 리더보드

지금 바로 플레이하고 눈 건강도 챙기세요!

#StarTracer #시선추적 #눈운동게임
    ''';

    try {
      await Share.share(text);
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }
}
