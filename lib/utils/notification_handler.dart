


import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {

  static final FlutterLocalNotificationsPlugin _fnotify = FlutterLocalNotificationsPlugin();
  static int _notifid = -1;
  static bool _isInit = false;
  static const String groupKey                = "com.gocarsdev.PUSH_NOTIF";
  static const String groupChannelId          = "NOTIFICATION GEOCARS";
  static const String groupChannelName        = "GEOCARS NOTIF";
  static const String groupChannelDescription = "GEOCARS NOTIFICATION";
  static const AndroidNotificationDetails androidNotificationDetails =
  AndroidNotificationDetails(
      groupChannelId     ,
      groupChannelName   ,
      groupKey: groupKey ,
      priority: Priority.high    ,
      importance: Importance.max ,
      channelDescription: groupChannelDescription,
  );

  static Future<bool> init() async {
    if (!_isInit) {
        _isInit = true;
        var initAndroid  = const AndroidInitializationSettings('geocarsapp');
        var initSettings = InitializationSettings(android: initAndroid);
        await _fnotify.initialize(
            initSettings,
            onSelectNotification: (String? payload) async {
              if (payload != null) log("NOTIFPAYLOAD: $payload");
            }
        );
    }
    return _isInit;
  }

  static void showNotification(String title,String messageBody) async {
    if (!_isInit) return;

    await _fnotify.show(
      (++_notifid),
      title,
      messageBody,
      const NotificationDetails(
        android: androidNotificationDetails
      )
    );
  }

}

