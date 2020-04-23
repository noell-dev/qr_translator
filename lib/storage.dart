import 'dart:io';
import 'package:path_provider/path_provider.dart';


const schemeFilename = "scheme.json";
const saveFilename = "save.json";

// Storage Actions: Done!
class JsonStorage {

  String _filename;
  // Get the Local Path on both Platforms
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Provide the json File as a File Object to read and Write
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_filename');
  }

  // Write newly fetched JSON String
  Future<File> writeJsonStore(String jsonString, bool isScheme) async {
    if (isScheme) {
      this._filename = schemeFilename;
    } else {
      this._filename = saveFilename;
    }
    final file = await _localFile;
    return file.writeAsString('$jsonString');
  }

  Future<String> readJsonStore(bool isScheme) async {
    if (isScheme) {
      this._filename = schemeFilename;
    } else {
      this._filename = saveFilename;
    }
    try {
      final file = await _localFile;

      // Read the File
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "file_error";
    }
  }
}

