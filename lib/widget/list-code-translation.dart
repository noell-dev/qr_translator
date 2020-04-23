import 'dart:convert';
import 'package:flutter/material.dart';

/// The Widget to slice and display the codes scanned and passed through the QR-Scanner
/// It expects to strings, adress and jsonString:
///   adress: this is the adress previously scanned from an QR-Code.
///   jsonString: this is the currently loaded json definition of what abbreviation or adress-part corresponds to which human-readable text.
/// 
class ListCodeTranslationWidget extends StatefulWidget {
  final String adress;
  final String jsonString;
  
  final fields = new List();
  final colors = new List();

  ListCodeTranslationWidget({
    Key key,
    @required this.adress,
    @required this.jsonString
  }) : super(key: key);


  @override
  _ListCodeTranslationWidget createState() => _ListCodeTranslationWidget();
}


/// This is the State-Implementation of the ListCodeTranslationWidget
/// It builds the UI displaying a translated adress (currently in ListTiles)
/// All the translation work is also done within the build method,
/// maybe this should be threaded into another non-UI method if the UI becomes slow with huge strings and JSON files.
/// ToDo: Test for performance in huge definitions
class _ListCodeTranslationWidget extends State<ListCodeTranslationWidget> {
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

