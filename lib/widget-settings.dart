import 'dart:async';
import 'package:http/http.dart' as http;

Future<http.Response> fetchPhotos(http.Client client) async {
  return client.get('https://ip.noell.li/schema.json');
}