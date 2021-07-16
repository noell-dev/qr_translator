import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:qr_translator/widget/list-code-translation.dart';
import 'package:qr_translator/widget/qr-scanner.dart';
import 'package:qr_translator/widget/settings.dart';
import 'package:qr_translator/storage.dart';
import 'package:qr_translator/localization.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_matomo/flutter_matomo.dart';

void main() async {
  runApp(MyApp());
}

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

      title: "QR Translator", //AppLocalizations.of(context).translate('title')
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(
        storage: JsonStorage(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final JsonStorage storage;

  Home({Key key, @required this.storage}) : super(key: key);

  // String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _littleWidget = false;
  bool _showHelp = true;
  bool _colorActivated = false;
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
                child: qrOverlayContent(context),
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
          _result = "noFile";
        });
      } else {
        setState(() {
          _json = jsonDecode(json);
          _result = "noCode";
        });
      }
    });
  }

  /// ############################################################
  /// ToDo: Append Strings to File function
  /// ToDo: functions to trigger saving of adresses in Parser ??
  /// ############################################################

  // void _appendStringToFile(String _stringToParse, bool isScheme) {
  //   String _originalJson;
  //   widget.storage.readJsonStore(false).then((String json) {
  //     if (json == "file_error"){

  //     } else {

  //     }
  //   });
  //   JsonStorage().writeJsonStore(_stringToParse, true);
  // }

  Future _getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("littleWidget")) {
      setState(() {
        _littleWidget = prefs.getBool("littleWidget");
      });
    }
    if (prefs.containsKey("colorActivated")) {
      setState(() {
        _colorActivated = prefs.getBool("colorActivated");
      });
    }
    if (prefs.containsKey("showHelp")) {
      setState(() {
        _showHelp = prefs.getBool("showHelp");
      });
    }
  }

  Future<void> _initMatomo(BuildContext context) async {
    await FlutterMatomo.initializeTracker('https://stat.noell.li/piwik.php', 3);
    await FlutterMatomo.trackScreen(context, "Opened");
  }

  Future<void> _trackCode(String name, String action) async {
    await FlutterMatomo.trackEventWithName("Home", name, action);
  }

  @override
  void initState() {
    super.initState();
    _readJson();
    _getPrefs();
    _initMatomo(context);
  }

  void callback(String code) {
    if (code != null) {
      setState(() {
        _codeAvailable = true;
        _code = code;
      });
      _trackCode("ScannerReturned", "code");
    } else {
      setState(() {
        _codeAvailable = false;
        _result = "noCode";
      });
      _trackCode("ScannerReturned", "noCode");
    }
  }

  void _navigateSettings() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsWidget()));
    _readJson();
  }

  @override
  Widget build(BuildContext context) {
    _getPrefs();
    Widget _centerWidget;
    Widget _body;
    Widget _fab;

    if (_codeAvailable) {
      if (_result == "noFile") {
        _centerWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: Text(AppLocalizations.of(context).translate(_result)),
                subtitle: Text(AppLocalizations.of(context)
                    .translate(_result + "Description")),
              ),
              Divider(),
              ListTile(
                title: Text(AppLocalizations.of(context)
                    .translate("codeBesidesNoFile")),
              ),
              Text("$_code")
            ],
          ),
        );
      } else {
        if (_json.containsKey("order")) {
          _centerWidget = ExtendetCodeTranslationWidget(
            code: _code,
            scheme: _json,
            showHelp: _showHelp,
            colorActivated: _colorActivated,
          );
        } else {
          _centerWidget = SimpleCodeTranslationWidget(
            adress: _code,
            scheme: _json,
          );
        }
      }
    } else {
      _centerWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text(AppLocalizations.of(context).translate(_result)),
              subtitle: Text(AppLocalizations.of(context)
                  .translate(_result + "Description")),
            )
          ],
        ),
      );
    }

    _body = _centerWidget;
    _fab = Container();
    if (_littleWidget) {
      _body = new Stack(children: <Widget>[
        _centerWidget,
        new Align(
            alignment: Alignment.bottomRight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
              child: LittleQrWidget(callback),
            ))
      ]);
    } else {
      _fab = FloatingActionButton(
        onPressed: () => _showOverlay(context),
        tooltip: AppLocalizations.of(context).translate("scanCode"),
        child: Icon(Icons.search),
        heroTag: 1,
      );
    }

    // ToDo: Add Button to AppBar to Copy Contents of the QR-Code into Clipboard
    // ToDo: Switch in Header Bar to enable saving of Adresses
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
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
