import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/popup_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // .env 파일 로드
  runApp(MyApp());
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
