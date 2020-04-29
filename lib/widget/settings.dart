import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bacnet_translator/localization.dart';
import 'package:bacnet_translator/storage.dart';
import 'package:bacnet_translator/widget/qr-scanner.dart';

class FormWidget extends StatefulWidget {
  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _adress;
  String _error = "Testing ...";
  String _localVersion;
  String _rawJson;
  Map<String, dynamic> _decodedJson;
  bool _newVersionAvailable = false;
  bool _adressCorrect = false;
  Color _dataColor = Colors.grey;
  final _controller = TextEditingController();

  // Compare the Version Numbers
  Future _compareVersion(version) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('localVersion') != version;
  }

  // Update the json on filesystem
  Future _updateLocalScheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonStorage().writeJsonStore(this._rawJson, true);
    prefs.setString('localVersion', this._decodedJson['Version']);
    setState(() {
      _dataColor = Colors.green;
      _error = AppLocalizations.of(context).translate('good');
      _newVersionAvailable = false;
    });
    _getPrefs();
  }


  // Future to test JSON
  Future _fetchScheme(http.Client client, adress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (adress == null) {
      adress = prefs.getString("adress");
    }

    try {
      final _response = await http.get(adress);
      try {
        var _decoded = json.decode(_response.body) as Map<String, dynamic>;
        if (_decoded['Version'] == null) {
          throw FormatException();
        }
        var _compare =  await _compareVersion(_decoded['Version']);
        await prefs.setString('adress', adress);
        setState(() {
          if (_compare) {
            _dataColor = Colors.yellow;
            _error = AppLocalizations.of(context).translate('newVersion');
          } else {
            _dataColor = Colors.green;
            _error = AppLocalizations.of(context).translate('good');
          }
          _rawJson = _response.body;
          _decodedJson = _decoded;
          _newVersionAvailable = _compare;
          _adressCorrect = true;
        }); 
      } on FormatException {
        setState(() {
          _dataColor = Colors.red;
          _error = AppLocalizations.of(context).translate('formatError');
          _adressCorrect = false;
        });
      }
    } catch (e) {
      setState(() {
        _dataColor = Colors.red;
        _error = AppLocalizations.of(context).translate('adressError');
        _adressCorrect = false;
      }); 
    }
  }

  /// get the Preferences
  Future _getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _adress = prefs.getString("adress");
      _controller.text = _adress;
      _localVersion = prefs.getString('localVersion');
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

@override
  void initState() {
    super.initState();
    _getPrefs();
    _fetchScheme(http.Client(), _adress);
  }

  void _showOverlay(BuildContext context) async {
      final adress = await Navigator.push(
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
      callback(adress);
  }


  void callback(String adress) {
    if (adress != null) {
      setState(() {
        this._adress = adress;
        this._controller.text = adress;
      });
      _fetchScheme(http.Client(), this._adress);
    }
  }


  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _button;
    
    if ( _newVersionAvailable ) {
      _button = RaisedButton(
        color: _dataColor,
        onPressed: () {
          _updateLocalScheme();
        },
        child: Text(AppLocalizations.of(context).translate('activateVersion')),
      );
    } else {
      _button = RaisedButton(
        color: _dataColor,
        onPressed: () {
          setState(() {
            this._adress = _controller.text;
          });
          _fetchScheme(http.Client(), this._adress);
        },
        child: Text(AppLocalizations.of(context).translate('testFile')),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    _showOverlay(context);
                  },
                ),
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context).translate('descriptionToAdress'),
              ),
              controller: _controller,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: _width / 2,
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _error,
                      style: TextStyle(color: _dataColor)
                    ),
                    Text("${AppLocalizations.of(context).translate('localVersion')}: ${this._localVersion ?? "---"}"),
                    this._adressCorrect ? Text("${AppLocalizations.of(context).translate('onlineVersion')}: ${this._decodedJson['Version']}") : Text("${AppLocalizations.of(context).translate('onlineVersion')}: ---"),
                  ],
                ),
              ),
              Container(
                width: _width /2,
                padding: EdgeInsets.all(15),
                child: _button,
              ),
            ],
          ),
        ],
      ),
    );
  }
}



/// ###################### Main Settings Widget ##########################################
/// ToDo: integrate FormWidget into the normal Settings to minmize double-code and async operations
class SettingsWidget extends StatefulWidget {

  
  _SettingsWidget createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  bool _littleWidget = false;

  Future _toggleLittleWidget(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("littleWidget", value);
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
    _getPrefs();
  }

  _launchURL() async {
    const url = 'https://noell.li';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build (BuildContext context) {

  return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(AppLocalizations.of(context).translate('settings')),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate('schemeSettings'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(AppLocalizations.of(context).translate('enterAdress')),
            ),
            FormWidget(),
            Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate('appearanceSettings'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context).translate('toggleLittleWidget')),
              subtitle: Text(AppLocalizations.of(context).translate('toggleLittleWidgetDescription')),
              value: _littleWidget,
              onChanged: (bool value) {
                _toggleLittleWidget(value);
                setState(() {
                  _littleWidget = value;
                });
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate('aboutHeader'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Text(
                AppLocalizations.of(context).translate('licence'),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).translate('about'),
                    textAlign: TextAlign.center,
                  ),
                  RaisedButton(
                    child: Text("noell.li"),
                    onPressed: () => _launchURL(),
                  )
                ],
              ),
            ),
          ]
        )
      ),
    );
  }
}