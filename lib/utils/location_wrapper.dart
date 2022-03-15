
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:geocarsclient/utils/Services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {

  static bool _isInit = false;

  static Future<bool> init() async {
    if (!_isInit) {

      _isInit = true;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.always) {
        _isInit = true;
      }
      else {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.always) {
          _isInit = true;
        }
      }

    }
    return _isInit;

  }

  static void listenServiceUpdate({required Function(ServiceStatus status) onServiceChange,required void Function() onStartDisabled}) async {

    if (!_isInit) return;

    var status = await Geolocator.isLocationServiceEnabled();
    if (!status) {
      onStartDisabled();
    }

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      onServiceChange(status);
    })
    .onError((err) {
      log("LOCATIONWRAPPER: $err");
    });

  }

  static void listenLocationUpdate({required Function(Position position) onchange,required void Function(LocationPermission) onStartPermissionDenied}) async {

    if (!_isInit) return;

    Geolocator.getPositionStream().listen((Position pos) {
      onchange(pos);
    })
    .onError((err) {
      log("LOCATIONWRAPPER: $err");
    });


  }

  static void getLocation({required Function(Position position) callback}) async {

    if (!await Geolocator.isLocationServiceEnabled()) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
    .then((Position pos) {
      callback(pos);
      return pos;
    });

  }

}

