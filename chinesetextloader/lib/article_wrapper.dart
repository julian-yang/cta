import 'utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proto/article.pb.dart';

class ArticleWrapper {
  final Article article;
  final DocumentReference reference;

  ArticleWrapper.fromSnapshot(DocumentSnapshot snapshot)
      : article = snapshotToArticle(snapshot),
        reference = snapshot.reference;

  @override
  String toString() => 'ArticleWrapper<$article:$reference>';

  static Article snapshotToArticle(DocumentSnapshot snapshot) {
    Map<String, dynamic> converted = snapshot.data.map(maybeConvertTimestamp);
    Article article = Article()..mergeFromProto3Json(converted);
    return article;
  }

  static MapEntry<String, dynamic> maybeConvertTimestamp(
          String key, dynamic value) =>
      (value is Timestamp)
          ? MapEntry(key, value.toDate().toUtc().toIso8601String())
          : MapEntry(key, value);

  static Map<String, dynamic> convertTimestampEntry(
          Map<String, dynamic> data) =>
      data.map((key, value) => (value is Timestamp)
          ? MapEntry(key, value.toDate().toUtc().toIso8601String())
          : MapEntry(key, value));

  static dynamic customEncoder(dynamic value) {
    if (value is Timestamp) {
      return {'seconds': value.seconds, 'nanoseconds': value.nanoseconds};
    } else {
      return value;
    }
  }

  static int compareAddDate(ArticleWrapper a, ArticleWrapper b) =>
      convertTimestamp(a.article.addDate)
          .compareTo(convertTimestamp(b.article.addDate));

  ArticleProperty get key => ArticleProperty(article.url, article.url);

  static String getArticleTitle(ArticleWrapper a) => a.article.chineseTitle;
  static int getTotalWords(ArticleWrapper a) => a.article.wordCount;

  static int getUnknownWords(ArticleWrapper a) => unknownWordCount(a.article);

  static double getKnownRatio(ArticleWrapper a) => a.article.stats.knownRatio;

  static String getKnownRatioAsPercentage(ArticleWrapper a) =>
      '${(a.article.stats.knownRatio * 100).toStringAsFixed(1)}%';

  static double getAverageWordDifficulty(ArticleWrapper a) =>
      a.article.averageWordDifficulty;

  static String getAverageWordDifficultyStr(ArticleWrapper a) =>
      a.article.averageWordDifficulty.toStringAsFixed(2);

//  DateTime addDate() =>
//  DateTime.fromMicrosecondsSinceEpoch();

}

class ArticleProperty {
  final String display;
  final dynamic value;

//  ArticleProperty(this.value) : this.display = value.toString();
  ArticleProperty(this.value, this.display);
}
