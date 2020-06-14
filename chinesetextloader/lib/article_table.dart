import 'package:flutter/services.dart';
import 'package:proto/article.pb.dart';
import 'article_toolbar.dart';
import 'package:flutter/material.dart';
import 'article_wrapper.dart';
import 'article_viewer.dart';
import 'utils.dart';

class ArticleTable extends StatelessWidget {
  final List<ArticleWrapper> _articleSource;

  ArticleTable(
    this._articleSource, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return wrap2DScrollbar(Column(
        children: <Widget>[createHeaderRow(columnConfig)] +
            _articleSource
                .map((article) => fromArticle(context, article))
                .toList()));
  }

  static Widget wrap2DScrollbar(Widget child) => Scrollbar(
      child: SingleChildScrollView(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: child)));

  static Widget fromArticle(
      BuildContext context, ArticleWrapper articleWrapper) {
    return Card(
      color: articleWrapper.article.wordCount < 1000 ? Colors.pink[200] : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            children: columnConfig
                .map((config) =>
                    config.valueCreator.call(context, articleWrapper, config))
                .toList()),
      ),
    );
  }

  static Widget createHeaderRow(List<DataColumnConfig> configs) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            children: configs
                .map((config) => Container(
                    width: config.width,
                    alignment: config.alignment,
                    child: Text(config.title)))
                .toList()),
      );

  static final List<DataColumnConfig> columnConfig = [
    DataColumnConfig(
        title: 'Title',
        valueCreator:
            DataColumnConfig.propertyCell((a) => a.article.chineseTitle),
        alignment: Alignment.centerLeft,
        width: 125),
    DataColumnConfig(
        title: 'Total',
        valueCreator: DataColumnConfig.propertyCell((a) => a.totalWords),
        alignment: Alignment.centerRight,
        width: 60),
    DataColumnConfig(
        title: 'Unknown',
        valueCreator: DataColumnConfig.propertyCell((a) => a.unknownCount),
        alignment: Alignment.centerRight,
        width: 80),
    DataColumnConfig(
        title: 'Ratio',
        valueCreator: DataColumnConfig.propertyCell((a) => a.ratio),
        alignment: Alignment.centerRight,
        width: 60),
    DataColumnConfig(
        title: 'Diff',
        valueCreator:
            DataColumnConfig.propertyCell((a) => a.averageWordDifficulty),
        alignment: Alignment.centerRight,
        width: 60),
  ];
}

typedef CellCreator = /*DataCell*/ Widget Function(BuildContext context,
    ArticleWrapper articleWrapper, DataColumnConfig config);
typedef PropertyExtractor = String Function(ArticleWrapper articleWrapper);

class DataColumnConfig {
  final double width;
  final String title;
  final CellCreator valueCreator;
  final AlignmentGeometry alignment;

  DataColumnConfig(
      {@required this.title,
      @required this.valueCreator,
      @required this.alignment,
      @required this.width});

  static CellCreator propertyCell(PropertyExtractor extractor) =>
      (context, articleWrapper, config) => Container(
          width: config.width,
          alignment: config.alignment,
          child: Text(extractor.call(articleWrapper)));
}
