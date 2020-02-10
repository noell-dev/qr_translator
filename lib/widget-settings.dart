import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


const jsonFilename = "scheme.json";



// Storage Actions: Done!
class JsonStorage {
  // Get the Local Path on both Platforms
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Provide the json File as a File Object to read and Write
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$jsonFilename');
  }

  // Write newly fetched JSON String
  Future<File> writeJsonStore(String jsonString) async {
    final file = await _localFile;
    return file.writeAsString('$jsonString');
  }

  Future<String> readJsonStore() async {
    try {
      final file = await _localFile;

      // Read the File
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // ToDo: if encountering an error, return ?
      return "file_error";
    }
  }
}


class FormWidget extends StatefulWidget {
  @override
  _FormWidget createState(){
    return _FormWidget();
  }
}

class _FormWidget extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _adress;
  String _error = "Testing ..."; // Translate
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
  Future _updateLocalJSON() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonStorage().writeJsonStore(this._rawJson);
    prefs.setString('localVersion', this._decodedJson['Version']);
    setState(() {
      _dataColor = Colors.green;
      _error = 'Alles Gut!'; // Translate
      _newVersionAvailable = false;
    });
    _getPrefs();
  }


  // Future to test JSON
  Future _fetchJSON(http.Client client, adress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (adress == null) {
      adress = prefs.getString("adress");
    }

    try {
      final _response = await http.get(adress);
      try {
        var _decoded = json.decode(_response.body) as Map<String, dynamic>;
        var _compare =  await _compareVersion(_decoded['Version']);
        await prefs.setString('adress', adress);
        setState(() {
          if (_compare) {
            _dataColor = Colors.yellow;
            _error = 'Neue Version verfügbar'; // Translate
          } else {
            _dataColor = Colors.green;
            _error = 'Alles Gut!'; // Translate
          }
          _rawJson = _response.body;
          _decodedJson = _decoded;
          _newVersionAvailable = _compare;
          _adressCorrect = true;
        }); 
      } on FormatException {
        setState(() {
          _dataColor = Colors.red;
          _error = 'Zieldatei nicht korrekt formatiert!'; // Translate
          _adressCorrect = false;
        });
      }
    } catch (e) {
      setState(() {
        _dataColor = Colors.red;
        _error = 'Adresse inkorrekt!'; // Translate
        _adressCorrect = false;
      }); 
    }
  }

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
    _getPrefs();
    _fetchJSON(http.Client(), _adress);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _button;
    if(_newVersionAvailable){
      _button = RaisedButton(
        color: _dataColor,
        onPressed: () {
          _updateLocalJSON();
        },
        child: Text('Neue Version aktivieren'), // Translate
      );
    } else {
      _button = RaisedButton(
        color: _dataColor,
        onPressed: () {
          setState(() {
            this._adress = _controller.text;
          });
          _fetchJSON(http.Client(), this._adress);
        },
        child: Text('Datei Testen'), // Translate
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
          ),
          Text(
            _error,
            style: TextStyle(color: _dataColor)
          ),
          Text("Lokale Version: ${this._localVersion}"),
          this._adressCorrect ? Text("Online Version: ${this._decodedJson['Version']}") : Text("Online Version: ---"),
          _button,
        ],
      ),
    );
  }
}



// ###################### Main Settings Widget ##########################################
class SettingsWidget extends StatefulWidget {
  _SettingsWidget createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  @override
  Widget build (BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Einstellungen"), // Translate
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text("Adresse angeben: (Beginnt mit HTTP(s)://)") // Translate
              ],
            ),
            FormWidget(),
          ],
        )
      ),
    );
  }
}