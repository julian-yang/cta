import 'package:chineseTextLoader/known_word_uploader/vocab_updater.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../article_wrapper.dart';
import 'package:proto/article.pb.dart';
import 'package:proto/vocab.pb.dart';
import 'dart:convert';

import 'VocabulariesWrapper.dart';

Future<List<ArticleComparison>> updateAllArticleStats() async {
  try {
    Map<String, dynamic> rawResult =
        await Firestore.instance.runTransaction((Transaction tx) async {
      VocabulariesWrapper latestVocab =
          await VocabulariesWrapper.getLatestVocabulariesWrapper(tx: tx);
      Set<String> knownWords = Set.from(latestVocab.headWords);
      Set<String> hskWords = await VocabulariesWrapper.loadHskWords();
      knownWords.addAll(hskWords);

      List<DocumentReference> articles =
          await getArticleReferencesFromFirestore();
      List<ArticleComparison> results = await Future.wait(articles
//          .take(1)
          .map((articleRef) => updateArticleStats(tx, articleRef, knownWords))
          .toList());
      await tx.update(
          latestVocab.reference, latestVocab.vocabularies.toProto3Json());
      return {
        'result': results.map((comparison) => comparison.toMapResult()).toList()
      };
    }, timeout: Duration(seconds: 20));
    List<ArticleComparison> results = [];
    for (Map result in rawResult['result']) {
      ArticleComparison comparison = ArticleComparison.fromMapResult(result);
      results.add(comparison);
    }
    // I have no idea why i can't use map...
//    List<ArticleComparison> results2 = rawResult['result']
//        .map((c) => ArticleComparison.fromMapResult(c))
//        .toList();
    return results;
  } catch (e) {
    return [];
  }
}

// TODO: calculate what changed
Future<ArticleComparison> updateArticleStatsTx(BuildContext context,
    DocumentReference articleRef, Set<String> knownWords) async {
  Map<String, String> result =
      await Firestore.instance.runTransaction((Transaction tx) async {
    ArticleComparison comparison =
        await updateArticleStats(tx, articleRef, knownWords);
    return comparison.toMapResult();
  }, timeout: Duration(seconds: 10));

  return ArticleComparison.fromMapResult(result);
}

Future<ArticleComparison> updateArticleStats(Transaction tx,
    DocumentReference articleRef, Set<String> knownWords) async {
  DocumentSnapshot articleSnapshot = await tx.get(articleRef);
  if (articleSnapshot.exists) {
    ArticleWrapper articleWrapper =
        ArticleWrapper.fromSnapshot(articleSnapshot);
    ArticleComparison comparison =
        _updateArticleCalculations(articleWrapper, knownWords);
    await tx.update(articleRef, articleWrapper.article.toProto3Json());
    return comparison;
  } else {
    print('Could not update article: ${articleRef.path}');
    return ArticleComparison.fromFailure(articleRef);
  }
}

ArticleComparison _updateArticleCalculations(
    ArticleWrapper articleWrapper, Set<String> knownWords) {
  Set<String> uniqueArticleWords =
      Set.from(articleWrapper.article.segmentation);
  Set<String> uniqueKnownArticleWords =
      knownWords.intersection(uniqueArticleWords);
  Map<String, int> histogram = {};
  for (String word in articleWrapper.article.segmentation) {
    histogram.update(word, (value) => value + 1, ifAbsent: () => 1);
  }
  int knownWordCount = uniqueKnownArticleWords
      .map((word) => histogram[word])
      .fold(0, (a, b) => a + b);

  Article oldArticle = articleWrapper.article.clone();
  articleWrapper.article.stats = articleWrapper.article.stats.clone();
  articleWrapper.article.stats.knownWordCount = knownWordCount;
  articleWrapper.article.stats.knownRatio = safeDivide(
      knownWordCount.toDouble(),
      articleWrapper.article.segmentation.length.toDouble());
  articleWrapper.article.stats.uniqueKnownRatio = safeDivide(
      uniqueKnownArticleWords.length.toDouble(), uniqueArticleWords.length);
  return ArticleComparison(articleWrapper.reference,
      oldArticle: oldArticle, newArticle: articleWrapper.article);
}

double safeDivide(a, b) {
  return b != 0 ? a / b : 0;
}

class ArticleComparison {
  final Article newArticle;
  final Article oldArticle;
  final DocumentReference ref;
  final bool success;

  static final String _newArticleKey = 'newArticle';
  static final String _oldArticleKey = 'oldArticle';

  // Should contain the path to the reference.
  static final String _refKey = 'ref';

  ArticleComparison(this.ref, {Article oldArticle, Article newArticle})
      : this.oldArticle = oldArticle,
        this.newArticle = newArticle,
        this.success = true;

  ArticleComparison.fromFailure(this.ref)
      : this.oldArticle = Article(),
        this.newArticle = Article(),
        this.success = false;

  ArticleComparison.fromMapResult(Map<dynamic, dynamic> result)
      : this.oldArticle = Article()..mergeFromJson(result[_oldArticleKey]),
        this.newArticle = Article()..mergeFromJson(result[_newArticleKey]),
        this.ref = Firestore.instance.document(result[_refKey]),
        this.success = true;

  Map<String, String> toMapResult() => {
        _newArticleKey: newArticle.writeToJson(),
        _oldArticleKey: oldArticle.writeToJson(),
        _refKey: ref.path
      };
}

Future<List<DocumentReference>> getArticleReferencesFromFirestore() async {
  QuerySnapshot querySnapshot =
      await Firestore.instance.collection('scraped_articles').getDocuments();
  return querySnapshot.documents
      .map((documentSnapshot) => documentSnapshot.reference)
      .toList();
}

Future<List<ArticleWrapper>> _getArticlesFromFirestore() async {
  QuerySnapshot querySnapshot =
      await Firestore.instance.collection('scraped_articles').getDocuments();
  return querySnapshot.documents
      .map((documentSnapshot) => ArticleWrapper.fromSnapshot(documentSnapshot))
      .toList();
}
