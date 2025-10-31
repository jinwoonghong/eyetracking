import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eye_tracking_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            onTap: () => _resetCalibration(context),
          ),

          const Divider(),

          // 게임 설정
          _SectionHeader(title: '게임'),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('사운드 효과'),
            subtitle: const Text('게임 사운드 켜기/끄기'),
            value: true, // TODO: 실제 설정 값
            onChanged: (value) {
              // TODO: 사운드 설정 저장
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('진동'),
            subtitle: const Text('햅틱 피드백 켜기/끄기'),
            value: true, // TODO: 실제 설정 값
            onChanged: (value) {
              // TODO: 진동 설정 저장
            },
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
        ],
      ),
    );
  }

  void _resetCalibration(BuildContext context) {
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
