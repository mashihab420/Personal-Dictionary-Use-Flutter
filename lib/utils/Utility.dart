import 'dart:ui';
import 'package:connectivity/connectivity.dart';

class Utility {

  static Future<bool> checkConnection() async {
    ConnectivityResult connectivityResult =
        await (new Connectivity().checkConnectivity());

    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }
}
