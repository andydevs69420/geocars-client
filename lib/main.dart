import 'dart:developer';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocarsclient/utils/binder_config.dart';
import 'package:geocarsclient/utils/location_wrapper.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geocarsclient/view/app_binder.dart';
import 'package:geocarsclient/utils/backend_connection.dart';
import 'package:geolocator/geolocator.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const GeocarsClientApp());

  // init background run mode(AndroidAlarmManager)!  
  await AndroidAlarmManager.initialize();
  AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    69420,
    runOnBackground,
    exact: true,
    allowWhileIdle: true,
    wakeup: true,
    rescheduleOnReboot: true
  );
  // fallback
  Workmanager().initialize(callbackDispatcher,isInDebugMode: true);
  Workmanager().registerPeriodicTask(
      "geocar.background.service",
      "runOnBackground",
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((String taskName, Map<dynamic,dynamic>? inputData) {
    if (taskName == "runOnBackground") {
      runOnBackground();
      return Future.value(true);
    }
    return Future.value(false);
  });
}


void runOnBackground() {

  // re-init for new isolate
  LocationService.init()
  .then((bool serving) {

    if (!serving) return;

    BackendConnection.init()
    .then((bool init) {
      if (!init) return;

      Config.isConfigured()
          .then((bool isconfig) {
        if (!isconfig) return;

        Config.readConfig()
        .then((config) {
          LocationService.getLocation(
              callback: (Position pos) {
                BackendConnection.transmit(
                    config,
                    latitude: pos.latitude,
                    longitude: pos.longitude,
                    process: "BACKGROUND"
                );

                log("TRANSMITTED(background): lat ${pos.latitude} - lng ${pos
                    .longitude}");
              }
          );
        }).onError((err, stackTrace) {
          log("ConfigError: $err");
        });
      }).onError((err, stackTrace) {
        log("ConfigError: $err");
      });
    }).catchError((err) {
      log("BackendConnectionInitError: $err");
    });
  }).catchError((err) {log("LOCATIONSERVICERROR: $err");});
}


class GeocarsClientApp extends StatelessWidget {
  const GeocarsClientApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'GeocarsClientApp',
      home: AppBinder(),
    );
  }
}
