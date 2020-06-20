import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../article_wrapper.dart';
import 'package:proto/vocab.pb.dart';
import 'package:proto/article.pb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'article_updater.dart';
import 'vocab_updater.dart';

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
                onPressed: vocab != null ? uploadVocab(context, vocab) : null,
                child: Text('Upload!'))
          ])
        ]));
  }

  List<Widget> _renderVocabularies() => (vocab?.knownWords ?? <Word>[])
      .map((word) => Card(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('${word.headWord} ${word.pinyin}'),
                subtitle: Text(word.definitions.isNotEmpty
                    ? word.definitions.first
                    : 'n/a'),
              )
            ],
          )))
      .toList();

  void _onPickedFile(File file) async {
    List<String> lines = await file.readAsLines(encoding: utf8);
    Vocabularies vocab = Vocabularies();
    List<String> missingDefinitions = [];
    for (String line in lines) {
      print('line: $line');
      List<String> parts = line.split('\t');
      String headWord = parts[0];
      String pinyin = parts[1];
      List<String> definitions = [];
      if (parts.length >= 3) {
        List<String> parseDefinitions = parts[2].split('; ');
//        print('$headWord $pinyin\n');
//        for (String definition in parseDefinitions) {
//          print('* $definition');
//        }
        definitions.add(parts[2]);
      } else {
        print('!!!! No definitions found for $headWord');
        missingDefinitions.add(headWord);
      }
      print('\n');
      Word word = Word()
        ..headWord = headWord
        ..pinyin = pinyin;
      word..definitions.addAll(definitions);
      vocab.knownWords.add(word);
    }
    if (missingDefinitions.isNotEmpty) {
      print('Missing definitions:');
      for (String missing in missingDefinitions) {
        print('* $missing');
      }
    }
    print('----');
    setState(() => this.vocab = vocab);
  }

  List<String> parseDefinition(String definition) {
    List<String> definitions = [];
    for (String token in definition.split(' ')) {
      if (PARTS_OF_SPEECH.contains(token)) {}
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
