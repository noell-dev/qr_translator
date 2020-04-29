import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


const flash_on = "FLASH ON";
const flash_on_i = Icon(Icons.flash_on, color: Colors.white,);
const flash_off = "FLASH OFF";
const flash_off_i = Icon(Icons.flash_off, color: Colors.white,);

const cam_on = "CAM ON";
const cam_on_i = Icon(Icons.pause, color: Colors.white,);
const cam_paused = "CAM PAUSED";
const cam_paused_i = Icon(Icons.play_arrow, color: Colors.white,);


Widget buildOverlayContent(BuildContext context) {
  var screenSize = MediaQuery.of(context).size;
  var width = screenSize.width;
  var height = screenSize.height;

  return OrientationBuilder(
    builder: (context, orientation) {
      return Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.7),
        ),
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: orientation == Orientation.landscape ? height : width,
                height: orientation == Orientation.landscape ? height : width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: QrWidget(),
                )
              ),
            ],
          ),
        ),
      );
    },
  );
}


class LittleQrWidget extends StatefulWidget {
  Function callback;

  LittleQrWidget(this.callback);

  @override
  _LittleQrWidget createState() => _LittleQrWidget();
}


class _LittleQrWidget extends State<LittleQrWidget> {

  void callback(String code) {
    this.widget.callback(code);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;
    var height = screenSize.height;
    return OrientationBuilder(
    builder: (context, orientation) {
      return Container(
            width: orientation == Orientation.landscape ? width/2 : height/2,
            height: orientation == Orientation.landscape ? width/2 : height/2,
            child: CameraView(callback)
          );
    });
  }
}


class QrWidget extends StatefulWidget {
  @override
  _QrWidget createState() => _QrWidget();
}


class _QrWidget extends State<QrWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void callback(String code) {
      Navigator.of(context).pop(code);
  }

  QRViewController controller;

  List<Widget> camChildren;

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
      // Camera (QR-Scan) Widget
      Expanded(
        flex: 5,
        child:  CameraView(callback)
      ),
    ],
    );
  }
}

// ###########################################
// ###    Camera View with Controls        ###
// ###########################################

class CameraView extends StatefulWidget {
  Function callback;

  CameraView(this.callback);

  @override
  _CameraView createState() => _CameraView();
}


class _CameraView extends State<CameraView> {
  var qr_text = null;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var flashState = flash_on;
  var flashImage = flash_on_i;
  var camStatus = cam_on;
  var camStatusImage = cam_on_i;

  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: flashImage,
                  onPressed: () {
                  if (controller != null) {
                    controller.toggleFlash();
                    if (_isFlashOn(flashState)) {
                      setState(() {
                        flashState = flash_off;
                        flashImage = flash_off_i;
                      });
                    } else {
                      setState(() {
                        flashState = flash_on;
                        flashImage = flash_on_i;
                      });
                    }
                  }
                },
                ),
                IconButton(
                  icon: camStatusImage,
                  onPressed: () {
                    if(_isCameraPaused(camStatus)){
                      controller?.resumeCamera();
                      setState(() {
                        camStatus = cam_on;
                        camStatusImage = cam_on_i;
                      });
                    } else {
                      controller?.pauseCamera();
                      setState(() {
                        camStatus = cam_paused;
                        camStatusImage = cam_paused_i;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.switch_camera, color: Colors.white,),
                  onPressed: () {
                    if (controller != null) {
                      controller.flipCamera();
                      setState(() {
                        camStatus = cam_on;
                        camStatusImage = cam_on_i;
                      });
                    }
                  },
                )
              ],
            )
          )
        )
      ]
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData != null) {
        if (qr_text != scanData){  
          this.widget.callback(scanData);
          this.qr_text = scanData;
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _isFlashOn(String current) {
    return flash_on == current;
  }

  _isCameraPaused(String current) {
    return cam_paused == current;
  }
}