import 'package:flutter/material.dart';
import 'package:popup_app/main.dart';
import 'popup_list_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PopupListPage()), // 메인 화면으로 이동
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
    checkNetwork(context);
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/splash.png', width: 200), // 스플래시 이미지 추가
      ),
    );
  }
}
