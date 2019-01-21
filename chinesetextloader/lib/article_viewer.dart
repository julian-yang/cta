import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'article.dart';
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
            child: ButtonTheme.bar(
                child: ButtonBar(children: <Widget>[
          RaisedButton(
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Icon(Icons.assignment, color: Colors.white),
                    const Text('Copy to Pleco',
                        style: TextStyle(color: Colors.white))
                  ])),
              onPressed: () => copyToClipBoard(article.chineseBody)),
          RaisedButton(
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Icon(Icons.open_in_browser, color: Colors.white),
                    const Text('Open in URL',
                        style: TextStyle(color: Colors.white))
                  ])),
              onPressed: () => openUrl(article.url))
        ]))));
  }
}
