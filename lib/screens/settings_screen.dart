import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eye_tracking_provider.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../services/share_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final AudioService _audioService = AudioService();
  final ShareService _shareService = ShareService();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.initialize();
    setState(() {
      _soundEnabled = _settingsService.soundEnabled;
      _musicEnabled = _settingsService.musicEnabled;
      _vibrationEnabled = _settingsService.vibrationEnabled;
    });

    // AudioService에 설정 반영
    _audioService.soundEnabled = _soundEnabled;
    _audioService.musicEnabled = _musicEnabled;
    _audioService.vibrationEnabled = _vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // 시선 추적 설정
          _SectionHeader(title: '시선 추적'),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('캘리브레이션 초기화'),
            subtitle: const Text('시선 추적 정확도가 낮을 때 사용'),
            onTap: _resetCalibration,
          ),

          const Divider(),

          // 게임 설정
          _SectionHeader(title: '게임'),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('사운드 효과'),
            subtitle: const Text('게임 사운드 켜기/끄기'),
            value: _soundEnabled,
            onChanged: (value) async {
              setState(() => _soundEnabled = value);
              await _settingsService.setSoundEnabled(value);
              _audioService.soundEnabled = value;

              if (value) {
                _audioService.playClick();
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.music_note),
            title: const Text('배경 음악'),
            subtitle: const Text('게임 BGM 켜기/끄기'),
            value: _musicEnabled,
            onChanged: (value) async {
              setState(() => _musicEnabled = value);
              await _settingsService.setMusicEnabled(value);
              _audioService.musicEnabled = value;

              if (!value) {
                _audioService.stopMusic();
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('진동'),
            subtitle: const Text('햅틱 피드백 켜기/끄기'),
            value: _vibrationEnabled,
            onChanged: (value) async {
              setState(() => _vibrationEnabled = value);
              await _settingsService.setVibrationEnabled(value);
              _audioService.vibrationEnabled = value;
            },
          ),

          const Divider(),

          // 공유
          _SectionHeader(title: '공유'),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('친구 초대'),
            subtitle: const Text('Star Tracer를 친구에게 추천'),
            onTap: () => _shareService.shareInvite(),
          ),

          const Divider(),

          // 정보
          _SectionHeader(title: '정보'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('버전'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('오픈소스 라이선스'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Star Tracer',
                applicationVersion: '1.0.0',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('개발자 정보'),
            subtitle: const Text('GenSpark AI Developer'),
          ),
        ],
      ),
    );
  }

  void _resetCalibration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('캘리브레이션 초기화'),
        content: const Text('정말로 캘리브레이션을 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<EyeTrackingProvider>().resetCalibration();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('캘리브레이션이 초기화되었습니다')),
              );
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
