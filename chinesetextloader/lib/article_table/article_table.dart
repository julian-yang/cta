import 'package:proto/article.pb.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../article_wrapper.dart';
import '../utils.dart';
import 'header_draggable_chip.dart';
import 'data_column_config.dart';
import 'header_drag_target.dart';
import 'package:provider/provider.dart';

class ArticleTable extends StatefulWidget {
  @override
  _ArticleTableState createState() => new _ArticleTableState();
}

class _ArticleTableState extends State<ArticleTable> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => DataColumnConfigModel(defaultColumnConfig),
        child: Consumer<DataColumnConfigModel>(
            builder: (context, configModel, child) =>
                StreamBuilder<QuerySnapshot>(
                    stream: getSortedSnapshot(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return LinearProgressIndicator();
                      List<ArticleWrapper> articles = snapshot.data.documents
                          .map((documentSnapshot) =>
                              ArticleWrapper.fromSnapshot(documentSnapshot))
                          .toList();
                      ArticleComparator comparator =
                          createComparator(configModel.columns);
                      articles.sort(comparator);
                      return buildTable(context, articles);
                    })));
  }

  int Function(ArticleWrapper a, ArticleWrapper b) createComparator(
      List<DataColumnConfig> columns) {
    return (ArticleWrapper a, ArticleWrapper b) {
      for (DataColumnConfig config in columns) {
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
    return wrap2DScrollbar(Consumer<DataColumnConfigModel>(
        builder: (context, configModel, child) => Column(
            children: <Widget>[createHeaderRow(configModel.columns)] +
                articles
                    .map((article) => buildArticleRow(context, article))
                    .toList())));
  }

  static Widget wrap2DScrollbar(Widget child) => Scrollbar(
      child: SingleChildScrollView(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: child)));

  Widget buildArticleRow(BuildContext context, ArticleWrapper articleWrapper) {
    return Card(
      color: articleWrapper.article.favorite ? Colors.pink[200] : null,
      child: InkWell(
        onTap: () => openArticleViewer(context, articleWrapper),
        onLongPress: () {
          updateFavorite(articleWrapper, !articleWrapper.article.favorite);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<DataColumnConfigModel>(
              builder: (context, configModel, child) => Row(
                  children: configModel.columns
                      .map((config) => config.valueCreator
                          .call(context, articleWrapper, config))
                      .toList())),
        ),
      ),
    );
  }

  Widget createHeaderRow(List<DataColumnConfig> configs) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            children:
                new List<int>.generate(configs.length, (i) => i).map((index) {
          DataColumnConfig config = configs[index];
          return Container(
              width: config.width,
              alignment: config.alignment,
              child: config.sortAscending != null
//                        ? sortableHeader(config)
                  ? draggableHeaderSpace(config, index)
                  : Text(config.name));
        }).toList()),
      );

  List<Widget> buildHeaderChipsAndTargets() {

  }

  Widget draggableHeaderSpace(DataColumnConfig config, int index) {
    return Column(
//      alignment: Alignment.center,
      children: <Widget>[
        HeaderDragTarget(index),
        HeaderDraggableChip(configName: config.name),
      ],
    );
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






