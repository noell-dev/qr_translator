import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


const flash_on = "FLASH ON";
const flash_on_i = Icon(Icons.flash_on);
const flash_off = "FLASH OFF";
const flash_off_i = Icon(Icons.flash_off);

const cam_on = "CAM ON";
const cam_on_i = Icon(Icons.pause);
const cam_paused = "CAM PAUSED";
const cam_paused_i = Icon(Icons.play_arrow);


class LittleQrWidget extends StatefulWidget {
  Function callback;

  LittleQrWidget(this.callback);

  @override
  _LittleQrWidget createState() => _LittleQrWidget();
}


class _LittleQrWidget extends State<LittleQrWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var camStatus = cam_paused;
  var camStatusImage = cam_paused_i;
  QRViewController controller;


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;
    var height = screenSize.height;
    controller?.pauseCamera();
    return Container(
            width: width/2,
            height: height/4,
            child: Stack(
              children: <Widget>[
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(
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
              )
            ]
            )
          );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      this.widget.callback(scanData);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  _isCameraPaused(String current) {
    return cam_paused == current;
  }
}



class QrWidget extends StatefulWidget {
  @override
  _QrWidget createState() => _QrWidget();
}


class _QrWidget extends State<QrWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  var flashState = flash_on;
  var flashImage = flash_on_i;
  var camStatus = cam_on;
  var camStatusImage = cam_on_i;

  QRViewController controller;

  List<Widget> camChildren;

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
      // Camera (QR-Scan) Widget
      Expanded(
        flex: 5,
        child:  QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
      // Controls for the Camera Widget
      Expanded(
        flex: 1,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // ######  Flash Button
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: RaisedButton(
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
                      child: flashImage
                    ),
                  ),
                  // ######  Camera Flip Button
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (controller != null) {
                          controller.flipCamera();
                          setState(() {
                            camStatus = cam_on;
                            camStatusImage = cam_on_i;
                          });
                        }
                      },
                      child: Icon(Icons.switch_camera)
                    ),
                  ),
                  // ######  Pause Camera Button
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: RaisedButton(
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
                      child: camStatusImage
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: Text(
                      "Code:",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: Text(
                      "$qrText",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () => Navigator.pop(context, qrText),
                      child: Icon(Icons.check),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
    );
  }

  _isFlashOn(String current) {
    return flash_on == current;
  }


  _isCameraPaused(String current) {
    return cam_paused == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}