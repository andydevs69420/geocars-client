
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocarsclient/utils/binder_config.dart';
import 'package:geocarsclient/view/qr_scanner.dart';
import 'package:geocarsclient/view/tracker_view.dart';

class AppBinder extends StatefulWidget {
  const AppBinder({Key? key}) : super(key: key);

  @override
  _AppBinderState createState() => _AppBinderState();
}

class _AppBinderState extends State<AppBinder> {
  bool _isset = false;
  bool _isScanView = true;

  @override
  void initState()  {

    super.initState();
  }

  @override
  Widget build(BuildContext context)  {

    double _w,_h;

    _w = MediaQuery.of(context).size.width;
    _h = MediaQuery.of(context).size.height;

    double _prime,_iconSize,_textSize;

    _prime = (_w > _h)?_h:_w;

    _iconSize = _prime * 0.16;
    _textSize = _prime * 0.06;
    

    return Scaffold(
      appBar: (!_isScanView)?
      AppBar(
        centerTitle: true,
        title: const Text("GEOCARS CLIENT"),
      )
      :
      null,
      body: SafeArea(
        child: FutureBuilder(
          future: Config.readConfig(),
          builder: (ctx, AsyncSnapshot<Map<String,dynamic>> snapshot) {

            if (snapshot.hasData) {

              Map<String,dynamic>? map = snapshot.data;

              if (
                  (map?["userid"] != null && map?["carplate"] != null) &&
                  (map?["userid"].length != 0 && map?["carplate"].length != 0) &&
                  (map!.containsKey("userid") && map.containsKey("carplate"))
              ) {
                if (!_isset) {
                  _isset = true;
                  Timer(const Duration(seconds: 3), () => setState(() {
                    _isScanView = false;
                  }));
                }
                // map view
                return const TrackerView();
              }
              else {
                // qr scanner
                return const ScannQr();
              }
            } else if (snapshot.hasError) {

              return  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                    Icon(Icons.error_outline,size: _iconSize),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Fatal error!",
                      style: TextStyle(
                          fontSize: _textSize
                      ),
                    )
                  ],
                ),
              );

            } else {

              return  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                    SizedBox(
                      width: _iconSize,
                      height: _iconSize,
                      child: const CircularProgressIndicator(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Loading",
                      style: TextStyle(
                          fontSize: _textSize
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
