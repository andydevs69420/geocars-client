
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocarsclient/utils/binder_config.dart';
import 'package:geocarsclient/view/scaffold_messenger.dart';
import 'package:geocarsclient/view/tracker_view_standalone.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannQr extends StatefulWidget {
  const ScannQr({ Key? key }) : super(key: key);

  @override
  _ScannQrState createState() => _ScannQrState();
}

class _ScannQrState extends State<ScannQr> {

  BuildContext? ctxGlobal;
  Barcode? scanresult;
  QRViewController? qrctrl;
  GlobalKey qrKey = GlobalKey(debugLabel: "QRCODE");
  bool allowScanning = true;

  void _onQrViewCreated(QRViewController genctrl) {
    setState(() {
      qrctrl = genctrl;
    });

    qrctrl?.scannedDataStream.listen((datastream) {

      if (!allowScanning) return;
        
      setState(() {
        _onScanresult(datastream.code.toString());
      });
    });

  }

  void _onPermCheck(BuildContext ctx,QRViewController ctrl,bool perm) {
    if (!perm) {
      showScaffoldMessage(ctx, "Camera permission denied!");
    }
  }

  void _onScanresult(String result) async {
    
    allowScanning = false;

    late Map map;
    bool isinvalid = false;

    try {
      map = jsonDecode(result);
    }
    catch(err) {
      isinvalid = true;
    }


    if (!isinvalid) {
      if (
        !(map.containsKey("userid") && map.containsKey("carplate"))
      ) {
        isinvalid = true;
      }
    }

    

    if (isinvalid) {
      // allowScanning = true;
      showScaffoldMessage(
        ctxGlobal!, 
        "Invalid qr code!"
      );
    }
    else {
      Config.writeConfig(
        result, 
        () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext ctx) => const TrackerViewSA()));
        } , 
        () {
          allowScanning = true;
          showScaffoldMessage(
            ctxGlobal!, 
            "Config write error!"
          );
        }
      );
    }

  }

  @override
  Widget build(BuildContext context) {

    ctxGlobal = context;
    double _prime,_w,_h,_size;

    _w = MediaQuery.of(context).size.width;
    _h = MediaQuery.of(context).size.height;

    _prime = (_w > _h)?_h:_w;

    _size = _prime * 0.75;


    return QRView(
      key: qrKey, 
      overlay: QrScannerOverlayShape(
        borderColor: const Color(0xffb2b3f7),
        borderRadius: 0,
        borderLength: 50,
        borderWidth:  2,
        cutOutSize: _size
      ),
      onQRViewCreated: _onQrViewCreated,
      onPermissionSet: (ctrl,perm) => _onPermCheck(context, ctrl, perm),
    );
  }

  @override
  void dispose() {
    qrctrl?.dispose();
    super.dispose();
  }
}