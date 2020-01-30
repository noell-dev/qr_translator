import 'dart:convert';
import 'package:flutter/material.dart';



class UaWidget extends StatefulWidget {
  final String adress;

  final fields = new List();

  UaWidget({Key key, @required this.adress}) : super(key: key);

  @override
  _UaWidget createState() => _UaWidget();
}


class _UaWidget extends State<UaWidget> {

  Map<String, dynamic> scheme = jsonDecode(jsonString);

  @override
  Widget build(BuildContext context) {
    String seperator = scheme["Trennzeichen"];
    List splittedAdress = widget.adress.split(seperator);
    for (var item in splittedAdress) {
      var searchItem = item.replaceAll(RegExp(r'[0-9]'), '');
      if (scheme["Keys"].containsKey(searchItem)) {
        widget.fields.add(scheme["Keys"][searchItem]);
      } else {
        var specialChar = splittedAdress.indexOf(item).toString();
        if (scheme["Specials"].containsKey(specialChar)){
          widget.fields.add('${scheme["Specials"][specialChar]}: $item');
        } else {
          widget.fields.add("Nicht Erkannt!");
        }
      }
    }
    return ListView.builder(
      itemCount: splittedAdress.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${widget.fields[index]}'),
          subtitle: Text('${splittedAdress[index]}'),
        );
      },
    );
  }
}

