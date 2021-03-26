import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'vocabularies_wrapper.dart';
import 'package:chineseTextLoader/article_wrapper.dart';
import 'package:proto/vocab.pb.dart';

class WordFrequency {
  final Map<String, ArticleWrapper> urlToArticle;
  final String word;
  int occurences;

  WordFrequency({@required String word})
      : this.word = word,
        this.occurences = 0,
        urlToArticle = {};

  static Stream<List<WordFrequency>> getObviousWordsStream() {
    Stream<List<WordFrequency>> histogramStream = Firestore.instance
        .collection('scraped_articles')
        .getDocuments()
        .asStream()
        .transform(StreamTransformer.fromHandlers(
            handleData: (snapshot, sink) {
              sink.add(generateWordHistogram(snapshot));
            },
            handleError: (error, stacktrace, sink) {
              sink.addError(error, stacktrace);
            },
            handleDone: (sink) => sink.close()));
    Stream<Vocabularies> obviousWordsStream =
        VocabulariesWrapper.obviousWordsDocRef.snapshots().map((snapshot) =>
            VocabulariesWrapper.parseVocabListFromFirestore(snapshot.data));
    return histogramStream.combineLatest(obviousWordsStream,
        (List<WordFrequency> histogram, Vocabularies vocab) {
      Set<String> obviousWords =
          vocab.knownWords.map((word) => word.headWord).toSet();
      return histogram
          .where((wordFrequency) => obviousWords.contains(wordFrequency.word))
          .toList();
    });
  }

  static Future<List<WordFrequency>> getWordHistogram() async {
    QuerySnapshot articlesSnapshot =
        await Firestore.instance.collection('scraped_articles').getDocuments();
    return generateWordHistogram(articlesSnapshot);
  }

  static List<WordFrequency> generateWordHistogram(
      QuerySnapshot articlesSnapshot) {
    List<ArticleWrapper> articles = articlesSnapshot.documents
        .map(
            (documentSnapshot) => ArticleWrapper.fromSnapshot(documentSnapshot))
        .toList();
    Map<String, WordFrequency> wordFrequencyMapping = {};
    for (ArticleWrapper articleWrapper in articles) {
      for (String word in articleWrapper.article.segmentation) {
        WordFrequency candidate = wordFrequencyMapping.putIfAbsent(
            word, () => WordFrequency(word: word));
        candidate.urlToArticle
            .putIfAbsent(articleWrapper.article.url, () => articleWrapper);
        candidate.occurences++;
      }
    }
    List<WordFrequency> wordFrequencies = wordFrequencyMapping.values.toList();
    wordFrequencies.sort((a, b) {
      int occurencesComp = a.occurences.compareTo(b.occurences);
      if (occurencesComp != 0) {
        return occurencesComp;
      }
      return a.urlToArticle.length.compareTo(b.urlToArticle.length);
    });
    return List.from(wordFrequencies.reversed);
  }

  static Future<List<WordFrequency>> getObviousWordCandidates() async {
    List<WordFrequency> wordFrequencies = await getWordHistogram();
    Set<String> knownWords = await VocabulariesWrapper.loadKnownWords();
    return wordFrequencies
        .where((wordFrequency) => !knownWords.contains(wordFrequency.word))
        .toList();
  }
}
