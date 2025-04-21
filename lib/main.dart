import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:popup_app/l10n/app_localizations.dart';
import 'package:popup_app/utils/like_helper.dart';
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
        GlobalCupertinoLocalizations.delegate,
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
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          headlineSmall: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}


class LikeButton extends StatefulWidget {
  final double popupId;

  const LikeButton({Key? key, required this.popupId}) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final liked = await LikeHelper.isLiked(widget.popupId);
    if (mounted) {
      setState(() {
        isLiked = liked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: () async {
        await LikeHelper.toggleLike(widget.popupId);
        await _checkLikeStatus();
      },
    );
  }
}