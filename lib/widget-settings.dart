import 'dart:async';
import 'package:http/http.dart' as http;

// ToDo Implement Settings Screen for Configuration of JSON Scheme
Future<http.Response> fetchPhotos(http.Client client) async {
  return client.get('');
}