import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;

class EyeTrackingProvider extends ChangeNotifier {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;

  // 시선 좌표
  Offset? _gazePosition;
  Offset? get gazePosition => _gazePosition;

  // 캘리브레이션 데이터
  List<CalibrationData> _calibrationPoints = [];
  bool _isCalibrated = false;
  bool get isCalibrated => _isCalibrated;

  // 카메라 상태
  bool _isCameraInitialized = false;
  bool get isCameraInitialized => _isCameraInitialized;

  // 추적 상태
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // 스무딩을 위한 이전 포지션 버퍼
  final List<Offset> _positionBuffer = [];
  static const int _bufferSize = 5;

  EyeTrackingProvider() {
    _initializeFaceDetector();
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
      enableClassification: false,
    );
    _faceDetector = FaceDetector(options: options);
  }

  // 카메라 초기화
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      // 전면 카메라 선택
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;
      notifyListeners();

      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  // 시선 추적 시작
  void startTracking() {
    if (!_isCameraInitialized || _cameraController == null) {
      debugPrint('Camera not initialized');
      return;
    }

    _isTracking = true;
    _cameraController!.startImageStream(_processCameraImage);
    notifyListeners();
  }

  // 시선 추적 중지
  void stopTracking() {
    if (_isTracking && _cameraController != null) {
      _cameraController!.stopImageStream();
      _isTracking = false;
      notifyListeners();
    }
  }

  // 카메라 이미지 처리
  Future<void> _processCameraImage(CameraImage image) async {
    if (_faceDetector == null) return;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        _calculateGazePosition(face);
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }
  }

  // 시선 위치 계산
  void _calculateGazePosition(Face face) {
    // 눈 랜드마크 추출
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];

    if (leftEye == null || rightEye == null) return;

    // 눈 중심점 계산
    final eyeCenter = Offset(
      (leftEye.position.x + rightEye.position.x) / 2,
      (leftEye.position.y + rightEye.position.y) / 2,
    );

    // 머리 회전 각도 고려
    final headEulerY = face.headEulerAngleY ?? 0;
    final headEulerZ = face.headEulerAngleZ ?? 0;

    // 캘리브레이션 적용
    Offset gazePos = _applyCalibration(eyeCenter, headEulerY, headEulerZ);

    // 스무딩 적용
    gazePos = _smoothPosition(gazePos);

    _gazePosition = gazePos;
    notifyListeners();
  }

  // 캘리브레이션 적용
  Offset _applyCalibration(Offset eyeCenter, double headY, double headZ) {
    if (!_isCalibrated || _calibrationPoints.isEmpty) {
      // 기본 변환 (카메라 좌표 → 화면 좌표)
      return Offset(
        eyeCenter.x * 2, // 대략적인 스케일링
        eyeCenter.y * 2,
      );
    }

    // 캘리브레이션 데이터를 사용한 변환
    // TODO: 더 정교한 캘리브레이션 알고리즘 구현
    return eyeCenter;
  }

  // 포지션 스무딩
  Offset _smoothPosition(Offset position) {
    _positionBuffer.add(position);

    if (_positionBuffer.length > _bufferSize) {
      _positionBuffer.removeAt(0);
    }

    // 평균 계산
    double sumX = 0;
    double sumY = 0;
    for (final pos in _positionBuffer) {
      sumX += pos.dx;
      sumY += pos.dy;
    }

    return Offset(
      sumX / _positionBuffer.length,
      sumY / _positionBuffer.length,
    );
  }

  // 캘리브레이션 포인트 추가
  void addCalibrationPoint(Offset screenPoint, Offset eyePoint, double headY, double headZ) {
    _calibrationPoints.add(CalibrationData(
      screenPoint: screenPoint,
      eyePoint: eyePoint,
      headEulerY: headY,
      headEulerZ: headZ,
    ));
  }

  // 캘리브레이션 완료
  void completeCalibration() {
    if (_calibrationPoints.length >= 5) { // 최소 5개 포인트 필요
      _isCalibrated = true;
      notifyListeners();
      debugPrint('Calibration completed with ${_calibrationPoints.length} points');
    }
  }

  // 캘리브레이션 초기화
  void resetCalibration() {
    _calibrationPoints.clear();
    _isCalibrated = false;
    notifyListeners();
  }

  // CameraImage를 InputImage로 변환
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final imageRotation = InputImageRotation.rotation0deg;

      final inputImageFormat = InputImageFormat.yuv420;

      final planeData = image.planes.map((plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      }).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        inputImageData: inputImageData,
      );
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }
}

// 캘리브레이션 데이터 모델
class CalibrationData {
  final Offset screenPoint;
  final Offset eyePoint;
  final double headEulerY;
  final double headEulerZ;

  CalibrationData({
    required this.screenPoint,
    required this.eyePoint,
    required this.headEulerY,
    required this.headEulerZ,
  });
}
