import 'package:flutter/cupertino.dart';
import 'package:proto/article.pb.dart';
import 'article_toolbar.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class ArticleCard extends StatelessWidget {
  final Article _article;

  const ArticleCard(
    this._article, {
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
              subtitle: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Table(
                    children: <TableRow>[
                  TableRow(
                      children: createRow([
                    ArticleProperty('Total:', _article.wordCount.toString()),
                    ArticleProperty('Diff:',
                        _article.averageWordDifficulty.toStringAsFixed(2))
                  ])),
                  TableRow(
                      children: createRow([
                    ArticleProperty(
                        'Unknown:', unknownWordCount(_article).toString()),
                    ArticleProperty('Ratio:', knownRatioAsPercentage(_article))
                  ]))
                ]),
              )),
          ArticleToolbar(article: _article)
        ],
      ),
    );
  }

  static String knownRatioAsPercentage(Article article) =>
      '${(article.stats.knownRatio * 100).toStringAsFixed(1)}%';

  static List<Widget> createRow(List<ArticleProperty> properties) {
    return properties
        .expand((p) => [descriptionCell(p.description), valueCell(p.value)])
        .toList();
  }

  static Widget descriptionCell(String value) =>
      Align(alignment: Alignment.centerRight, child: Text(value));

  static Widget valueCell(String value) => Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(value),
      ));
}

class ArticleProperty {
  final String description;
  final String value;

  ArticleProperty(this.description, this.value);
}
