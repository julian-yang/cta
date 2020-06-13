import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proto/article.pb.dart';
import 'article_toolbar.dart';
import 'utils.dart';

class ArticleViewer extends StatelessWidget {
  final Article article;

  ArticleViewer({Key key, @required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('ArticleViewer')),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(article.chineseTitle,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(article.chineseBody,
                              style: TextStyle(fontSize: 20))
                        ])))),
        bottomNavigationBar: BottomAppBar(
            child: ArticleToolbar(article: article))
        );
  }
}
