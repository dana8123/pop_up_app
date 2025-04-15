import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'main_navigation.dart';
import '../utils/network_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();

    // 네트워크 연결 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNetwok(context);
    });

    // 2초 뒤 광고 or 메인화면
    Future.delayed(Duration(seconds: 2), () {
      if (_isAdLoaded) {
        _interstitialAd?.show();
      } else {
        goToMain();
      }
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // 테스트용 ID (배포 시 교체!)
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('광고 로드 ....?: ');
              goToMain();
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('광고 로드 ....? 실패: ');
              goToMain();
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('광고 로드 실패: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void goToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainNavigation()),
    );
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
