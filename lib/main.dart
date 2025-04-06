import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/popup_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import '../utils/network_helper.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // .env 파일 로드
  runApp(MyApp());
}

void checkNetwork(BuildContext context) async {
  bool connected = await NetworkHelper.isInternetAvailable();
  if (!connected) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text("네트워크 연결 없음"),
                content: Text("인터넷 연결이 필요합니다."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("확인")),
                ]));
  }
  ;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PopupProvider()..fetchPopups(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Popup Finder',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      ),
    );
  }
}
