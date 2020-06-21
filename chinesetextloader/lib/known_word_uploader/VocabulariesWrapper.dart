import 'package:proto/vocab.pb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VocabulariesWrapper {
  final Vocabularies vocabularies;
  final DocumentReference reference;

  List<String> get headWords =>
      vocabularies.knownWords.map((word) => word.headWord).toList();

  VocabulariesWrapper._(this.vocabularies, this.reference);

  static DocumentReference get latestVocabulariesRef =>
    Firestore.instance.collection('known_words').document('latest');


  static Future<VocabulariesWrapper> getLatestVocabulariesWrapper(
      {Transaction tx}) async {
    DocumentSnapshot latestVocabListSnapshot = tx != null
        ? await tx.get(latestVocabulariesRef)
        : Firestore.instance.document(latestVocabulariesRef.path);
    if (latestVocabListSnapshot.exists) {
      Vocabularies latestVocabularies =
      _parseVocabListFromFirestore(latestVocabListSnapshot.data);
      return VocabulariesWrapper._(latestVocabularies, latestVocabulariesRef);
    } else {
      return null;
    }
  }

  static Vocabularies _parseVocabListFromFirestore(Map<String, dynamic> data) {
    // We should be able to merge proto3 directly since we don't have timestamps.
    Vocabularies vocabularies = Vocabularies()..mergeFromProto3Json(data);
    return vocabularies;
  }


  static DocumentReference _hskDocumentRef() =>
      Firestore.instance.collection('known_words').document('hsk');

  static Future<Set<String>> loadHskWords() async {
    DocumentSnapshot snapshot = await _hskDocumentRef().get();
    if (!snapshot.exists) {
      print('******!!!!! MISSING HSK woRDS');
      return {};
    }

    Vocabularies hskVocabularies = Vocabularies()
      ..mergeFromProto3Json(snapshot.data);
    List<String> hskWords =
    hskVocabularies.knownWords.map((word) => word.headWord).toList();
    return Set.from(hskWords);
  }

}
