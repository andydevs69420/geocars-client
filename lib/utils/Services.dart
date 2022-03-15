



import 'dart:developer';
import 'dart:io';
import 'package:connectivity/connectivity.dart';

class ConnectionWrapper {
  static void onConnectionChange ({required Function onConnected , required Function onDisconnected}) async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult res) async {
      log("CONNECTIVITY: ${res.toString()}");
      switch (res) {
        case ConnectivityResult.none: onDisconnected();break;
        default: {
          if (await hasInternet()) {
            onConnected();
          }
          else {
            onDisconnected();
          }
          break;
        }

      }
    });
  }

  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

}



