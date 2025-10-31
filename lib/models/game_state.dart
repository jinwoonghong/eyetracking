enum GameState {
  menu,
  calibration,
  playing,
  paused,
  finished,
}

enum Difficulty {
  beginner,
  intermediate,
  advanced,
}

enum GameTheme {
  constellation,
  jungle,
  cityDrive,
  underwater,
}

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
    }
  }

  double get trackWidth {
    switch (this) {
      case Difficulty.beginner:
        return 80.0;
      case Difficulty.intermediate:
        return 60.0;
      case Difficulty.advanced:
        return 40.0;
    }
  }

  double get baseSpeed {
    switch (this) {
      case Difficulty.beginner:
        return 0.3;
      case Difficulty.intermediate:
        return 0.5;
      case Difficulty.advanced:
        return 0.8;
    }
  }
}

extension GameThemeExtension on GameTheme {
  String get displayName {
    switch (this) {
      case GameTheme.constellation:
        return '별자리';
      case GameTheme.jungle:
        return '정글 어드벤처';
      case GameTheme.cityDrive:
        return '도시 드라이브';
      case GameTheme.underwater:
        return '물속 탐험';
    }
  }

  String get description {
    switch (this) {
      case GameTheme.constellation:
        return '밤하늘의 별자리를 연결하세요';
      case GameTheme.jungle:
        return '굽이진 덩굴을 따라 이동하세요';
      case GameTheme.cityDrive:
        return '야경 네온사인을 따라가세요';
      case GameTheme.underwater:
        return '산호초 사이를 탐험하세요';
    }
  }
}
