import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _notificationEnabledKey = 'notification_enabled';
  bool _isNotificationEnabled = true;

  Future<void> init() async {
    // 저장된 알림 설정 불러오기
    await _loadNotificationSettings();

    // iOS에서는 AppDelegate에서 이미 권한 요청을 했을 수 있음
    // 하지만 안전하게 여기서도 한번 더 요청
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // iOS에서 중요
    );

    print('FCM 권한 상태: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted permission');

      // 토큰 리스너 등록 (iOS에서 중요)
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        print('FCM 토큰 갱신됨: $token');
        // 여기서 토큰을 서버에 전송하는 코드 추가 가능
      });

      // FCM 토큰 가져오기
      if (_isNotificationEnabled) {
        await getToken();
      }

      // 로컬 알림 설정
      await _setupLocalNotifications();

      // foreground 알림 핸들러 설정
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // background 알림 핸들러 설정
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // 앱이 종료된 상태에서 알림을 통해 열릴 때 처리
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          _handleInitialMessage(message);
        }
      });
    } else {
      print(
          'User declined or has not accepted permission: ${settings.authorizationStatus}');
      await setNotificationEnabled(false);
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // 로컬 알림 클릭 시 처리
        print("Local notification clicked: ${details.payload}");
      },
    );
  }

  // FCM 토큰 가져오기
  Future<String?> getToken() async {
    if (!_isNotificationEnabled) return null;

    try {
      // iOS에서는 APNS 토큰이 설정되어 있어야 FCM 토큰을 얻을 수 있음
      String? token = await _fcm.getToken(
        vapidKey: null, // 웹 푸시에 사용되므로 모바일에서는 null
      );
      print('FCM Token: $token');

      // 토큰을 서버에 저장하는 로직을 추가할 수 있습니다
      // 예: await _sendTokenToServer(token);

      return token;
    } catch (e) {
      print('FCM 토큰을 가져오는 중 오류 발생: $e');
      return null;
    }
  }

  Future<String?> saveToken(token) async {
    await Supabase.instance.client.from('user_devices').insert([
      {'token': token},
    ]);

    return null;
  }

  // 토큰 삭제 (로그아웃 또는 알림 비활성화 시)
  Future<void> deleteToken() async {
    try {
      String? token = await _fcm.getToken(
        vapidKey: null, // 웹 푸시에 사용되므로 모바일에서는 null
      );
      print(token);
      await Supabase.instance.client.from('user_devices').update(
          {'deleted_at': DateTime.now().toString()}).eq('token', '${token}');
      await _fcm.deleteToken();
      print('FCM Token deleted');
    } catch (e) {
      print('FCM 토큰 삭제 중 오류 발생: $e');
    }
  }

  // Foreground 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    if (!_isNotificationEnabled) return;

    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  // Background 메시지 처리
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Message clicked from background: ${message.data}');
    // 여기서 특정 화면으로 이동하거나 데이터 처리를 할 수 있습니다.
  }

  // 앱이 종료된 상태에서 알림 클릭으로 시작된 경우
  void _handleInitialMessage(RemoteMessage message) {
    print('App opened from terminated state via notification: ${message.data}');
    // 특정 화면으로 이동하거나 데이터 처리를 할 수 있습니다.
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (!_isNotificationEnabled) return;

    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'popup_channel',
            'Popup Notifications',
            channelDescription: 'This channel is used for popup notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // 알림 설정 저장
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
    _isNotificationEnabled = enabled;

    // iOS에서 알림 권한 설정 확인
    if (enabled) {
      // iOS에서는 사용자가 설정 앱에서 알림을 비활성화했을 수 있으므로 현재 상태 확인
      final settings = await _fcm.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await getToken(); // 토큰 다시 가져오기
        await saveToken(token);

        // 필요시 APNs 토큰 갱신을 위해 registerForRemoteNotifications() 호출
        // 이 기능은 네이티브 코드와 MethodChannel을 통해 구현해야 할 수 있음
      } else {
        // 사용자에게 설정 앱에서 알림을 활성화하도록 안내하는 로직
        print('알림 사용 권한이 없습니다. 설정 앱에서 알림을 활성화해 주세요.');
      }
    } else {
      await deleteToken(); // 토큰 삭제
    }
  }

  // 저장된 알림 설정 불러오기
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isNotificationEnabled = prefs.getBool(_notificationEnabledKey) ?? true;
  }

  // 현재 알림 설정 상태 가져오기
  Future<bool> isNotificationEnabled() async {
    await _loadNotificationSettings();
    return _isNotificationEnabled;
  }
}
