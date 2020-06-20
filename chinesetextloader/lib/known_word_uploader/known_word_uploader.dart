import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:proto/vocab.pb.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'vocab_updater.dart';

class KnownWordUploader extends StatefulWidget {
  @override
  _KnownWordUploaderState createState() => new _KnownWordUploaderState();
}

class _KnownWordUploaderState extends State<KnownWordUploader> {
  File _pickedFile;
  Vocabularies _vocab;
  bool _showProgress = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ModalProgressHUD(
        inAsyncCall: _showProgress,
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              RaisedButton(
                child: Text('Open file picker'),
                onPressed: () async {
                  File file = await FilePicker.getFile();
                  _onPickedFile(file);
                  setState(() => _pickedFile = file);
                },
              ),
              Text(_pickedFile != null
                  ? 'Picked file: ${_pickedFile.path}'
                  : 'Pick a file!'),
              Expanded(
                  child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: _renderVocabularies())),
              ButtonBar(alignment: MainAxisAlignment.center, children: <Widget>[
                RaisedButton(
                    onPressed:
                        _vocab != null ? () => onUploadPressed(context) : null,
                    child: Text('Upload!')),
              ])
            ])));
  }

  void onUploadPressed(context) async {
    if (_vocab == null) {
      showDialog(
          context: context,
          child: SimpleDialog(title: Text('Upload vocab'), children: <Widget>[
            Text('Please pick a file to extract vocab first.')
          ]));
      return;
    }
    setState(() {
      _showProgress = true;
    });
    VocabAndExisting result = await uploadVocab(context, _vocab);
    setState(() => _showProgress = false);
    showDialog(
        context: context, child: _createUploadedDialog(result.existingWords));
  }

  void onUpdateStatsPressed(context) async {}

  Widget _createUploadedDialog(List<String> existingWords) =>
      SimpleDialog(title: Text('Uploaded!'), children: <Widget>[
        Text('Existing words: '),
        Container(
            width: 400.0,
            height: 500.0,
            child: ListView(
                padding: const EdgeInsets.all(8),
                children: _createExistingWordCards(existingWords)))
      ]);

  List<Widget> _createExistingWordCards(List<String> existingWords) =>
      existingWords
          .map((word) => Card(child: Column(children: [Text(word)])))
          .toList();

  List<Widget> _renderVocabularies() => (_vocab?.knownWords ?? <Word>[])
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
    setState(() => this._vocab = vocab);
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
