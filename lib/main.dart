import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:bacnet_translator/widget/list-code-translation.dart';
import 'package:bacnet_translator/widget/qr-scanner.dart';
import 'package:bacnet_translator/widget/settings.dart';
import 'package:bacnet_translator/storage.dart';
import 'package:bacnet_translator/localization.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('de'), // German
      ],

      title: "Test", //AppLocalizations.of(context).translate('title')
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "Test", storage: JsonStorage()),
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

  String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _littleWidget = false;
  bool _settingsButton = true;
  String _result = "noFile";
  String _code;
  bool _codeAvailable = false;
  Map<String, dynamic> _json;

  void _showOverlay(BuildContext context) async {
      final code = await Navigator.push(
        context,
        // Create the QROverlay in the next step.
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) {
            return Material(
              color: Colors.white,
              
              type: MaterialType.transparency,
              // make sure that the overlay content is not cut off
              child: SafeArea(
                child: buildOverlayContent(context),
              ),
            );
          },
      ));
      callback(code);
  }


  void _readJson() {
    widget.storage.readJsonStore(true).then((String json) {
      if (json == "file_error") {
        setState(() {
          _settingsButton = true;
          _result = "noFile";
        });
      } else {
        setState(() {
          _settingsButton = false;
          _json = jsonDecode(json);
          _result = "noCode";
        });
      }
    });
  }


/// ############################################################
/// ToDo: Append Strings to File function
/// ToDo: Switch in Header Bar to enable saving of Adresses
/// ToDo: functions to trigger saving of adresses in Parser  
/// ############################################################

  void _appendStringToFile(String _stringToParse, bool isScheme) {
    String _originalJson;
    widget.storage.readJsonStore(false).then((String json) {
      if (json == "file_error"){

      } else {

      }
    });
    JsonStorage().writeJsonStore(_stringToParse, true);
  }

  Future _getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("littleWidget")) {
      setState(() {
        _littleWidget = prefs.getBool("littleWidget");
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _readJson();
    _getPrefs();
  }

  void callback(String code) {
    if (code != null) {
      setState(() {
        _codeAvailable = true;
        _code = code;
      });
    } else {
      setState(() {
        _codeAvailable = false;
        _result = "noCode";
      });
    }
  }

  void _navigateSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsWidget()));
    _readJson();
  }

  @override
  Widget build(BuildContext context) {
    _getPrefs();
    Widget _centerWidget;
    Widget _body;
    Widget _fab;
    
    widget.title = AppLocalizations.of(context).translate('title');


    if (_codeAvailable) {
      if (_json.containsKey("order")) {
        _centerWidget = ExtendetCodeTranslationWidget(
          code: _code,
          scheme: _json,
        );
      } else {
        _centerWidget = SimpleCodeTranslationWidget(
          adress: _code,
          scheme: _json,
        );
      }

    } else {
      _centerWidget = Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text(AppLocalizations.of(context).translate(_result)),
              subtitle: Text(AppLocalizations.of(context).translate(_result + "Description")),
            )
          ],
        ),
      );
    }


    _body = _centerWidget;
    _fab = Container();
    if( _settingsButton ){
      _fab = FloatingActionButton(
        onPressed: () {
          _navigateSettings();
        },
        tooltip: AppLocalizations.of(context).translate("settings"),
        child: Icon(Icons.settings),
        heroTag: 1,
      );
    } else if ( _littleWidget ) {
      _body =  new Stack(
        children: <Widget>[
          _centerWidget,
          new Align(
            alignment: Alignment.bottomRight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
              child: LittleQrWidget(callback),
            )
          )
        ]
      );
    } else {
      _fab = FloatingActionButton(
        onPressed: () => _showOverlay(context),
        tooltip: AppLocalizations.of(context).translate("scanCode"),
        child: Icon(Icons.search),
        heroTag: 1,
      );
    }
    
    return Scaffold(
      appBar: AppBar(
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
      body: _body, 
      floatingActionButton: _fab,
    );
  }
}
