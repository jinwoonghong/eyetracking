import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/track.dart';
import '../models/game_state.dart';

class TrackPainter extends CustomPainter {
  final Track track;
  final double progress;
  final double trackWidth;
  final GameTheme theme;
  final bool isFeverMode;
  final Animation<double>? feverAnimation;

  TrackPainter({
    required this.track,
    required this.progress,
    required this.trackWidth,
    required this.theme,
    this.isFeverMode = false,
    this.feverAnimation,
  }) : super(repaint: feverAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // 트랙 그리기
    _drawTrack(canvas);

    // 진행 포인터 그리기
    _drawProgressPointer(canvas);

    // 별/포인트 그리기
    _drawStars(canvas);
  }

  void _drawTrack(Canvas canvas) {
    if (track.points.length < 2) return;

    // 트랙 배경 (어두운 선)
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = trackWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawPath(canvas, backgroundPaint, 1.0);

    // 완료된 트랙 (밝은 선)
    final completedPaint = Paint()
      ..strokeWidth = trackWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 테마별 색상
    if (isFeverMode && feverAnimation != null) {
      // 피버 모드: 애니메이션 색상
      final hue = (feverAnimation!.value * 360).toDouble();
      completedPaint.shader = ui.Gradient.linear(
        track.points.first,
        track.points.last,
        [
          HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
          HSVColor.fromAHSV(1.0, (hue + 60) % 360, 1.0, 1.0).toColor(),
        ],
      );
    } else {
      // 일반 모드: 테마별 그라데이션
      completedPaint.shader = _getThemeGradient();
    }

    _drawPath(canvas, completedPaint, progress);
  }

  void _drawPath(Canvas canvas, Paint paint, double progressLimit) {
    final path = Path();
    path.moveTo(track.points.first.dx, track.points.first.dy);

    if (progressLimit >= 1.0) {
      // 전체 경로 그리기
      for (int i = 1; i < track.points.length; i++) {
        path.lineTo(track.points[i].dx, track.points[i].dy);
      }
    } else {
      // 진행도까지만 그리기
      final targetPosition = track.getPositionAt(progressLimit);
      double accumulatedDistance = 0;
      final totalDistance = track.totalLength;

      for (int i = 0; i < track.points.length - 1; i++) {
        final segmentLength = (track.points[i + 1] - track.points[i]).distance;

        if (accumulatedDistance + segmentLength >= totalDistance * progressLimit) {
          // 이 세그먼트에서 멈춤
          path.lineTo(targetPosition.dx, targetPosition.dy);
          break;
        } else {
          path.lineTo(track.points[i + 1].dx, track.points[i + 1].dy);
        }

        accumulatedDistance += segmentLength;
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawProgressPointer(Canvas canvas) {
    final position = track.getPositionAt(progress);

    // 외부 원 (글로우 효과)
    final glowPaint = Paint()
      ..color = _getThemeColor().withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(position, 25, glowPaint);

    // 내부 원
    final pointerPaint = Paint()
      ..color = _getThemeColor()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 15, pointerPaint);

    // 중심 점
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 5, centerPaint);
  }

  void _drawStars(Canvas canvas) {
    // 트랙의 주요 포인트에 별 그리기
    for (int i = 0; i < track.points.length; i++) {
      final point = track.points[i];
      final pointProgress = _getProgressAtPointIndex(i);

      if (pointProgress <= progress) {
        // 완료된 별 (밝게)
        _drawStar(canvas, point, 12, _getThemeColor());
      } else {
        // 미완료 별 (어둡게)
        _drawStar(canvas, point, 10, Colors.white.withOpacity(0.3));
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 5;
    const angle = math.pi * 2 / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? size : size / 2;
      final x = center.dx + radius * math.cos(i * angle / 2 - math.pi / 2);
      final y = center.dy + radius * math.sin(i * angle / 2 - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  double _getProgressAtPointIndex(int index) {
    if (track.points.isEmpty) return 0;
    if (index >= track.points.length) return 1.0;

    double accumulatedDistance = 0;
    for (int i = 0; i < index; i++) {
      if (i < track.points.length - 1) {
        accumulatedDistance += (track.points[i + 1] - track.points[i]).distance;
      }
    }

    return accumulatedDistance / track.totalLength;
  }

  ui.Gradient _getThemeGradient() {
    List<Color> colors;

    switch (theme) {
      case GameTheme.constellation:
        colors = [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
        ];
        break;
      case GameTheme.jungle:
        colors = [
          const Color(0xFF10B981),
          const Color(0xFF34D399),
          const Color(0xFF6EE7B7),
        ];
        break;
      case GameTheme.cityDrive:
        colors = [
          const Color(0xFFF59E0B),
          const Color(0xFFEF4444),
          const Color(0xFFEC4899),
        ];
        break;
      case GameTheme.underwater:
        colors = [
          const Color(0xFF06B6D4),
          const Color(0xFF3B82F6),
          const Color(0xFF8B5CF6),
        ];
        break;
    }

    return ui.Gradient.linear(
      track.points.first,
      track.points.last,
      colors,
    );
  }

  Color _getThemeColor() {
    switch (theme) {
      case GameTheme.constellation:
        return const Color(0xFF6366F1);
      case GameTheme.jungle:
        return const Color(0xFF10B981);
      case GameTheme.cityDrive:
        return const Color(0xFFF59E0B);
      case GameTheme.underwater:
        return const Color(0xFF06B6D4);
    }
  }

  @override
  bool shouldRepaint(TrackPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isFeverMode != isFeverMode ||
        oldDelegate.track != track;
  }
}
