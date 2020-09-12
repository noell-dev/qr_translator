import 'package:flutter/material.dart';
import 'package:qr_translator/localization.dart';
import 'package:flutter_matomo/flutter_matomo.dart';

/// The Widget to slice and display the codes scanned and passed through the QR-Scanner
/// It expects to strings, adress and jsonString:
///   adress: this is the adress previously scanned from an QR-Code.
///   jsonString: this is the currently loaded json definition of what abbreviation or adress-part corresponds to which human-readable text.
/// 
/// It builds the UI displaying a translated adress (currently in ListTiles)
/// All the translation work is also done within the build method,
/// maybe this should be threaded into another non-UI method if the UI becomes slow with huge strings and JSON files.
/// ToDo: Test for performance in huge definitions
/// 

class SimpleCodeTranslationWidget extends StatelessWidget {

  final String adress;
  final Map<String, dynamic> scheme;
  
  final fields = new List();
  final colors = new List();

  SimpleCodeTranslationWidget({
    Key key,
    @required this.adress,
    @required this.scheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String seperator = scheme["Separator"];
    List splittedAdress = adress.split(seperator);

    for (var item in splittedAdress) {
      var searchItem = item.replaceAll(RegExp(r'[0-9]'), '');
      if (scheme["Keys"].containsKey(searchItem)) {
        fields.add(scheme["Keys"][searchItem]);
        colors.add(Colors.green);
      } else {
        var specialChar = splittedAdress.indexOf(item).toString();
        if (scheme["Specials"].containsKey(specialChar)){
          fields.add('${scheme["Specials"][specialChar]}: $item');
          colors.add(Colors.orange);
        } else {
          fields.add("Nicht Erkannt!");
          colors.add(Colors.red);
        }
      }
    }


    return ListView.builder(
      itemCount: splittedAdress.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            '${fields[index]}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors[index]),
            ),
          subtitle: Text('${splittedAdress[index]}'),
        );
      },
    );
  }
}

class Entry {
  String codePart;
  String description;
  Color color;
  String clearText;

  Entry({
    this.codePart,
    this.description,
    this.color,
    this.clearText,
  });
}

class ExtendetCodeTranslationWidget extends StatelessWidget {

  final String code;
  final Map<String, dynamic> scheme;
  final bool showHelp;
  final bool colorActivated;
  
  final entries = {};

  

  ExtendetCodeTranslationWidget({
    Key key,
      @required this.code,
      @required this.scheme,
      @required this.showHelp,
      @required this.colorActivated,
    }) : super(key: key);

  bool _validateCode (codePart, schemePart, dependList) {
    var parts = scheme["parts"];

    var type = parts[schemePart]["type"];
    var depends_on = parts[schemePart]["depends_on"];
    var possible_values;

    bool _isValid = false;

    if (type == "integer") {
      try{
        var value = double.parse(codePart);
      } on FormatException {
        _isValid =  false;
      } finally {
        _isValid =  true;
      }
    } else {
      if (depends_on != null){
        possible_values = parts[schemePart]["possible_values"][dependList[depends_on]];
      } else {
        possible_values = parts[schemePart]["possible_values"];
      }
      try {
        var value = possible_values[codePart];
      } catch (e) {
        _isValid =  false;
      } finally {
        _isValid =  true;
      }
    }
    return _isValid;
  }

  Future<void> _trackCode(String name, String action) async {
    await FlutterMatomo.trackEventWithName("Home", name, action);
  }

  @override
  Widget build(BuildContext context) {
    var parts = scheme["parts"];
    int position = 0;

    if (!scheme["possible_lengths"].contains(code.length)){
      _trackCode("CodeTranslation", "Wrong Lenght");
      return ListTile(
          title: Text(
            AppLocalizations.of(context).translate('wronglength'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red),
            ),
            subtitle: Text(code),
        );
    }

    Map<int, List> newOrder = {0: []};
    int pos = 0;
    for (var item in scheme["order"]){
      if (item == "Trennzeichen") {
        pos += 1;
        newOrder[pos] = [];
      } else {
        newOrder[pos].add(item);
      }
    }


    var splitted_code = code.split(parts["Trennzeichen"]["possible_values"][0]);
    pos = 0;
    Map<String, String> dependet = {};
    for (var code_part in splitted_code) {
      entries[pos] = new List();
      position = 0;
      for (var i in newOrder[pos]) {
        int length = parts[i]["length"];    
        var description = parts[i]["description"];
        var part_substring = code_part.substring(position, position + length);

        if (parts[i]["dependet_on"]) {
          dependet[i] = part_substring;
        }


        if (_validateCode(part_substring, i, dependet)) {
          var depends_on = parts[i]["depends_on"];
          var possible_values;
          var type = parts[i]["type"];
          var clearText;
          if (depends_on != null){
            possible_values = parts[i]["possible_values"][dependet[depends_on]];
          } else {
            possible_values = parts[i]["possible_values"];
          }
          try {
            clearText = possible_values[part_substring];
          } catch (e){
            clearText = "";
          }
          entries[pos].add(Entry(
            codePart: part_substring,
            description: description,
            color: type == "integer" ? Colors.orange : Colors.green,
            clearText: clearText,
          ));
        } else {
          entries[pos].add(Entry(
            codePart: part_substring,
            description: description,
            color: Colors.red,
          ));
        }
        position += length;
      }

      pos += 1;
    }
      

    return ListView.separated(
      // physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        List posEntries = entries[index];
        List<TextSpan> descriptions = [];
        List<TextSpan> codeParts = [];
        List<TextSpan> clearTexts = [];

        for (Entry entry in posEntries){
          if (descriptions.length >= 1){
            descriptions.add(TextSpan(
              text: "\n",
              style: TextStyle(
                color: Colors.black,
                //fontWeight: FontWeight.bold,
              )
            ));
          }
          descriptions.add(TextSpan(
            text: entry.description,
            style: TextStyle(
              color: colorActivated ? entry.color : Colors.black,
              //fontWeight: FontWeight.bold,
            )
          ));
          codeParts.add(TextSpan(
            text: entry.codePart,
            style: TextStyle(
              color: entry.color,
              fontWeight: FontWeight.bold,
            )
          ));
          clearTexts.add(TextSpan(
            text: entry.clearText,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )
          ));
        }
        Widget tile = ListTile(
          title: RichText(text: TextSpan(children: clearTexts),),
          subtitle: RichText(text: TextSpan(children: descriptions),),
          leading: Container(
            alignment: Alignment.centerLeft,
            width: 80,
            child: RichText(text: TextSpan(children: codeParts),)
          ),
        );
        if (index == 0 && showHelp){
          return Column(
            children: <Widget>[
              ListTile(
                title: RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(context).translate('clearText'),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(context).translate('description'),
                    style: TextStyle(
                      color: Colors.black,
                    )
                  ),
                ),
                leading: Container(
                  alignment: Alignment.centerLeft,
                  width: 80,
                  child: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context).translate('code'),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ),
                trailing: Icon(Icons.help)
              ),
              Divider(),
              tile,
            ]
          );
        } else {
          return tile;
        }

      },
      separatorBuilder: (context, index){
        return Divider();
      },
    );
  }
}