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

  static DocumentReference get obviousWordsDocRef =>
      Firestore.instance.collection('known_words').document('obvious');

  static Future<VocabulariesWrapper> getVocabulariesWrapper(DocumentReference docRef,
      {Transaction tx}) async {
    DocumentSnapshot vocabulariesSnapshot = tx != null
        ? await tx.get(docRef)
        : await Firestore.instance.document(docRef.path).get();
    if (vocabulariesSnapshot.exists) {
      Vocabularies latestVocabularies =
      _parseVocabListFromFirestore(vocabulariesSnapshot.data);
      return VocabulariesWrapper._(latestVocabularies, docRef);
    } else {
      return null;
    }
  }

  static Vocabularies _parseVocabListFromFirestore(Map<String, dynamic> data) {
    // We should be able to merge proto3 directly since we don't have timestamps.
    Vocabularies vocabularies = Vocabularies()..mergeFromProto3Json(data);
    return vocabularies;
  }

  static Future<Set<String>> loadKnownWordsDocument(DocumentReference docRef, {Transaction tx}) async {
    DocumentSnapshot snapshot =
        await (tx != null ? tx.get(docRef) : docRef.get());
    if (!snapshot.exists) {
      return {};
    }
    Vocabularies existingVocabularies = Vocabularies()
      ..mergeFromProto3Json(snapshot.data);
    List<String> uniqueWords =
    existingVocabularies.knownWords.map((word) => word.headWord).toList();
    return Set.from(uniqueWords);
  }

  static Future<Set<String>> loadHskWords() async {
    DocumentReference hskDocRef = Firestore.instance.collection('known_words').document('hsk');
    return loadKnownWordsDocument(hskDocRef);
  }

  static Future<Set<String>> loadObviousWords() async {
    DocumentReference obviousDocRef = obviousWordsDocRef;
    return loadKnownWordsDocument(obviousDocRef);
  }

  static Future<Set<String>> loadKnownWords() async {
    VocabulariesWrapper latest = await VocabulariesWrapper.getVocabulariesWrapper(latestVocabulariesRef);
    Set<String> knownWords = Set.from(latest.headWords);
    print('Latest size: ${knownWords.length}');
    Set<String> hskWords = await loadHskWords();
    print('Hsk size: ${hskWords.length}');
    knownWords.addAll(hskWords);
    Set<String> obviousWords = await loadObviousWords();
    knownWords.addAll(obviousWords);
    print('Obvious size: ${obviousWords.length}');
    print('Total size: ${knownWords.length}');
    return knownWords;
  }
}
