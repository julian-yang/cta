import 'package:proto/article.pb.dart';
import 'article_toolbar.dart';
import 'package:flutter/material.dart';
import 'article_wrapper.dart';
import 'utils.dart';

class ArticleTable extends StatelessWidget {
  final List<ArticleWrapper> _articleSource;

  ArticleTable(
    this._articleSource, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return wrap2DScrollbar(DataTable(
      columns: dataColumns,
      rows: _articleSource.map(fromArticle).toList(),
    ));
  }

  static Widget wrap2DScrollbar(Widget child) => Scrollbar(
      child: SingleChildScrollView(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: child)));

  static DataRow fromArticle(ArticleWrapper articleWrapper) {
    return DataRow(
        cells: <DataCell>[DataCell(Text(articleWrapper.article.chineseTitle))]);
  }

  final List<DataColumn> dataColumns = [DataColumn(label: Text('Title'))];
}

class ArticleTableSource extends DataTableSource {
  final List<ArticleWrapper> _articleWrappers;

  ArticleTableSource(this._articleWrappers);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount {
    return 0;
  }

  @override
  int get rowCount {
    return _articleWrappers.length;
  }

  @override
  DataRow getRow(int index) {
    return fromArticle(_articleWrappers[index]);
  }

  static DataRow fromArticle(ArticleWrapper articleWrapper) {
    return DataRow(
        cells: <DataCell>[DataCell(Text(articleWrapper.article.chineseTitle))]);
  }
}

//  child: Table(
//  children: <TableRow>[
//  TableRow(
//  children: createRow([
//  ArticleProperty('Total:', _article.wordCount.toString()),
//  ArticleProperty('Diff:',
//  _article.averageWordDifficulty.toStringAsFixed(2))
//  ])),
//  TableRow(
//  children: createRow([
//  ArticleProperty(
//  'Unknown:', unknownWordCount(_article).toString()),
//  ArticleProperty('Ratio:', knownRatioAsPercentage(_article))
//  ]))
//  ]),
//  )),
