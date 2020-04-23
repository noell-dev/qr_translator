import 'dart:convert';
import 'package:flutter/material.dart';

// ToDo: Change name and describe!
class UaWidget extends StatefulWidget {
  final String adress;
  final String jsonString;
  
  final fields = new List();
  final colors = new List();

  UaWidget({
    Key key,
    @required this.adress,
    @required this.jsonString
  }) : super(key: key);


  @override
  _UaWidget createState() => _UaWidget();
}

// ToDo: Change name and describe!
class _UaWidget extends State<UaWidget> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> scheme = jsonDecode(widget.jsonString);
    String seperator = scheme["Trennzeichen"];
    List splittedAdress = widget.adress.split(seperator);

    for (var item in splittedAdress) {
      var searchItem = item.replaceAll(RegExp(r'[0-9]'), '');
      if (scheme["Keys"].containsKey(searchItem)) {
        widget.fields.add(scheme["Keys"][searchItem]);
        widget.colors.add(Colors.green);
      } else {
        var specialChar = splittedAdress.indexOf(item).toString();
        if (scheme["Specials"].containsKey(specialChar)){
          widget.fields.add('${scheme["Specials"][specialChar]}: $item');
          widget.colors.add(Colors.orange);
        } else {
          widget.fields.add("Nicht Erkannt!");
          widget.colors.add(Colors.red);
        }
      }
    }


    return ListView.builder(
      itemCount: splittedAdress.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            '${widget.fields[index]}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.colors[index]),
            ),
          subtitle: Text('${splittedAdress[index]}'),
        );
      },
    );
  }
}

