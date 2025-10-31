import 'dart:ui';
import '../models/track.dart';
import '../models/game_state.dart';

class TrackRepository {
  static final TrackRepository _instance = TrackRepository._internal();
  factory TrackRepository() => _instance;
  TrackRepository._internal();

  // 모든 트랙 리스트
  final List<Track> _tracks = [];

  // 초기화
  void initialize(Size screenSize) {
    if (_tracks.isNotEmpty) return; // 이미 초기화됨

    _tracks.addAll(_generateBeginnerTracks(screenSize));
    _tracks.addAll(_generateIntermediateTracks(screenSize));
    _tracks.addAll(_generateAdvancedTracks(screenSize));
  }

  // 난이도별 트랙 가져오기
  List<Track> getTracksByDifficulty(Difficulty difficulty) {
    return _tracks.where((track) => track.difficulty == difficulty).toList();
  }

  // ID로 트랙 가져오기
  Track? getTrackById(String id) {
    try {
      return _tracks.firstWhere((track) => track.id == id);
    } catch (e) {
      return null;
    }
  }

  // 모든 트랙 가져오기
  List<Track> getAllTracks() => List.unmodifiable(_tracks);

  // ========================================
  // 초급 트랙 생성 (5개)
  // ========================================
  List<Track> _generateBeginnerTracks(Size screenSize) {
    final w = screenSize.width;
    final h = screenSize.height;

    return [
      // 1. 간단한 직선 S자
      Track(
        id: 'beginner_1',
        name: '별빛 산책',
        difficulty: Difficulty.beginner,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.5, h * 0.3),
          Offset(w * 0.7, h * 0.45),
          Offset(w * 0.5, h * 0.6),
          Offset(w * 0.3, h * 0.75),
          Offset(w * 0.5, h * 0.9),
        ],
      ),

      // 2. 부드러운 곡선
      Track(
        id: 'beginner_2',
        name: '달빛 곡선',
        difficulty: Difficulty.beginner,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.3, h * 0.2),
          Offset(w * 0.4, h * 0.35),
          Offset(w * 0.6, h * 0.5),
          Offset(w * 0.7, h * 0.65),
          Offset(w * 0.6, h * 0.8),
        ],
      ),

      // 3. 완만한 지그재그
      Track(
        id: 'beginner_3',
        name: '반딧불 길',
        difficulty: Difficulty.beginner,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.2, h * 0.2),
          Offset(w * 0.4, h * 0.3),
          Offset(w * 0.35, h * 0.45),
          Offset(w * 0.55, h * 0.6),
          Offset(w * 0.5, h * 0.75),
          Offset(w * 0.7, h * 0.85),
        ],
      ),

      // 4. 대각선 웨이브
      Track(
        id: 'beginner_4',
        name: '유성우',
        difficulty: Difficulty.beginner,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.2, h * 0.15),
          Offset(w * 0.35, h * 0.3),
          Offset(w * 0.45, h * 0.4),
          Offset(w * 0.55, h * 0.55),
          Offset(w * 0.65, h * 0.7),
          Offset(w * 0.8, h * 0.85),
        ],
      ),

      // 5. 원형 궤도
      Track(
        id: 'beginner_5',
        name: '행성 궤도',
        difficulty: Difficulty.beginner,
        theme: GameTheme.constellation,
        points: _generateCircularPath(
          center: Offset(w * 0.5, h * 0.5),
          radius: w * 0.3,
          points: 12,
        ),
      ),
    ];
  }

  // ========================================
  // 중급 트랙 생성 (5개)
  // ========================================
  List<Track> _generateIntermediateTracks(Size screenSize) {
    final w = screenSize.width;
    final h = screenSize.height;

    return [
      // 1. 복잡한 S자 곡선
      Track(
        id: 'intermediate_1',
        name: '은하수 항로',
        difficulty: Difficulty.intermediate,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.2, h * 0.1),
          Offset(w * 0.4, h * 0.2),
          Offset(w * 0.7, h * 0.25),
          Offset(w * 0.8, h * 0.4),
          Offset(w * 0.6, h * 0.55),
          Offset(w * 0.3, h * 0.6),
          Offset(w * 0.2, h * 0.75),
          Offset(w * 0.5, h * 0.9),
        ],
      ),

      // 2. 나선형
      Track(
        id: 'intermediate_2',
        name: '소용돌이 성운',
        difficulty: Difficulty.intermediate,
        theme: GameTheme.constellation,
        points: _generateSpiralPath(
          center: Offset(w * 0.5, h * 0.5),
          startRadius: w * 0.05,
          endRadius: w * 0.4,
          revolutions: 2.5,
          points: 20,
        ),
      ),

      // 3. 급격한 지그재그
      Track(
        id: 'intermediate_3',
        name: '천둥 번개',
        difficulty: Difficulty.intermediate,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.5, h * 0.1),
          Offset(w * 0.7, h * 0.25),
          Offset(w * 0.4, h * 0.35),
          Offset(w * 0.75, h * 0.5),
          Offset(w * 0.35, h * 0.6),
          Offset(w * 0.7, h * 0.75),
          Offset(w * 0.5, h * 0.9),
        ],
      ),

      // 4. 무한대 기호 (∞)
      Track(
        id: 'intermediate_4',
        name: '무한 루프',
        difficulty: Difficulty.intermediate,
        theme: GameTheme.constellation,
        points: _generateInfinityPath(
          center: Offset(w * 0.5, h * 0.5),
          width: w * 0.6,
          height: h * 0.3,
          points: 30,
        ),
      ),

      // 5. 별자리 연결 (W자 형태)
      Track(
        id: 'intermediate_5',
        name: '카시오페이아',
        difficulty: Difficulty.intermediate,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.15, h * 0.3),
          Offset(w * 0.3, h * 0.5),
          Offset(w * 0.5, h * 0.25),
          Offset(w * 0.7, h * 0.5),
          Offset(w * 0.85, h * 0.3),
        ],
      ),
    ];
  }

  // ========================================
  // 고급 트랙 생성 (5개)
  // ========================================
  List<Track> _generateAdvancedTracks(Size screenSize) {
    final w = screenSize.width;
    final h = screenSize.height;

    return [
      // 1. 극도로 복잡한 곡선
      Track(
        id: 'advanced_1',
        name: '블랙홀 회전',
        difficulty: Difficulty.advanced,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.1, h * 0.15),
          Offset(w * 0.3, h * 0.2),
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.75, h * 0.25),
          Offset(w * 0.85, h * 0.4),
          Offset(w * 0.7, h * 0.55),
          Offset(w * 0.45, h * 0.5),
          Offset(w * 0.25, h * 0.6),
          Offset(w * 0.15, h * 0.75),
          Offset(w * 0.4, h * 0.8),
          Offset(w * 0.65, h * 0.85),
          Offset(w * 0.85, h * 0.9),
        ],
      ),

      // 2. 이중 나선
      Track(
        id: 'advanced_2',
        name: 'DNA 이중나선',
        difficulty: Difficulty.advanced,
        theme: GameTheme.constellation,
        points: _generateDoubleHelixPath(
          startY: h * 0.1,
          endY: h * 0.9,
          centerX: w * 0.5,
          amplitude: w * 0.25,
          frequency: 3,
          points: 25,
        ),
      ),

      // 3. 극도의 지그재그 (번개)
      Track(
        id: 'advanced_3',
        name: '초신성 폭발',
        difficulty: Difficulty.advanced,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.5, h * 0.05),
          Offset(w * 0.8, h * 0.15),
          Offset(w * 0.3, h * 0.25),
          Offset(w * 0.85, h * 0.35),
          Offset(w * 0.2, h * 0.45),
          Offset(w * 0.75, h * 0.55),
          Offset(w * 0.25, h * 0.65),
          Offset(w * 0.8, h * 0.75),
          Offset(w * 0.35, h * 0.85),
          Offset(w * 0.5, h * 0.95),
        ],
      ),

      // 4. 복잡한 별자리 (용자리)
      Track(
        id: 'advanced_4',
        name: '드래곤의 비행',
        difficulty: Difficulty.advanced,
        theme: GameTheme.constellation,
        points: [
          Offset(w * 0.1, h * 0.5),
          Offset(w * 0.2, h * 0.3),
          Offset(w * 0.35, h * 0.2),
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.65, h * 0.25),
          Offset(w * 0.75, h * 0.4),
          Offset(w * 0.7, h * 0.6),
          Offset(w * 0.55, h * 0.7),
          Offset(w * 0.4, h * 0.75),
          Offset(w * 0.3, h * 0.85),
          Offset(w * 0.5, h * 0.9),
        ],
      ),

      // 5. 5각 별 (펜타그램)
      Track(
        id: 'advanced_5',
        name: '오각 별',
        difficulty: Difficulty.advanced,
        theme: GameTheme.constellation,
        points: _generateStarPath(
          center: Offset(w * 0.5, h * 0.5),
          outerRadius: w * 0.35,
          innerRadius: w * 0.15,
          points: 5,
        ),
      ),
    ];
  }

  // ========================================
  // 유틸리티 함수 - 특수 경로 생성
  // ========================================

  // 원형 경로
  List<Offset> _generateCircularPath({
    required Offset center,
    required double radius,
    required int points,
    double startAngle = 0,
  }) {
    final result = <Offset>[];
    for (int i = 0; i < points; i++) {
      final angle = startAngle + (i * 2 * 3.14159 / points);
      result.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    return result;
  }

  // 나선형 경로
  List<Offset> _generateSpiralPath({
    required Offset center,
    required double startRadius,
    required double endRadius,
    required double revolutions,
    required int points,
  }) {
    final result = <Offset>[];
    for (int i = 0; i < points; i++) {
      final t = i / (points - 1);
      final angle = revolutions * 2 * 3.14159 * t;
      final radius = startRadius + (endRadius - startRadius) * t;
      result.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }
    return result;
  }

  // 무한대 기호 경로
  List<Offset> _generateInfinityPath({
    required Offset center,
    required double width,
    required double height,
    required int points,
  }) {
    final result = <Offset>[];
    for (int i = 0; i < points; i++) {
      final t = i / points * 2 * 3.14159;
      final x = center.dx + (width / 2) * sin(t);
      final y = center.dy + (height / 2) * sin(t) * cos(t);
      result.add(Offset(x, y));
    }
    return result;
  }

  // 이중 나선 경로
  List<Offset> _generateDoubleHelixPath({
    required double startY,
    required double endY,
    required double centerX,
    required double amplitude,
    required double frequency,
    required int points,
  }) {
    final result = <Offset>[];
    for (int i = 0; i < points; i++) {
      final t = i / (points - 1);
      final y = startY + (endY - startY) * t;
      final angle = frequency * 2 * 3.14159 * t;
      final x = centerX + amplitude * sin(angle);
      result.add(Offset(x, y));
    }
    return result;
  }

  // 별 모양 경로
  List<Offset> _generateStarPath({
    required Offset center,
    required double outerRadius,
    required double innerRadius,
    required int points,
  }) {
    final result = <Offset>[];
    final totalPoints = points * 2;

    for (int i = 0; i < totalPoints; i++) {
      final angle = (i * 2 * 3.14159 / totalPoints) - 3.14159 / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      result.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }

    // 마지막 점을 첫 점으로 연결하여 닫기
    if (result.isNotEmpty) {
      result.add(result.first);
    }

    return result;
  }

  // 삼각함수 헬퍼
  double cos(double angle) => angle.cos();
  double sin(double angle) => angle.sin();
}

// double extension
extension TrigDouble on double {
  double cos() {
    // 테일러 급수를 이용한 cos 근사
    final x = this % (2 * 3.14159);
    var result = 1.0;
    var term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double sin() {
    // cos(x - π/2) = sin(x)
    return (this - 3.14159 / 2).cos();
  }
}
