
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class WeatherHandler {
  static const String _apiKey = "94bf8010751e87f67f68ac3ec19fb73b";
  static bool _isFirstrun = true;
  static String _label = "";

  static void onWeatherUpdate({required double lat,required double lng,required Function(String label) callback}) async {
    String request = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$_apiKey";

    // if (_isFirstrun) {
    //   _isFirstrun = false;
    //   return;
    // }

    Timer.periodic(const Duration(minutes: 1), (timer) {
      log("WEATHERLISTENING...");
      http.get(Uri.parse(request))
      .then((response) {
        if (response.statusCode == 200) {
          Map respBody = jsonDecode(response.body);
          List weather = respBody["weather"];
          if (weather.isNotEmpty) {
            Map data = weather[0];
            int id   = data["id"];
            String label = data["main"];
            if (
                (id >= 500 && id <= 531) || // Rain
                (id >= 200 && id <= 232) || // Thunderstorm
                (id >= 801 && id <= 804)    // Cloudy
            ) {
              if (label != _label) {
                log("TO NOTIFY!");
                _label = label;
                callback(label);
              }
              else {
                log("WEATHERERROR: empty label $_label");
              }
            }
          }
          else{
            log("WEATHERERROR: empty!");
          }
        }
        else {
          log("WEATHERERROR: ${response.statusCode}");
        }
      })
      .catchError((err) {
        log("WEATHERERROR: $err");
      });
    });

  }
}

