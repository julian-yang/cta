import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proto/article.pb.dart';

class ArticleWrapper {
  final Article article;
  final DocumentReference reference;

  ArticleWrapper.fromSnapshot(DocumentSnapshot snapshot)
      : article = snapshotToArticle(snapshot), reference = snapshot.reference;


  @override
  String toString() => 'ArticleWrapper<$article:$reference>';

  static Article snapshotToArticle(DocumentSnapshot snapshot) {
    Map<String, dynamic> converted = snapshot.data.map(maybeConvertTimestamp);
    Article article = Article()..mergeFromProto3Json(converted);
    return article;
  }

  static MapEntry<String, dynamic> maybeConvertTimestamp(String key, dynamic value) =>
      (value is Timestamp)
          ? MapEntry(key, value.toDate().toUtc().toIso8601String())
          : MapEntry(key, value);

  static Map<String, dynamic> convertTimestampEntry(
      Map<String, dynamic> data) =>
      data.map((key, value) =>
      (value is Timestamp)
          ? MapEntry(key, value.toDate().toUtc().toIso8601String())
          : MapEntry(key, value)
      );

  static DateTime convertTimestamp(Timestamp timestamp) {
    return DateTime.fromMicrosecondsSinceEpoch(
        timestamp.microsecondsSinceEpoch);
  }

  static dynamic customEncoder(dynamic value) {
    if (value is Timestamp) {
      return {'seconds': value.seconds, 'nanoseconds': value.nanoseconds};
    } else {
      return value;
    }
  }

//  DateTime addDate() =>
//  DateTime.fromMicrosecondsSinceEpoch();

}
