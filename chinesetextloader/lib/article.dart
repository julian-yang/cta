import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String chineseTitle;
  final String chineseBody;
  final String englishTitle;
  final String englishBody;
  final String url;
  final DocumentReference reference;

  Article.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['chineseTitle'] != null),
        assert(map['chineseBody'] != null),
        assert(map['englishTitle'] != null),
        assert(map['englishBody'] != null),
        assert(map['url'] != null),
        chineseTitle = map['chineseTitle'],
        chineseBody = map['chineseBody'],
        englishTitle = map['englishTitle'],
        englishBody = map['englishBody'],
        url = map['url'];

  Article.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => 'Article<$chineseTitle:$url>';
}
