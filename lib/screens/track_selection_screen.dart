import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/track.dart';
import '../services/track_repository.dart';
import '../providers/game_provider.dart';
import '../providers/eye_tracking_provider.dart';
import 'calibration_screen.dart';

class TrackSelectionScreen extends StatefulWidget {
  const TrackSelectionScreen({super.key});

  @override
  State<TrackSelectionScreen> createState() => _TrackSelectionScreenState();
}

class _TrackSelectionScreenState extends State<TrackSelectionScreen> {
  final TrackRepository _trackRepository = TrackRepository();
  late List<Track> _tracks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _trackRepository.initialize(size);

      final gameProvider = context.read<GameProvider>();
      setState(() {
        _tracks = _trackRepository.getTracksByDifficulty(gameProvider.difficulty);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('트랙 선택 - ${gameProvider.difficulty.displayName}'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          // 난이도 변경 버튼
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showDifficultyDialog,
          ),
        ],
      ),
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
        child: _tracks == null
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tracks.length,
                itemBuilder: (context, index) {
                  final track = _tracks[index];
                  return _TrackCard(
                    track: track,
                    onTap: () => _selectTrack(track),
                  );
                },
              ),
      ),
    );
  }

  void _selectTrack(Track track) async {
    final eyeTracking = context.read<EyeTrackingProvider>();
    final gameProvider = context.read<GameProvider>();

    // 카메라 초기화
    if (!eyeTracking.isCameraInitialized) {
      await eyeTracking.initializeCamera();
    }

    // 캘리브레이션 확인
    if (!eyeTracking.isCalibrated) {
      if (mounted) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const CalibrationScreen()),
        );

        // 캘리브레이션 취소 시 리턴
        if (result != true && mounted) return;
      }
    }

    // 게임 시작
    if (mounted) {
      gameProvider.startGame(track);
      Navigator.of(context).pushNamed('/game');
    }
  }

  void _showDifficultyDialog() {
    final gameProvider = context.read<GameProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('난이도 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((difficulty) {
            return ListTile(
              title: Text(difficulty.displayName),
              subtitle: Text(
                '트랙 폭: ${difficulty.trackWidth.toInt()}px\n기본 속도: ${difficulty.baseSpeed}x',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              leading: Radio<Difficulty>(
                value: difficulty,
                groupValue: gameProvider.difficulty,
                onChanged: (value) {
                  if (value != null) {
                    gameProvider.setDifficulty(value);
                    Navigator.pop(context);

                    // 트랙 리스트 업데이트
                    setState(() {
                      _tracks = _trackRepository.getTracksByDifficulty(value);
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;

  const _TrackCard({
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 트랙 미리보기
              _TrackPreview(track: track),

              const SizedBox(width: 16),

              // 트랙 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.difficulty.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getDifficultyColor(track.difficulty),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.route,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${track.points.length} 포인트',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표 아이콘
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }
}

class _TrackPreview extends StatelessWidget {
  final Track track;

  const _TrackPreview({required this.track});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _TrackPreviewPainter(track: track),
      ),
    );
  }
}

class _TrackPreviewPainter extends CustomPainter {
  final Track track;

  _TrackPreviewPainter({required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    if (track.points.length < 2) return;

    // 트랙 포인트를 미리보기 크기에 맞게 스케일링
    final bounds = _calculateBounds();
    final scaleX = size.width * 0.8 / bounds.width;
    final scaleY = size.height * 0.8 / bounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final offsetY = (size.height - bounds.height * scale) / 2 - bounds.top * scale;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final firstPoint = track.points.first;
    path.moveTo(
      firstPoint.dx * scale + offsetX,
      firstPoint.dy * scale + offsetY,
    );

    for (int i = 1; i < track.points.length; i++) {
      final point = track.points[i];
      path.lineTo(
        point.dx * scale + offsetX,
        point.dy * scale + offsetY,
      );
    }

    canvas.drawPath(path, paint);

    // 시작점 표시
    final startPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        firstPoint.dx * scale + offsetX,
        firstPoint.dy * scale + offsetY,
      ),
      3,
      startPaint,
    );

    // 끝점 표시
    final endPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final lastPoint = track.points.last;
    canvas.drawCircle(
      Offset(
        lastPoint.dx * scale + offsetX,
        lastPoint.dy * scale + offsetY,
      ),
      3,
      endPaint,
    );
  }

  Rect _calculateBounds() {
    double minX = track.points.first.dx;
    double maxX = track.points.first.dx;
    double minY = track.points.first.dy;
    double maxY = track.points.first.dy;

    for (final point in track.points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool shouldRepaint(_TrackPreviewPainter oldDelegate) {
    return oldDelegate.track != track;
  }
}
