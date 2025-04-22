import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // FCM 권한 요청
      NotificationSettings settings = await _fcm.requestPermission(
          alert: true, badge: true, sound: true, provisional: true);

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // iOS의 경우 APNS 토큰을 기다림
        if (Platform.isIOS) {
          print("iOS 디바이스 감지됨, APNS 토큰 대기 중...");
          await Future.delayed(Duration(seconds: 2)); // APNS 토큰을 기다리기 위한 지연
          String? apnsToken = await _fcm.getAPNSToken();
          print("APNS 토큰: $apnsToken");

          if (apnsToken == null) {
            print("APNS 토큰이 없습니다. FCM 토큰 요청을 건너뜁니다.");
            return;
          }
        }

        // FCM 토큰 요청
        String? token = await _fcm.getToken();
        if (token != null) {
          print("FCM 토큰: $token");
          await _sendTokenToServer(token);
        }

        // 토큰 갱신 리스너
        _fcm.onTokenRefresh.listen((newToken) {
          print("새로운 FCM 토큰: $newToken");
          _sendTokenToServer(newToken);
        });

        // 로컬 알림 초기화
        await _initializeLocalNotifications();

        // 포그라운드 메시지 핸들링
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print("포그라운드 메시지 수신: ${message.messageId}");
          _showLocalNotification(message);
        });

        // 백그라운드 메시지 핸들러 설정
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } else {
        print("알림 권한이 거부되었습니다.");
      }
    } catch (e) {
      print("푸시 알림 초기화 중 오류 발생: $e");
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 탭 핸들링
      },
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'popup_finder_channel',
      'Popup Finder Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      platformChannelSpecifics,
    );
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.get("API_URL")}/device-tokens'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'token': token}),
      );
      print(response.body);

      if (response.statusCode != 200) {
        print('Failed to send token to server');
      }
    } catch (e) {
      print('Error sending token to server: $e');
    }
  }
}

// 백그라운드 메시지 핸들러는 top-level function이어야 합니다
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 메시지 처리
  print("Handling a background message: ${message.messageId}");
}
