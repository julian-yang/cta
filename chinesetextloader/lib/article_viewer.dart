import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'article.dart';

class ArticleViewer extends StatelessWidget {
  final Article article;

  ArticleViewer({Key key, @required this.article}):
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.chineseTitle)),
      body: Padding(
        padding: EdgeInsets.all(16.0)
      )
    );
  }
}
