import 'package:proto/article.pb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'article_wrapper.dart';
import 'utils.dart';

class ArticleTable extends StatefulWidget {
  @override
  _ArticleTableState createState() => new _ArticleTableState();
}

class _ArticleTableState extends State<ArticleTable> {
  List<DataColumnConfig> columnConfig = List.from(defaultColumnConfig);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder <QuerySnapshot>(
        stream: Firestore.instance.collection('scraped_articles').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          List<ArticleWrapper> articles = snapshot.data.documents
              .map((documentSnapshot) =>
              ArticleWrapper.fromSnapshot(documentSnapshot))
              .toList()
            ..sort(ArticleWrapper.compareAddDate);
          return buildTable(context, articles);
        });
  }

  Widget buildTable(BuildContext context, List<ArticleWrapper> articles) {
    return wrap2DScrollbar(Column(
        children: <Widget>[createHeaderRow(columnConfig)] +
            articles
                .map((article) => fromArticle(context, article))
                .toList()));
  }

  static Widget wrap2DScrollbar(Widget child) => Scrollbar(
      child: SingleChildScrollView(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: child)));

  Widget fromArticle(
      BuildContext context, ArticleWrapper articleWrapper) {
    return Card(
      color: articleWrapper.article.favorite ? Colors.pink[200] : null,
      child: InkWell(
        onTap: () => openArticleViewer(context, articleWrapper),
        onLongPress: () {
          updateFavorite(articleWrapper, !articleWrapper.article.favorite);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
              children: columnConfig
                  .map((config) =>
                      config.valueCreator.call(context, articleWrapper, config))
                  .toList()),
        ),
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
                    child: config.sortable
                        ? sortableHeader(config)
                        : Text(config.name)))
                .toList()),
      );

  static Widget sortableHeader(DataColumnConfig config) {
    return ActionChip(avatar: Icon(Icons.arrow_upward),
        label: Text(config.name),
        onPressed: () {});
  }

  static final List<DataColumnConfig> defaultColumnConfig = [
    DataColumnConfig(
        name: 'Title',
        valueCreator:
            DataColumnConfig.propertyCell((a) => a.article.chineseTitle),
        alignment: Alignment.centerLeft,
        width: 125,
        sortable: false),
    DataColumnConfig(
        name: 'Total',
        valueCreator: DataColumnConfig.propertyCell((a) => a.totalWords),
        alignment: Alignment.center,
        width: 80,
        sortable: true),
    DataColumnConfig(
        name: 'Unknown',
        valueCreator: DataColumnConfig.propertyCell((a) => a.unknownCount),
        alignment: Alignment.center,
        width: 120,
        sortable: true),
    DataColumnConfig(
        name: 'Ratio',
        valueCreator: DataColumnConfig.propertyCell((a) => a.ratio),
        alignment: Alignment.center,
        width: 90,
        sortable: true),
    DataColumnConfig(
        name: 'Diff',
        valueCreator:
            DataColumnConfig.propertyCell((a) => a.averageWordDifficulty),
        alignment: Alignment.center,
        width: 80,
        sortable: true),
  ];
}

typedef CellCreator = Widget Function(BuildContext context,
    ArticleWrapper articleWrapper, DataColumnConfig config);
typedef PropertyExtractor = String Function(ArticleWrapper articleWrapper);

class DataColumnConfig {
  final double width;
  final String name;
  final CellCreator valueCreator;
  final AlignmentGeometry alignment;
  final bool sortable;

  const DataColumnConfig(
      {@required this.name,
      @required this.valueCreator,
      @required this.alignment,
      @required this.width,
      @required this.sortable});

  static CellCreator propertyCell(PropertyExtractor extractor) =>
      (context, articleWrapper, config) => Container(
          width: config.width,
          alignment: config.alignment,
          child: Text(extractor.call(articleWrapper)));
}
