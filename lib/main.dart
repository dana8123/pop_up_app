import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:popup_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './providers/popup_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // .env 파일 로드
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); // 광고 초기화
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
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,        // 추가로 AppLocalizations.delegate도 설정 필요
      ],
      supportedLocales: [
        Locale('en'),
        Locale('zh'),
        Locale('ko'),
      ],
      locale: Locale('ko'),
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
