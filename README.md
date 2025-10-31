# 👁️ Star Tracer

시선으로 별자리를 연결하는 웰니스 게임

## 📖 프로젝트 개요

Star Tracer는 사용자의 '시선'을 컨트롤러로 사용하여, 화면에 제시된 트랙을 따라가는 혁신적인 모바일 게임입니다. 부드러운 안구 운동(Smooth Pursuit)을 유도하여 눈 피로도 감소 및 집중력 강화를 목표로 합니다.

## ✨ 주요 기능

### 🎮 게임 플레이
- **시선 추적 기반**: ML Kit을 활용한 실시간 시선 추적
- **다양한 난이도**: 초급, 중급, 고급 3단계
- **테마 시스템**: 별자리, 정글, 도시 드라이브, 물속 탐험
- **콤보 & 피버 모드**: 연속 성공 시 특수 효과 및 점수 배율 증가
- **페널티 & 보상**: 트랙 이탈 시 페널티, 유지 시 보상

### 📊 기능 상세
- **캘리브레이션**: 9포인트 캘리브레이션으로 정확한 시선 추적
- **실시간 피드백**: 시선 포인터, HUD, 정확도 표시
- **기록 관리**: 최고 점수, 정확도, 콤보 기록 저장
- **소셜 공유**: 게임 결과 공유 기능 (준비 중)

## 🛠️ 기술 스택

### Frontend
- **Flutter 3.0+**: 크로스 플랫폼 프레임워크
- **Dart 3.0+**: 프로그래밍 언어

### 시선 추적
- **ML Kit Face Detection**: Google ML Kit 얼굴 및 눈 랜드마크 감지
- **Camera Plugin**: 카메라 접근 및 이미지 스트림 처리

### 상태 관리
- **Provider**: 앱 전역 상태 관리

### 로컬 저장
- **SharedPreferences**: 게임 기록 및 설정 저장

### 그래픽
- **CustomPainter**: Canvas 기반 트랙 렌더링
- **Animations**: Flutter 애니메이션 시스템

## 📁 프로젝트 구조

```
star_tracer/
├── lib/
│   ├── main.dart                    # 앱 진입점
│   ├── models/                      # 데이터 모델
│   │   ├── game_state.dart          # 게임 상태 enum
│   │   ├── track.dart               # 트랙 모델
│   │   └── game_result.dart         # 게임 결과 모델
│   ├── providers/                   # 상태 관리
│   │   ├── eye_tracking_provider.dart
│   │   └── game_provider.dart
│   ├── screens/                     # 화면
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── calibration_screen.dart
│   │   ├── game_screen.dart
│   │   ├── result_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/                     # 재사용 가능한 위젯
│   │   ├── track_painter.dart       # Canvas 트랙 렌더링
│   │   └── game_hud.dart            # 게임 HUD
│   └── utils/                       # 유틸리티
├── android/                         # Android 네이티브 설정
├── assets/                          # 이미지, 사운드 등
└── pubspec.yaml                     # 의존성 관리
```

## 🚀 시작하기

### 사전 요구사항
- Flutter SDK (3.0 이상)
- Android Studio 또는 VS Code
- Android 디바이스 또는 에뮬레이터 (API 21 이상)

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd eyetracking
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **디바이스 연결 확인**
   ```bash
   flutter devices
   ```

4. **앱 실행**
   ```bash
   flutter run
   ```

### 빌드

**Android APK 빌드**
```bash
flutter build apk --release
```

**Android App Bundle 빌드 (Play Store용)**
```bash
flutter build appbundle --release
```

## 🎮 게임 방법

### 1단계: 캘리브레이션
- 앱 실행 후 "게임 시작" 선택
- 화면의 9개 포인트를 순서대로 응시한 후 탭
- 캘리브레이션 완료

### 2단계: 게임 플레이
- 화면에 표시되는 트랙(경로)을 시선으로 따라가기
- 트랙 위에 시선을 유지하면 점수 획득
- 트랙을 벗어나면 페널티 적용

### 3단계: 콤보 & 피버
- 연속으로 트랙 유지 시 콤보 스택 증가
- 피버 게이지가 가득 차면 피버 모드 발동
- 피버 모드: 속도 증가, 점수 2배

## 📊 마일스톤 및 개발 진행 상황

### ✅ Milestone 1: MVP (완료)
- [x] Flutter 프로젝트 초기화
- [x] 시선 추적 Provider 구현
- [x] 게임 상태 관리 Provider 구현
- [x] 화면 UI 구현 (Splash, Home, Calibration, Game, Result)
- [x] Canvas 기반 트랙 렌더링
- [x] 시선-트랙 충돌 감지
- [x] Android 설정 파일 구성

### ✅ Milestone 2: 게임성 강화 (완료)
- [x] 다양한 트랙 추가 (난이도별 15개)
  - 초급 5개 (간단한 S자, 곡선, 지그재그, 원형 등)
  - 중급 5개 (복잡한 S자, 나선형, 무한대, W자 등)
  - 고급 5개 (극도로 복잡한 곡선, 이중나선, 별 모양 등)
- [x] 트랙 선택 UI 구현
  - 난이도별 트랙 리스트
  - 트랙 미리보기 기능
- [x] 사운드 효과 추가
  - 트랙 유지/이탈 사운드
  - 콤보 증가 사운드
  - 피버 모드 시작/종료 사운드
  - 게임 완료 사운드
- [x] BGM 추가
  - 메뉴 BGM
  - 게임 플레이 BGM
  - 피버 모드 전용 BGM
- [x] 진동 피드백 구현
  - 트랙 이탈 시 진동
  - 콤보/피버 모드 진동 패턴

### ✅ Milestone 3: 콘텐츠 확장 (완료)
- [x] 소셜 공유 기능 구현
  - 게임 결과 공유 (텍스트 기반)
  - 리더보드 공유
  - 친구 초대 공유
- [x] 설정 시스템 완성
  - 사운드 효과 ON/OFF
  - 배경 음악 ON/OFF
  - 진동 ON/OFF
  - SharedPreferences로 설정 저장
- [x] SettingsService 구현
  - 설정 값 영구 저장
  - AudioService와 연동

### 🔮 Milestone 4: 고급 기능 (향후 계획)
- [ ] 클라우드 백엔드 연동 (Firebase/Supabase)
- [ ] 글로벌 리더보드
- [ ] 멀티플레이 협동 모드
- [ ] AI 트레이닝 모드
- [ ] 수익화 (광고, 인앱 구매)
- [ ] 실제 사운드 에셋 제작

## 🐛 알려진 이슈

- **시선 추적 정확도**: 조명 환경에 영향을 받을 수 있음
- **성능**: 저사양 디바이스에서 프레임 드롭 가능
- **캘리브레이션**: 알고리즘 개선 필요 (더 정교한 매핑)
- **사운드 파일**: 현재 더미 파일만 포함 (실제 오디오 에셋 필요)

## ⚠️ 중요 참고사항

### 사운드 파일
현재 `assets/sounds/` 디렉토리에는 더미 파일만 있습니다. 실제 게임을 플레이하려면 다음 사운드 파일을 추가해야 합니다:

```
assets/sounds/
├── on_track.mp3          # 트랙 유지 사운드
├── off_track.mp3         # 트랙 이탈 경고음
├── combo.mp3             # 콤보 증가 사운드
├── fever_start.mp3       # 피버 모드 시작
├── fever_end.mp3         # 피버 모드 종료
├── game_complete.mp3     # 게임 완료
├── click.mp3             # 버튼 클릭
├── menu_bgm.mp3          # 메뉴 배경음악
├── game_bgm.mp3          # 게임 배경음악
└── fever_bgm.mp3         # 피버 모드 음악
```

**파일이 없어도 앱은 정상 작동하지만, 소리가 나지 않습니다.**

## 📝 할 일

- [ ] 시선 추적 정확도 개선 (캘리브레이션 알고리즘)
- [ ] 트랙 에디터 개발 (커스텀 트랙 생성)
- [ ] 튜토리얼 모드 추가
- [ ] 다국어 지원 (영어, 한국어)

## 🤝 기여

이슈 및 PR을 환영합니다!

## 📄 라이선스

MIT License

## 👨‍💻 개발자

GenSpark AI Developer

---

**즐거운 게임 되세요! 👁️✨**
