import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


const jsonFilename = "scheme.json";


// ToDo: implement secure function to fetch JSON Data
Future<String> fetchJSON(http.Client client, adress) async {
  try {
    final _response = await http.get(adress);
    try {
      var x = json.decode(_response.body) as Map<String, dynamic>;
      JsonStorage().writeJsonStore(_response.body);
      return "OK";
    } on FormatException {
      return throw("Zieldatei nicht korrekt formatiert!"); // Todo: Translate
    }
  } catch (err) {
    return throw('Adresse inkorrekt!'); // Todo: Translate
  }
}

// Storage Actions: Done?
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

// Form done?
class FormWidget extends StatefulWidget {
  @override
  _FormWidget createState(){
    return _FormWidget();
  }
}
// Form done?
class _FormWidget extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  String adress;

  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<String>(
      future: fetchJSON(http.Client(), this.adress),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Color _dataColor = Colors.grey;
        var _error = Text('');

        if (snapshot.hasData) {
          _dataColor = Colors.green;
          _error = Text(
            '',
            style: TextStyle(color: _dataColor)
          );
        } 
        if (snapshot.hasError) {
          _dataColor = Colors.red;
          _error = Text(
            '${snapshot.error}',
            style: TextStyle(color: _dataColor)
          );
        }
        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextField(
                controller: myController,
              ),
              _error,
              RaisedButton(
                color: _dataColor,
                onPressed: () {
                  setState(() {
                    this.adress = myController.text;
                  });
                },
                child: Text('Testen'), // Todo: Translate
              )
            ],
          ),
        );
      }
    );
  }
}

// ToDo: Create Widgets for the Settings Screen
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
        title: Text("Einstellungen"), // ToDo: Translate
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text("Adresse angeben: (Beginnt mit HTTP(s)://)")
              ],
            ),
            FormWidget(),
            // ToDo: ReadWidget(),
          ],
        )
      ),
    );
  }
}