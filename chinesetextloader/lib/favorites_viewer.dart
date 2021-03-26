import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'article_wrapper.dart';
import 'article_viewer.dart';
import 'article_card.dart';
import 'utils.dart';

class FavoritesViewer extends StatefulWidget {
  @override
  _FavoritesViewerState createState() => new _FavoritesViewerState();
}

class _FavoritesViewerState extends State<FavoritesViewer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('scraped_articles')
          .where('favorite', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  static Widget _buildList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    List<ArticleWrapper> articles = snapshot
        .map((data) => ArticleWrapper.fromSnapshot(data))
        .toList()
      ..sort(ArticleWrapper.compareAddDate);
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: articles.reversed
          .map((article) => _buildListItem(context, article))
          .toList(),
    );
  }

  static Widget _buildListItem(
      BuildContext context, ArticleWrapper articleWrapper) {
    return Padding(
        key: ValueKey(articleWrapper.key),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ArticleViewer(article: articleWrapper.article)));
            },
            child: ArticleCard(articleWrapper.article)));
  }
}