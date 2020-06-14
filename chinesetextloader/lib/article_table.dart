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
  List<DataColumnConfig> tableColumnConfig = List.from(defaultColumnConfig);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: getSortedSnapshot(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          List<ArticleWrapper> articles = snapshot.data.documents
              .map((documentSnapshot) =>
                  ArticleWrapper.fromSnapshot(documentSnapshot))
              .toList();
          ArticleComparator comparator = createComparator();
          articles.sort(comparator);
          return buildTable(context, articles);
        });
  }

  int Function(ArticleWrapper a, ArticleWrapper b) createComparator() {
    return (ArticleWrapper a, ArticleWrapper b) {
      for (DataColumnConfig config in tableColumnConfig) {
        if (config.sortAscending == null) continue;
        // sorts by ascending
        int result = config.comparator.call(a, b);
        if (result != 0) {
          return config.sortAscending ? result : -result;
        }
      }
      return ArticleWrapper.compareAddDate(a, b);
    };
  }

  Stream<QuerySnapshot> getSortedSnapshot() {
//    SortState ratioSortable = tableColumnConfig
//        .firstWhere((config) => config.name == 'Ratio')
//        .sortable;
//    SortState difficultySortable = tableColumnConfig
//        .firstWhere((config) => config.name == 'Diff')
//        .sortable;
    return Firestore.instance
        .collection('scraped_articles')
//        .orderBy('stats.known_ratio',
//            descending: ratioSortable == SortState.DESCENDING)
//        .orderBy('average_word_difficulty',
//            descending: difficultySortable == SortState.DESCENDING)
        .snapshots();
  }

  Widget buildTable(BuildContext context, List<ArticleWrapper> articles) {
    return wrap2DScrollbar(Column(
        children: <Widget>[createHeaderRow(tableColumnConfig)] +
            articles.map((article) => fromArticle(context, article)).toList()));
  }

  static Widget wrap2DScrollbar(Widget child) => Scrollbar(
      child: SingleChildScrollView(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: child)));

  Widget fromArticle(BuildContext context, ArticleWrapper articleWrapper) {
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
              children: tableColumnConfig
                  .map((config) =>
                      config.valueCreator.call(context, articleWrapper, config))
                  .toList()),
        ),
      ),
    );
  }

  Widget createHeaderRow(List<DataColumnConfig> configs) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            children: configs
                .map((config) => Container(
                    width: config.width,
                    alignment: config.alignment,
                    child: config.sortAscending != null
                        ? sortableHeader(config)
                        : Text(config.name)))
                .toList()),
      );

  Widget sortableHeader(DataColumnConfig config) {
    return ActionChip(
        avatar: Icon(
            config.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
        label: Text(config.name),
        onPressed: () {
          setState(() {
            String name = config.name;
            DataColumnConfig columnConfig =
                tableColumnConfig.firstWhere((config) => config.name == name);
            columnConfig.sortAscending = !columnConfig.sortAscending;
          });
        });
  }

  static final List<DataColumnConfig> defaultColumnConfig = [
    DataColumnConfig(
        name: 'Title',
        propertyExtractor: (a) =>
            ArticleProperty(a.article.chineseTitle, a.article.chineseTitle),
        alignment: Alignment.centerLeft,
        width: 125),
    DataColumnConfig(
        name: 'Total',
        propertyExtractor: (a) => a.totalWords,
        alignment: Alignment.center,
        width: 80,
        sortAscending: true),
    DataColumnConfig(
        name: 'Unknown',
        propertyExtractor: (a) => a.unknownCount,
        alignment: Alignment.center,
        width: 120,
        sortAscending: true),
    DataColumnConfig(
        name: 'Ratio',
        propertyExtractor: (a) => a.ratio,
        alignment: Alignment.center,
        width: 90,
        sortAscending: false),
    DataColumnConfig(
        name: 'Difficulty',
        propertyExtractor: (a) => a.averageWordDifficulty,
        alignment: Alignment.center,
        width: 120,
        sortAscending: true),
  ];
}

enum SortState { ASCENDING, DESCENDING }

typedef CellCreator = Widget Function(BuildContext context,
    ArticleWrapper articleWrapper, DataColumnConfig config);
typedef PropertyExtractor = ArticleProperty Function(
    ArticleWrapper articleWrapper);
typedef ValueExtractor = dynamic Function(ArticleWrapper articleWrapper);
typedef ArticleComparator = int Function(ArticleWrapper a, ArticleWrapper b);

class DataColumnConfig {
  final double width;
  final String name;
  final PropertyExtractor propertyExtractor;
  final AlignmentGeometry alignment;
  bool sortAscending;

  DataColumnConfig({
    @required this.name,
    @required this.propertyExtractor,
    @required this.alignment,
    @required this.width,
    this.sortAscending,
  });

  CellCreator get valueCreator => propertyCell(propertyExtractor);

  ArticleComparator get comparator => createComparator(propertyExtractor);

  static CellCreator propertyCell(PropertyExtractor extractor) =>
      (context, articleWrapper, config) => Container(
          width: config.width,
          alignment: config.alignment,
          child: Text(extractor.call(articleWrapper).display));

  // Sorts ascending.
  static ArticleComparator createComparator(PropertyExtractor extractor) =>
      (ArticleWrapper a, ArticleWrapper b) =>
          extractor.call(a).value.compareTo(extractor.call(b).value);
}
