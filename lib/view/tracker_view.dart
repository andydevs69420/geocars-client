import 'package:flutter/material.dart';
import 'package:geocarsclient/utils/Services.dart';
import 'package:geocarsclient/utils/binder_config.dart';
import 'package:geocarsclient/utils/location_wrapper.dart';
import 'package:geocarsclient/utils/notification_handler.dart';
import 'package:geocarsclient/utils/weather_handler.dart';
import 'package:geocarsclient/view/scaffold_messenger.dart';
import 'package:geocarsclient/utils/backend_connection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as _l;
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();
  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}


class TrackerView extends StatefulWidget {
  const TrackerView({ Key? key }) : super(key: key);

  @override
  _TrackerViewState createState() => _TrackerViewState();
}

class _TrackerViewState extends State<TrackerView> {
  MapController mapctrl = MapController();
  double zoom = 13, minZoom = 14, maxZoom = 16, ltags = 45;
  double lat = 0, lng = 0;
  bool hasevent = false;


  void startServices() async {


    // init location
    await LocationService.init();
    // init notification handler
    await NotificationHandler.init();
    // init backend connection
    await BackendConnection.init();

    // listen for connection changes
    ConnectionWrapper.onConnectionChange(
        onConnected:    () {
          showScaffoldMessage(super.context, "DEBUG: Connection restored!");
        },
        onDisconnected: () {
          showScaffoldMessage(super.context, "DEBUG: No Internet! Saving offline...");
        }
    );

    // Notification listener
    BackendConnection.onNotification(
        await Config.readConfig(),
        callback: (owner,msgbody) {
          NotificationHandler.showNotification(
              owner,
              msgbody
          );
        }
    );

    // Weather listener
    WeatherHandler.onWeatherUpdate(
      lat: lat,
      lng: lng,
      callback: (String label) {

        String message = "";
      
        switch (label) {
          case "Rain":
            message = "it's raining($label).";
            break;
          case "Thunderstorm":
            message = "Thunderstorm warning($label).";
            break;
          default:
            message = "Cloudy day($label).";
            break;
        }

        NotificationHandler.showNotification(
          "Weather update",
          message
        );
        
      }
    );


    // Location listener
    LocationService.listenServiceUpdate(
      onServiceChange: (ServiceStatus status) async {
        if (status == ServiceStatus.disabled) {
          // TODO: remove on release mode
          if (!await ConnectionWrapper.hasInternet()) {
            showScaffoldMessage(super.context, "DEBUG: GPS disabled! Saving offline...");
          }
          else {
            showScaffoldMessage(super.context, "DEBUG: GPS disabled! Using internet...");
          }
          return;
        }

        showScaffoldMessage(super.context, "DEBUG: GPS ${status.name}!");
      },
      onStartDisabled: () async {
        // TODO: remove on release mode
        if (!await ConnectionWrapper.hasInternet()) {
          showScaffoldMessage(super.context, "DEBUG: GPS disabled! Saving offline...");
        }
        else {
          showScaffoldMessage(super.context, "DEBUG: GPS disabled! Using internet...");
        }
      }
    );

    LocationService.listenLocationUpdate(
      onchange: (Position pos) async {

        // make unique
        if (pos.latitude == lat && pos.longitude == lng) return;

        setState(()  {

          lat = pos.latitude;
          lng = pos.longitude;

          if(!hasevent) mapctrl.move(_l.LatLng(lat,lng),zoom);

        });

        String mode = "FOREGROUND";

        if (!await ConnectionWrapper.hasInternet()) mode = "OFFLINE-FOREGROUND";

        BackendConnection.transmit(
          await Config.readConfig(),
          latitude: lat,
          longitude: lng,
          process: mode,
        );

      },
      onStartPermissionDenied: (LocationPermission perm) async {
        // TODO: remove on release mode
        if (!await ConnectionWrapper.hasInternet()) {
          showScaffoldMessage(super.context, "DEBUG: Location, permission denied!");
        }
        else {
          showScaffoldMessage(super.context, "DEBUG: GPS disabled! Using internet...");
        }
      }
    );

  }

  @override
  void initState() {

    // start foreground services here!
    startServices();

    mapctrl.mapEventStream.listen((event) {
      if (event.runtimeType == MapEventMoveStart) {
        hasevent = true;
      }
      else if (event.runtimeType == MapEventMoveEnd) {
        hasevent = false;
      }
    });

    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapctrl,
      options: MapOptions(
        center: _l.LatLng(lat, lng),
        zoom: zoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        enableMultiFingerGestureRace:true
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          tileProvider: const CachedTileProvider()
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: ltags,
              height: ltags,
              point: _l.LatLng(lat,lng),
              builder: (ctx) => Icon(Icons.location_on,size: ltags,color: const Color(0xffE83233))
            )
          ]
        )
      ],
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
