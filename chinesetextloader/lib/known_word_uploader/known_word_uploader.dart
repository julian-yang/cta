import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:proto/vocab.pb.dart';

class KnownWordUploader extends StatefulWidget {
  @override
  _KnownWordUploaderState createState() => new _KnownWordUploaderState();
}

class _KnownWordUploaderState extends State<KnownWordUploader> {
  File pickedFile;
  Vocabularies vocab;

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
              : 'Pick a file!'),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: _renderVocabularies())),
          ButtonBar(alignment: MainAxisAlignment.center, children: <Widget>[
            RaisedButton(
                onPressed: vocab != null ? _uploadVocab(context) : null,
                child: Text('Upload!'))
          ])
        ]));
  }

  Function _uploadVocab(BuildContext context) => () {

        showDialog(context: context, child: Text('Upload!'));
      };

  List<Widget> _renderVocabularies() => (vocab?.knownWords ?? <Word>[])
      .map((word) => Card(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('${word.headWord} ${word.pinyin}'),
                subtitle: Text(word.definition.first),
              )
            ],
          )))
      .toList();

  void _onPickedFile(File file) async {
    List<String> lines = await file.readAsLines(encoding: utf8);
    Vocabularies vocab = Vocabularies();
    for (String line in lines) {
      List<String> parts = line.split('\t');
      String headWord = parts[0];
      String pinyin = parts[1];
      List<String> definitions = parts[2].split('; ');
      print('$headWord $pinyin\n');
      for (String definition in definitions) {
        print('* $definition');
      }
      print('\n');
      Word word = Word()
        ..headWord = headWord
        ..pinyin = pinyin;
      word..definition.add(parts[2]);
      vocab.knownWords.add(word);
    }
    setState(() => this.vocab = vocab);
  }

  List<String> parseDefinition(String definition) {
    List<String> definitions = [];
    for (String token in definition.split(' ')) {
      if (PARTS_OF_SPEECH.contains(token)) {

      }
    }
  }

  static const Set<String> PARTS_OF_SPEECH = {
    "noun",
    "pronoun",
    "adjective",
    "determiner",
    "verb",
    "adverb",
    "preposition",
  };
}
