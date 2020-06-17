import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:proto/vocab.pb.dart';

class KnownWordUploader extends StatefulWidget {
  @override
  _KnownWordUploaderState createState() => new _KnownWordUploaderState();
}

class _KnownWordUploaderState extends State<KnownWordUploader> {
  File pickedFile;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          RaisedButton(
            child: Text('Open file picker'),
            onPressed: () async {
              File file = await FilePicker.getFile();
              _onPickedFile(file);
              setState(() => pickedFile = file);
            },
          ),
          Text(pickedFile != null
              ? 'Picked file: ${pickedFile.path}'
              : 'Pick a file!')
        ]));
  }

  void _onPickedFile(File file) async {
    List<String> lines = await file.readAsLines(encoding: utf8);
    XmlDocument xmlDocument = parse(lines.join(' '));
    List<XmlElement> cards = xmlDocument.findAllElements("card").toList();
    for (XmlElement card in cards) {
      XmlElement entry = card.findElements("entry").first;
    }

//    for (String line in lines) {
//      List<String> parts = line.split('\t');
//      String word = parts[0];
//      String pinyin = parts[1];
//      List<String> definitions = parts[2].split('; ');
//      print('$word $pinyin\n');
//      for (String definition in definitions) {
//        print('* $definition');
//      }
//      print('\n');
//    }
//    var blah = 1;
  }
}



