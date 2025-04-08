import 'package:flutter/material.dart';
import 'popup_list_page.dart';
import 'main_navigation.dart';
import '../utils/network_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // splash
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainNavigation()), // 메인 화면으로 이동
      );
    });

    // 네트워크 연결 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNetwok(context);
    });

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          body: Center(
        child: Text('Popup Finder',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ));
    }
  }

  void checkNetwok(BuildContext context) async {
    bool connected = await NetworkHelper.isInternetAvailable();
    if (!connected) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  title: Text("네트워크 연결 없음"),
                  content: Text("인터넷 연결을 확인해주세요"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("확인"),
                    )
                  ]));
    }
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
