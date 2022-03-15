import 'dart:developer';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:geocarsclient/utils/binder_config.dart';
import 'package:geocarsclient/utils/location_wrapper.dart';
import 'package:geocarsclient/utils/backend_connection.dart';
import 'package:geolocator/geolocator.dart';


class BackgroundServices {
  
  static void startServices() async {

    // Re-init if not
    // init location ervice
    await LocationService.init();

    // init backend connection
    await BackendConnection.init();

    // init background run mode(AndroidAlarmManager)!
    await AndroidAlarmManager.initialize();
  
    AndroidAlarmManager.periodic(
      const Duration(minutes: 1),
      69420,
      runOnBackground,
      exact: true,
      allowWhileIdle: true,
      wakeup: true
    );
  
  }

  static void runOnBackground() {
    log("RUNNING ON BACKGROUND");
    Config.readConfig().then((Map<String,dynamic>? config) {
      LocationService.getLocation(
        callback: (Position pos) {
          BackendConnection.transmit(
            config,
            latitude : pos.latitude,
            longitude: pos.longitude,
            process: "background"
          );
        }
      );
    });

  }

}

