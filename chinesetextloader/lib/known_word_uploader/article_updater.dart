import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../article_wrapper.dart';
import 'package:proto/article.pb.dart';

Future<List<ArticleComparison>> updateAllArticleStats(
    BuildContext context, Set<String> knownWords) async {
  List<DocumentReference> articles = await getArticleReferencesFromFirestore();
  return Future.wait(articles
      .map((articleRef) => updateArticleStatsTx(context, articleRef, knownWords))
      .toList());
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
  articleWrapper.article.stats.knownRatio = knownWordCount.toDouble() /
      articleWrapper.article.segmentation.length.toDouble();
  articleWrapper.article.stats.uniqueKnownRatio =
      uniqueKnownArticleWords.length.toDouble() / uniqueArticleWords.length;
  return ArticleComparison(articleWrapper.reference,
      oldArticle: oldArticle, newArticle: articleWrapper.article);
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

  ArticleComparison.fromMapResult(Map<String, String> result)
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
