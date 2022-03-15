import 'dart:developer';
import 'dart:math' as Math;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

double calcDistance(double lat0,double lng0,double lat1,double lng1) {
  const R   = 6371e3;
  double PI = Math.pi;
  var lat0R = lat0 * PI / 180;
  var lat1R = lat0 * PI / 180;

  double lat1_lat0_diff = (lat1 - lat0) * PI/180;
  double lng1_lng0_diff = (lng1 - lng0) * PI/180;

  double a = Math.sin(lat1_lat0_diff/2) * Math.sin(lat1_lat0_diff/2) +
          Math.cos(lat0R) * Math.cos(lat1R) *
          Math.sin(lng1_lng0_diff) * Math.sin(lng1_lng0_diff);
  double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

  double dist = c * R;
  return dist;
}

class BackendConnection {
  static double _prevLat = 0;
  static double _prevLng = 0;
  static bool _isInit = false;
  static bool _isfirstrun = false;
  static final _msgref = FirebaseFirestore.instance;
  static final _carref = FirebaseFirestore.instance.collection("cars");

  static Future<bool> init() async {
    if (!_isInit) {
      _isInit = true;
      await Firebase.initializeApp();
    }
    return _isInit;
  }

  static void onNotification(Map<String,dynamic>? carconfig,{required Function(String owner,String messageBody) callback}) async {
    if (!_isInit || _isfirstrun) return;

    String id = carconfig?["userid"] + carconfig?["carplate"];
    _msgref.collection("messages").snapshots().listen((doc) {
      for (var element in doc.docChanges) {
        var doc = element.doc;
        if (doc.id == id && _isfirstrun) {
          Map message = doc.get("message");
          callback(message["owner"],message["body"]);
          return;
        }
      }
      _isfirstrun = true;
    });
  }

  static void transmit(Map<String,dynamic>? carconfig,{required double latitude,required double longitude,required String process}) async {
    
    if (!_isInit) return;

    String id = carconfig?["userid"] + carconfig?["carplate"];
    var doc = await _carref.doc(id).get();
    List locations = [];

    double distance = calcDistance(
        _prevLat,
        _prevLng,
        latitude,
        longitude
    );

    // log("DISTANCEMETER: Distance $distance");

    Map? data = doc.data();

    if (data != null) {

      locations = data["locationHistory"];

      //record every 100m distance
      if (distance >= 100) {

        if(!(_prevLat == 0 && _prevLng == 0)){
          locations.add({
            "lat" : _prevLat,
            "lng" : _prevLng
          });
        }

        // log("LOCHISTUPDATE: $_prevLat $_prevLng");

      }
      _prevLat = latitude;
      _prevLng = longitude;

    }

    _carref.doc(id).set({
      "currentLoc" : {
        "lat" : latitude,
        "lng" : longitude,
        "process": process,
      },
      "locationHistory": locations
    },SetOptions(merge: true))
    .catchError((error) => log("BACKENDCONNECTIONERROR: ${error.toString()}"));

  }

}