




import 'package:flutter/material.dart';
import 'package:geocarsclient/view/tracker_view.dart';

class TrackerViewSA extends StatelessWidget {
  const TrackerViewSA({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("GEOCARS CLIENT"),
      ),
      body: const TrackerView(),
    );
  }
}


