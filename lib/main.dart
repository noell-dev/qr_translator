import 'package:flutter/material.dart';

import 'package:bacnet_translator/widget-ua.dart';
import 'package:bacnet_translator/widget-qr.dart';
import 'package:bacnet_translator/widget-settings.dart';


var noCode = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Kein Code gescannt"), // Translate
      ],
    ),
  );
var noFile = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Kein Schema", // Translate
          style: TextStyle(color: Colors.red),
        ),
      ],
    ),
  );


class QROverlay extends StatelessWidget {

  @override
  Widget build(
      BuildContext context,
      
      ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;
    var height = screenSize.height;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: width,
            height: height - 200,
            child: QrWidget(),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BACnet Übersetzer', // Translate 
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BACnet Übersetzer', storage: JsonStorage()), // Translate 
    );
  }
}

class MyHomePage extends StatefulWidget {
  final JsonStorage storage;

  MyHomePage({
    Key key,
    this.title,
    @required this.storage
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hideButton = true;
  String _jsonString = "file_error";
  Widget _result = noFile;

  void _showOverlay(BuildContext context) async {
      final code = await Navigator.push(
        context,
        // Create the SelectionScreen in the next step.
        MaterialPageRoute(builder: (context) => QROverlay())
      );
      if (code != null) {
        setState(() {
          _result = UaWidget(
            adress: code,
            jsonString: _jsonString
          );
        });
      } else {
        setState(() {
          _result = noCode;
        });
      }
  }


  void _readJson() {
    widget.storage.readJsonStore().then((String json) {
      if (json == "file_error") {
        setState(() {
          _hideButton = true;
          _jsonString = json;
          _result = noFile;
        });
      } else {
        setState(() {
          _hideButton = false;
          _jsonString = json;
          _result = noCode;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _readJson();
  }

  void _navigateSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsWidget()));
    _readJson();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _navigateSettings();
            },
          )
        ],
      ),
      body: _result,
      floatingActionButton: _hideButton ? FloatingActionButton(
        onPressed: () {
          _navigateSettings();
        },
        tooltip: 'Einstellungen', // Translate
        child: Icon(Icons.settings),
        heroTag: 1,
      ) : FloatingActionButton(
        onPressed: () => _showOverlay(context),
        tooltip: 'Code Scannen', // Translate
        child: Icon(Icons.search),
        heroTag: 1,
      ),
    );
  }
}
