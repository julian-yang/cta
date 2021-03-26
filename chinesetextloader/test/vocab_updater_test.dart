import 'package:test/test.dart';
import 'package:chineseTextLoader/known_word_uploader/vocab_updater.dart';
import 'package:proto/vocab.pb.dart';

void main() {
  test('Merge vocab merges correctly', () {
    Vocabularies existing = Vocabularies();
    existing.knownWords.addAll([
      Word()..headWord = '1',
      Word()..headWord = '2',
      Word()..headWord = '3',
    ]);

    Vocabularies toAdd = Vocabularies();
    toAdd.knownWords.addAll([
      Word()..headWord = '3',
      Word()..headWord = '4',
      Word()..headWord = '5',
    ]);
    MergeVocabResult result =  mergeVocabLists(existing, toAdd);
    Vocabularies expectedMergedVocabularies = Vocabularies();
    expectedMergedVocabularies.knownWords.addAll([
      Word()..headWord = '1',
      Word()..headWord = '2',
      Word()..headWord = '3',
      Word()..headWord = '4',
      Word()..headWord = '5',
    ]);
    expect(result.merged, expectedMergedVocabularies);
    expect(result.existingWords, ['3']);
    expect(result.newWords, ['4', '5']);
  });
}