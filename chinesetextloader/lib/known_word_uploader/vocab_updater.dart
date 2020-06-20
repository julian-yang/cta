import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proto/vocab.pb.dart';
import 'article_updater.dart';

Function uploadVocab(BuildContext context, Vocabularies vocab) => () async {
      Map<String, dynamic> result =
          await Firestore.instance.runTransaction((Transaction tx) async {
        DocumentReference latestVocabListRef = _findLatestVocabList();
        DocumentSnapshot latestVocabListSnapshot =
            await tx.get(latestVocabListRef);
        Vocabularies latestVocabList =
            _parseVocabListFromFirestore(latestVocabListSnapshot.data);
        VocabAndExisting vocabAndExisting =
            _mergeVocabLists(latestVocabList, vocab);

        Set<String> knownWords = Set.from(vocabAndExisting.merged.knownWords
            .map((word) => word.headWord)
            .toList());
        VocabAndExisting hskWords = await _loadHskWords();
        knownWords.addAll(hskWords.existingWords);

        List<DocumentReference> articleReferences =
            await getArticleReferencesFromFirestore();
        List<Future<ArticleComparison>> comparisonFutures = articleReferences
            .map((articleRef) => updateArticleStats(tx, articleRef, knownWords))
            .toList();
        await Future.wait(comparisonFutures);

        Object mergedProto3Json = vocabAndExisting.merged.toProto3Json();
        if (latestVocabListSnapshot.exists) {
          await tx.update(latestVocabListRef, mergedProto3Json);
        }

        return {
          'existingWords': vocabAndExisting.existingWords,
          'merged': vocabAndExisting.merged.writeToJson()
        };
      }, timeout: Duration(seconds: 10));

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

DocumentReference _hskDocumentRef() =>
    Firestore.instance.collection('known_words').document('hsk');

Future<VocabAndExisting> _loadHskWords() async {
  DocumentSnapshot snapshot = await _hskDocumentRef().get();
  if (!snapshot.exists) {
    print('******!!!!! MISSING HSK woRDS');
    return VocabAndExisting(Vocabularies(), []);
  }

  Vocabularies hskVocabularies = Vocabularies()
    ..mergeFromProto3Json(snapshot.data);
  List<String> hskWords =
      hskVocabularies.knownWords.map((word) => word.headWord).toList();
  return VocabAndExisting(hskVocabularies, hskWords);
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

class VocabAndExisting {
  final Vocabularies merged;
  final List<String> existingWords;

  VocabAndExisting(this.merged, this.existingWords);
}
