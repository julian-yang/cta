import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String chineseTitle;
  final String chineseBody;
  final String englishTitle;
  final String englishBody;
  final String url;
  final DocumentReference reference;
  final DateTime addDate;

  Article.empty()
      : chineseTitle = '',
        chineseBody = '',
        englishTitle = '',
        englishBody = '',
        url = '',
        addDate = DateTime.now(),
        reference = null;

//  Article.fromMap(Map<String, dynamic> map, {this.reference})
//      : assert(map['chineseTitle'] != null),
//        assert(map['chineseBody'] != null),
//        assert(map['englishTitle'] != null),
//        assert(map['englishBody'] != null),
//        assert(map['url'] != null),
//        assert(map['addDate'] != null),
//        chineseTitle = map['chineseTitle'],
//        chineseBody = map['chineseBody'],
//        englishTitle = map['englishTitle'],
//        englishBody = map['englishBody'],
//        url = map['url'],
//        addDate = map['addDate'];

  Article.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['chinese_title'] != null),
        assert(map['chinese_body'] != null),
        assert(map['url'] != null),
        assert(map['add_date'] != null),
        chineseTitle = map['chinese_title'],
        chineseBody = map['chinese_body'],
        englishTitle = map['english_title'] ?? '',
        englishBody = map['english_body'] ?? '',
        url = map['url'],
        addDate = convertTimestamp(map['add_date']);

  Article.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => 'Article<$chineseTitle:$url>';

  static DateTime convertTimestamp(Timestamp timestamp) {
    return DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
  }
}
