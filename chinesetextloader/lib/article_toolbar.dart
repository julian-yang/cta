import 'package:flutter/material.dart';
import 'article.dart';
import 'utils.dart';

class ArticleToolbar extends StatelessWidget {
  final Article article;

  ArticleToolbar({Key key, @required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme.bar(
        child: ButtonBar(children: <Widget>[
      RaisedButton(
          child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Icon(Icons.assignment, color: Colors.white),
                const Text('Copy to Pleco',
                    style: TextStyle(color: Colors.white))
              ])),
          onPressed: () => copyToClipBoard(
              '${article.chineseTitle}\n\n${article.chineseBody}')),
      RaisedButton(
          child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Icon(Icons.open_in_browser, color: Colors.white),
                const Text('Open in URL', style: TextStyle(color: Colors.white))
              ])),
          onPressed: () => openUrl(article.url))
    ]));
  }
}
