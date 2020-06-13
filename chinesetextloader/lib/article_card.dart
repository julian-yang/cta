import 'package:proto/article.pb.dart';
import 'article_toolbar.dart';
import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final Article _article;
  const ArticleCard(this._article, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
//                      leading: Icon(Icons.description),
              title: Text(_article.chineseTitle),
              subtitle: Row(
                children: <Widget>[
//                  Text(_)
                  Text(_article.averageWordDifficulty.toString()),
                ],
              )),
          ArticleToolbar(article: _article)
        ],
      ),
    );
  }
}

