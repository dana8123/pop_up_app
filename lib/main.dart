import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './providers/popup_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // .env 파일 로드
  print(dotenv.get("SUPABASE_URL"));
  await Supabase.initialize(
    url: dotenv.get("SUPABASE_URL"),
    anonKey: dotenv.get("SUPABASE_ANON_KEY"),
  );
  runApp(
    ChangeNotifierProvider(
        create: (_) => PopupProvider()..fetchPopups(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Popup Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansKr',
      ),
      home: SplashScreen(),
    );
  }
}
