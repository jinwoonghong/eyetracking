import 'dart:ui';
import 'game_state.dart';

class Track {
  final String id;
  final String name;
  final List<Offset> points;
  final Difficulty difficulty;
  final GameTheme theme;
  final double totalLength;

  Track({
    required this.id,
    required this.name,
    required this.points,
    required this.difficulty,
    required this.theme,
  }) : totalLength = _calculateTotalLength(points);

  // 트랙의 총 길이 계산
  static double _calculateTotalLength(List<Offset> points) {
    if (points.length < 2) return 0;

    double length = 0;
    for (int i = 0; i < points.length - 1; i++) {
      length += (points[i + 1] - points[i]).distance;
    }
    return length;
  }

  // 진행도(0~1)에 따른 위치 가져오기
  Offset getPositionAt(double progress) {
    if (points.isEmpty) return Offset.zero;
    if (progress <= 0) return points.first;
    if (progress >= 1) return points.last;

    final targetDistance = totalLength * progress;
    double accumulatedDistance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final segmentLength = (points[i + 1] - points[i]).distance;

      if (accumulatedDistance + segmentLength >= targetDistance) {
        final remainingDistance = targetDistance - accumulatedDistance;
        final t = remainingDistance / segmentLength;

        return Offset(
          points[i].dx + (points[i + 1].dx - points[i].dx) * t,
          points[i].dy + (points[i + 1].dy - points[i].dy) * t,
        );
      }

      accumulatedDistance += segmentLength;
    }

    return points.last;
  }

  // 특정 위치가 트랙 위에 있는지 확인
  bool isPointOnTrack(Offset point, double tolerance) {
    for (int i = 0; i < points.length - 1; i++) {
      final distance = _distanceToLineSegment(point, points[i], points[i + 1]);
      if (distance <= tolerance) {
        return true;
      }
    }
    return false;
  }

  // 점에서 선분까지의 거리 계산
  static double _distanceToLineSegment(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;
    final lengthSquared = dx * dx + dy * dy;

    if (lengthSquared == 0) {
      return (point - lineStart).distance;
    }

    final t = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) / lengthSquared;
    final tClamped = t.clamp(0.0, 1.0);

    final projection = Offset(
      lineStart.dx + tClamped * dx,
      lineStart.dy + tClamped * dy,
    );

    return (point - projection).distance;
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'difficulty': difficulty.index,
      'theme': theme.index,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      points: (json['points'] as List)
          .map((p) => Offset(p['x'], p['y']))
          .toList(),
      difficulty: Difficulty.values[json['difficulty']],
      theme: GameTheme.values[json['theme']],
    );
  }

  // 샘플 트랙 생성
  static Track createSampleTrack({
    required String id,
    required String name,
    required Difficulty difficulty,
    required GameTheme theme,
    required Size screenSize,
  }) {
    final points = _generateTrackPoints(difficulty, screenSize);
    return Track(
      id: id,
      name: name,
      points: points,
      difficulty: difficulty,
      theme: theme,
    );
  }

  // 난이도에 따른 트랙 포인트 생성
  static List<Offset> _generateTrackPoints(Difficulty difficulty, Size screenSize) {
    final points = <Offset>[];
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    switch (difficulty) {
      case Difficulty.beginner:
        // 간단한 S자 곡선
        points.add(Offset(centerX, screenSize.height * 0.2));
        points.add(Offset(centerX + 100, screenSize.height * 0.35));
        points.add(Offset(centerX, screenSize.height * 0.5));
        points.add(Offset(centerX - 100, screenSize.height * 0.65));
        points.add(Offset(centerX, screenSize.height * 0.8));
        break;

      case Difficulty.intermediate:
        // 복잡한 곡선
        points.add(Offset(centerX, screenSize.height * 0.15));
        points.add(Offset(centerX + 120, screenSize.height * 0.25));
        points.add(Offset(centerX + 80, screenSize.height * 0.4));
        points.add(Offset(centerX - 80, screenSize.height * 0.55));
        points.add(Offset(centerX - 120, screenSize.height * 0.7));
        points.add(Offset(centerX, screenSize.height * 0.85));
        break;

      case Difficulty.advanced:
        // 매우 복잡한 패턴
        points.add(Offset(centerX, screenSize.height * 0.1));
        points.add(Offset(centerX + 100, screenSize.height * 0.2));
        points.add(Offset(centerX + 140, screenSize.height * 0.3));
        points.add(Offset(centerX + 80, screenSize.height * 0.4));
        points.add(Offset(centerX, screenSize.height * 0.5));
        points.add(Offset(centerX - 80, screenSize.height * 0.6));
        points.add(Offset(centerX - 140, screenSize.height * 0.7));
        points.add(Offset(centerX - 100, screenSize.height * 0.8));
        points.add(Offset(centerX, screenSize.height * 0.9));
        break;
    }

    return points;
  }
}
