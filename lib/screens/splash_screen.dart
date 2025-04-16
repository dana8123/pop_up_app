import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main_navigation.dart';
import '../utils/network_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _isAdShowing = false;

  @override
  void initState() {
    super.initState();
    _loadAppOpenAd();

    // 네트워크 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNetwork(context);
    });

    // 2초 대기 후 광고 또는 메인 이동
    Future.delayed(Duration(seconds: 2), () {
      if (_isAdLoaded) {
        _showAd();
      } else {
        goToMain();
      }
    });
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: dotenv.get("ADMOB_SPLASH"),
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoaded = true;

          _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdShowing = false;
              goToMain();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAdShowing = false;
              goToMain();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  void _showAd() {
    if (_appOpenAd != null && !_isAdShowing) {
      _isAdShowing = true;
      _appOpenAd!.show();
    } else {
      goToMain();
    }
  }

  void goToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainNavigation()),
    );
  }

  void checkNetwork(BuildContext context) async {
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
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAF9F7),
      body: Center(
        child: Image.asset('assets/splash.png', width: 200),
      ),
    );
  }
}
