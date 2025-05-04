import 'package:flutter/material.dart';
import 'package:popup_app/services/push_notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await PushNotificationService().isNotificationEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SizedBox(height: 20),
                _buildSectionTitle('알림 설정'),
                SwitchListTile(
                  title: Text('푸시 알림'),
                  subtitle: Text('새로운 팝업 스토어 정보 및 업데이트를 받습니다'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    // 알림 설정 업데이트
                    await PushNotificationService().setNotificationEnabled(value);
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    
                    // 알림 상태 변경 피드백
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                Divider(),
                
                // 추가 설정 옵션들을 여기에 추가할 수 있습니다
                _buildSectionTitle('앱 정보'),
                ListTile(
                  title: Text('앱 버전'),
                  subtitle: Text('1.0.0'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('이용약관'),
                  onTap: () {
                    // 이용약관 페이지로 이동
                  },
                ),
                ListTile(
                  title: Text('개인정보 처리방침'),
                  onTap: () {
                    // 개인정보 처리방침 페이지로 이동
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}