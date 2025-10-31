import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eye_tracking_provider.dart';
import 'dart:async';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int _currentPointIndex = 0;
  bool _isCollecting = false;
  Timer? _collectionTimer;

  final List<Offset> _calibrationPositions = [];

  @override
  void initState() {
    super.initState();
    _setupCalibrationPoints();

    // 시선 추적 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EyeTrackingProvider>().startTracking();
    });
  }

  void _setupCalibrationPoints() {
    // 화면의 9개 포인트 (3x3 그리드)
    // 나중에 화면 크기에 맞춰 계산
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_calibrationPositions.isEmpty) {
      final size = MediaQuery.of(context).size;
      final padding = size.width * 0.15;

      _calibrationPositions.addAll([
        Offset(padding, padding), // 좌상
        Offset(size.width / 2, padding), // 중상
        Offset(size.width - padding, padding), // 우상
        Offset(padding, size.height / 2), // 좌중
        Offset(size.width / 2, size.height / 2), // 중앙
        Offset(size.width - padding, size.height / 2), // 우중
        Offset(padding, size.height - padding), // 좌하
        Offset(size.width / 2, size.height - padding), // 중하
        Offset(size.width - padding, size.height - padding), // 우하
      ]);
    }
  }

  @override
  void dispose() {
    _collectionTimer?.cancel();
    super.dispose();
  }

  void _startCollection() {
    setState(() {
      _isCollecting = true;
    });

    // 2초간 데이터 수집
    _collectionTimer = Timer(const Duration(seconds: 2), () {
      _completePoint();
    });
  }

  void _completePoint() {
    final eyeTracking = context.read<EyeTrackingProvider>();
    final screenPoint = _calibrationPositions[_currentPointIndex];
    final gazePoint = eyeTracking.gazePosition ?? Offset.zero;

    // 캘리브레이션 포인트 추가
    eyeTracking.addCalibrationPoint(screenPoint, gazePoint, 0, 0);

    setState(() {
      _isCollecting = false;
      _currentPointIndex++;
    });

    // 모든 포인트 완료
    if (_currentPointIndex >= _calibrationPositions.length) {
      eyeTracking.completeCalibration();
      eyeTracking.stopTracking();

      // 완료 화면으로 이동
      Navigator.of(context).pop();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('캘리브레이션 완료'),
        content: const Text('시선 추적이 준비되었습니다!\n이제 게임을 시작할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(true); // 캘리브레이션 화면 닫기 (true 반환)
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eyeTracking = context.watch<EyeTrackingProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰 (선택사항)
          // if (eyeTracking.isCameraInitialized)
          //   CameraPreview(eyeTracking.cameraController!),

          // 캘리브레이션 포인트들
          if (_calibrationPositions.isNotEmpty)
            ...List.generate(
              _calibrationPositions.length,
              (index) => _buildCalibrationPoint(index),
            ),

          // 진행 상황 표시
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    '캘리브레이션',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_currentPointIndex + 1} / ${_calibrationPositions.length}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _currentPointIndex / _calibrationPositions.length,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isCollecting
                        ? '포인트를 계속 응시하세요...'
                        : '포인트를 응시한 후 탭하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 시선 포인터 (디버깅용)
          if (eyeTracking.gazePosition != null)
            Positioned(
              left: eyeTracking.gazePosition!.dx - 10,
              top: eyeTracking.gazePosition!.dy - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2),
                ),
              ),
            ),

          // 취소 버튼
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () {
                  context.read<EyeTrackingProvider>().stopTracking();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationPoint(int index) {
    final isActive = index == _currentPointIndex;
    final isCompleted = index < _currentPointIndex;
    final position = _calibrationPositions[index];

    return Positioned(
      left: position.dx - 30,
      top: position.dy - 30,
      child: GestureDetector(
        onTap: isActive && !_isCollecting ? _startCollection : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withOpacity(0.5)
                : isActive
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              width: isActive ? 3 : 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 32)
                : _isCollecting && isActive
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
