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

  static Future<List<WordFrequency>> getWordHistogram() async {
    QuerySnapshot articlesSnapshot =
        await Firestore.instance.collection('scraped_articles').getDocuments();
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
    wordFrequencies.sort((a, b) => a.occurences.compareTo(b.occurences));
    return wordFrequencies;
  }

  static Future<List<WordFrequency>> getObviousWordCandidates() async {
    List<WordFrequency> wordFrequencies = await getWordHistogram();
    Set<String> knownWords = await VocabulariesWrapper.loadKnownWords();
    return wordFrequencies
        .where((wordFrequency) => !knownWords.contains(wordFrequency.word))
        .toList();
  }
}
