import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proto/vocab.pb.dart';
import 'package:collection/collection.dart';
import 'vocabularies_wrapper.dart';
//import 'article_updater.dart';

// Returns the words added.
Future<MergeVocabResult> insertObviousWords(List<String> obviousWords) async {
  try {
    Map<String, dynamic> result =
        await Firestore.instance.runTransaction((Transaction tx) async {
      Set<String> knownWords = Set<String>.from(await VocabulariesWrapper.loadKnownWords());
      // Purposely drop the type here, since if it's empty, Flutter/Java will freak out
      // about casting the type.
      Set filteredObviousCandidates =
          Set.from(obviousWords).difference(knownWords);
      List<Word> wordsToAdd = filteredObviousCandidates
          .map((word) => Word()..headWord = word)
          .toList();
      Vocabularies toAdd = Vocabularies();
      toAdd.knownWords.addAll(wordsToAdd);
      VocabulariesWrapper existingObviousVocab =
          await VocabulariesWrapper.getVocabulariesWrapper(
              VocabulariesWrapper.obviousWordsDocRef, tx: tx);
      MergeVocabResult vocabAndExisting =
          mergeVocabLists(existingObviousVocab.vocabularies, toAdd);
      Object mergedProto3Json = vocabAndExisting.merged.toProto3Json();
      await tx.update(existingObviousVocab.reference, mergedProto3Json);
      return {
        'existingWords': vocabAndExisting.existingWords,
        'newWords': vocabAndExisting.newWords,
        'merged': vocabAndExisting.merged.writeToJson()
      };
    }, timeout: Duration(seconds: 10));

    // Use this way to cast to List<String> since result is actually Map<String, dynamic>
    List<String> existingWords = List<String>.from(result['existingWords']);
    List<String> newWords = List<String>.from(result['newWords']);
    Vocabularies merged = Vocabularies()..mergeFromJson(result['merged']);
    return MergeVocabResult(merged, existingWords, newWords);
  } catch (e) {
    return MergeVocabResult(null, [], []);
  }
}

Future<MergeVocabResult> uploadVocab(
    BuildContext context, Vocabularies vocab) async {
  try {
    Map<String, dynamic> result =
        await Firestore.instance.runTransaction((Transaction tx) async {
      VocabulariesWrapper latestVocab =
          await VocabulariesWrapper.getVocabulariesWrapper(
              VocabulariesWrapper.latestVocabulariesRef,
              tx: tx);
      MergeVocabResult vocabAndExisting =
          mergeVocabLists(latestVocab.vocabularies, vocab);

      Set<String> knownWords = Set.from(vocabAndExisting.merged.knownWords
          .map((word) => word.headWord)
          .toList());
      Set<String> hskWords = await VocabulariesWrapper.loadHskWords();
      knownWords.addAll(hskWords);

//    List<DocumentReference> articleReferences =
//        await getArticleReferencesFromFirestore();
//    List<Future<ArticleComparison>> comparisonFutures = articleReferences
//        .take(2)
//        .map((articleRef) => updateArticleStats(tx, articleRef, knownWords))
//        .toList();
//    await Future.wait(comparisonFutures);

      Object mergedProto3Json = vocabAndExisting.merged.toProto3Json();
      await tx.update(latestVocab.reference, mergedProto3Json);

      return {
        'existingWords': vocabAndExisting.existingWords,
        'newWords': vocabAndExisting.newWords,
        'merged': vocabAndExisting.merged.writeToJson()
      };
    }, timeout: Duration(seconds: 10));

    // Use this way to cast to List<String> since result is actually Map<String, dynamic>
    List<String> existingWords = List<String>.from(result['existingWords']);
    List<String> newWords = List<String>.from(result['newWords']);
    Vocabularies merged = Vocabularies()..mergeFromJson(result['merged']);
    return MergeVocabResult(merged, existingWords, newWords);
  } catch (e) {
    return MergeVocabResult(null, [], []);
  }
//      print(result);
//      print(merged.toProto3Json());
}

Map<String, dynamic> _generateTestMap() {
  Map<String, dynamic> baseMap = {'head_word': '你好', 'pinyin': 'ni2hao3'};
  baseMap['definitions'] = ['${DateTime.now().toIso8601String()}'];
  return baseMap;
}

@visibleForTesting
MergeVocabResult mergeVocabLists(Vocabularies existing, Vocabularies toAdd) {
  // when no mapping function is specified, it uses identity
  Map<String, Word> existingMap =
      Map.fromIterable(existing.knownWords, key: (word) => word.headWord);
  Map<String, Word> toAddMap =
      Map.fromIterable(toAdd.knownWords, key: (word) => word.headWord);
  Set<String> toAddSet = toAddMap.keys.toSet();
  Set<String> existingSet = existingMap.keys.toSet();
  List<String> existingWords =
      existingMap.keys.where((word) => toAddMap.containsKey(word)).toList();
  existingMap.addAll(toAddMap);
  Vocabularies merged = Vocabularies();
  merged.knownWords.addAll(existingMap.values);
  return MergeVocabResult(merged, existingSet.intersection(toAddSet).toList(),
      toAddSet.difference(existingSet).toList());
}

class MergeVocabResult {
  final Vocabularies merged;
  final List<String> existingWords;
  final List<String> newWords;

  MergeVocabResult(this.merged, this.existingWords, this.newWords);
}
