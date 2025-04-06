import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  static Future<bool> isInternetAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
