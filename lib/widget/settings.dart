import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:qr_translator/localization.dart';
import 'package:qr_translator/storage.dart';
import 'package:qr_translator/widget/qr-scanner.dart';

/// ###################### Main Settings Widget ##########################################
///
///

class SettingsWidget extends StatefulWidget {
  _SettingsWidget createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  bool _littleWidget = false;
  bool _colorActivated = false;
  bool _showHelp = true;

  bool _newVersionAvailable = false;
  bool _adressCorrect = false;

  String _adress;
  String _error = "Testing ...";
  String _localVersion;
  String _rawJson;

  Map<String, dynamic> _decodedJson;
  Color _dataColor = Colors.grey;
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getPrefs();
    _fetchScheme(http.Client(), _adress);
    _controller.addListener(_refetchOnChange);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  /// Get SharedPreferences and OptOut Status
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
    if (prefs.containsKey("adress")) {
      setState(() {
        _adress = prefs.getString("adress");
        _controller.text = _adress;
      });
    }
    if (prefs.containsKey("localVersion")) {
      setState(() {
        _localVersion = prefs.getString('localVersion');
      });
    }
  }

  /// toggle a single Value of the SharedPreferences
  Future _toggleValue(name, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(name, value);
  }

  /// Launch the Predefined URL in a Browser
  _launchURL() async {
    const url = 'https://noell.li';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Refetch on change from the TextController
  void _refetchOnChange() {
    _fetchScheme(http.Client(), _controller.text);
  }

  // // Compare the Version Numbers
  // Future _compareVersion(version) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('localVersion') != version;
  // }

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

        // if the required Key "Version" is not available throw an Exception
        if (_decoded['Version'] == null) {
          throw FormatException();
        }

        var _compare = _localVersion !=
            _decoded[
                'Version']; // maybe switch _localVersion for await prefs.getString('localVersion')
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

  /// QR-Scanner Overlay to Scan a code with a URL to schemes
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
                child: qrOverlayContent(context),
              ),
            );
          },
        ));
    callback(adress);
  }

  /// Callback for the QR-Scanner to pass it's contents to Our TextController
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

    // Check if a new Version is Available and change Button according
    if (_newVersionAvailable) {
      _button = ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return _dataColor; // Use the component's default.
            },
          ),
        ),
        onPressed: () {
          _updateLocalScheme();
        },
        child: Text(AppLocalizations.of(context).translate('activateVersion')),
      );
    } else {
      _button = ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return _dataColor; // Use the component's default.
            },
          ),
        ),
        onPressed: () {
          setState(() {
            this._adress = _controller.text;
          });
          _fetchScheme(http.Client(), this._adress);
        },
        child: Text(AppLocalizations.of(context).translate('testFile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(AppLocalizations.of(context).translate('settings')),
      ),
      body: Center(
          child: ListView(children: <Widget>[
        // Header for "Scheme Settings"
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
        // Form with TextController to update Schemes
        Form(
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
                    labelText: AppLocalizations.of(context)
                        .translate('descriptionToAdress'),
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
                        Text(_error, style: TextStyle(color: _dataColor)),
                        Text(
                            "${AppLocalizations.of(context).translate('localVersion')}: ${this._localVersion ?? "---"}"),
                        this._adressCorrect
                            ? Text(
                                "${AppLocalizations.of(context).translate('onlineVersion')}: ${this._decodedJson['Version']}")
                            : Text(
                                "${AppLocalizations.of(context).translate('onlineVersion')}: ---"),
                      ],
                    ),
                  ),
                  Container(
                    width: _width / 2,
                    padding: EdgeInsets.all(15),
                    child: _button,
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
        // Header for "Appearance Settings"
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate('appearanceSettings'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Toggle littleWidget
        SwitchListTile(
          title: Text(
              AppLocalizations.of(context).translate('toggleLittleWidget')),
          subtitle: Text(AppLocalizations.of(context)
              .translate('toggleLittleWidgetDescription')),
          value: _littleWidget,
          onChanged: (bool value) {
            _toggleValue("littleWidget", value);
            setState(() {
              _littleWidget = value;
            });
          },
        ),
        // Toggle Help
        SwitchListTile(
          title: Text(AppLocalizations.of(context).translate('toggleHelp')),
          subtitle: Text(
              AppLocalizations.of(context).translate('toggleHelpDescription')),
          value: _showHelp,
          onChanged: (bool value) {
            _toggleValue("showHelp", value);
            setState(() {
              _showHelp = value;
            });
          },
        ),
        // Toggle colorful
        SwitchListTile(
          title: Text(
              AppLocalizations.of(context).translate('toggleColorActivated')),
          subtitle: Text(AppLocalizations.of(context)
              .translate('toggleColorActivatedDescription')),
          value: _colorActivated,
          onChanged: (bool value) {
            _toggleValue("colorActivated", value);
            setState(() {
              _colorActivated = value;
            });
          },
        ),

        // About Area and Links
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
              ElevatedButton(
                child: Text("noell.li"),
                onPressed: () => _launchURL(),
              )
            ],
          ),
        ),
      ])),
    );
  }
}
