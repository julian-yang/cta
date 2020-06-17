import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:proto/vocab.pb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Function _uploadVocab(BuildContext context) => () async {
        Map<String, dynamic> result =
            await Firestore.instance.runTransaction((Transaction tx) async {
          DocumentReference latestVocabListRef = _findLatestVocabList();
          DocumentSnapshot latestVocabListSnapshot =
              await tx.get(latestVocabListRef);
          Vocabularies latestVocabList =
              _parseVocabListFromFirestore(latestVocabListSnapshot.data);
          VocabAndExisting vocabAndExisting =
              _mergeVocabLists(latestVocabList, vocab);
          Object mergedProto3Json = vocabAndExisting.merged.toProto3Json();
          if (latestVocabListSnapshot.exists) {
            await tx.update(latestVocabListRef, mergedProto3Json);
          }
          return {'existingWords': vocabAndExisting.existingWords,
            'merged': vocabAndExisting.merged.writeToJson()
          };
        });

        // Use this way to cast to List<String> since result is actually Map<String, dynamic>
        List<String> existingWords = List<String>.from(result['existingWords']);
        Vocabularies merged = Vocabularies()..mergeFromJson(result['merged']);
        showDialog(
            context: context,
            child: Card(child: _createUploadedDialog(existingWords)));
        print(result);
        print(merged.toProto3Json());
      };

  Widget _createUploadedDialog(List<String> existingWords) => Card(
          child: Column(children: <Widget>[
        Text('Uploaded!'),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.all(8),
                children: _createExistingWordCards(existingWords)))
      ]));

  List<Widget> _createExistingWordCards(List<String> existingWords) =>
      existingWords
          .map((word) => Card(child: Column(children: [Text(word)])))
          .toList();

  Map<String, dynamic> _generateTestMap() {
    Map<String, dynamic> baseMap = {'head_word': '你好', 'pinyin': 'ni2hao3'};
    baseMap['definitions'] = ['${DateTime.now().toIso8601String()}'];
    return baseMap;
  }

  DocumentReference _findLatestVocabList() {
    return Firestore.instance.collection('known_words').document('latest');
  }

  Vocabularies _parseVocabListFromFirestore(Map<String, dynamic> data) {
    // We should be able to merge proto3 directly since we don't have timestamps.
    Vocabularies vocabularies = Vocabularies()..mergeFromProto3Json(data);
    return vocabularies;
  }

  VocabAndExisting _mergeVocabLists(Vocabularies existing, Vocabularies toAdd) {
    // when no mapping function is specified, it uses identity
    Map<String, Word> existingMap =
        Map.fromIterable(existing.knownWords, key: (word) => word.headWord);
    Map<String, Word> toAddMap =
        Map.fromIterable(toAdd.knownWords, key: (word) => word.headWord);
    List<String> existingWords =
        existingMap.keys.where((word) => toAddMap.containsKey(word)).toList();
    existingMap.addAll(toAddMap);
    Vocabularies merged = Vocabularies();
    merged.knownWords.addAll(existingMap.values);
    return VocabAndExisting(merged, existingWords);
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
        List<String> parseDefinitions= parts[2].split('; ');
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

class VocabAndExisting {
  final Vocabularies merged;
  final List<String> existingWords;

  VocabAndExisting(this.merged, this.existingWords);
}
