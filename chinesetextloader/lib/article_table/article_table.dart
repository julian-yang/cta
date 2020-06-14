import 'package:proto/article.pb.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../article_wrapper.dart';
import '../utils.dart';
import 'header_draggable_chip.dart';
import 'column_config.dart';
import 'header_drag_target.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

class ArticleTable extends StatefulWidget {
  @override
  _ArticleTableState createState() => new _ArticleTableState();
}

class _ArticleTableState extends State<ArticleTable> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ColumnConfigModel(defaultColumnConfig),
        child: Consumer<ColumnConfigModel>(
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
                          createComparator(configModel);
                      articles.sort(comparator);
                      return buildTable(context, articles);
                    })));
  }

  int Function(ArticleWrapper a, ArticleWrapper b) createComparator(
      ColumnConfigModel model) {
    return (ArticleWrapper a, ArticleWrapper b) {
      for (ColumnConfig config in model.columns) {
        SortState sortState = model.getSortState(config);
        if (!sortState.sortable) continue;
        // sorts by ascending
        int result = config.comparator.call(a, b);
        if (result != 0) {
          return sortState == SortState.ASCENDING ? result : -result;
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
    return wrap2DScrollbar(Consumer<ColumnConfigModel>(
        builder: (context, configModel, child) => Column(
            children: <Widget>[createHeaderRow(configModel)] +
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
          child: Consumer<ColumnConfigModel>(
              builder: (context, configModel, child) => Row(
                  children: configModel.columns
                      .map((config) => config.valueCreator
                          .call(context, articleWrapper, config))
                      .toList())),
        ),
      ),
    );
  }

  Widget createHeaderRow(ColumnConfigModel model) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            children:
                new List<int>.generate(model.columns.length, (i) => i).map((index) {
          ColumnConfig config = model.columns[index];
          return Container(
              width: config.width,
              alignment: config.alignment,
              child: model.getSortState(config).sortable
//                        ? sortableHeader(config)
                  ? draggableHeaderSpace(config, index)
                  : Text(config.name));
        }).toList()),
      );

  List<Widget> buildHeaderChipsAndTargets() {

  }

  Widget draggableHeaderSpace(ColumnConfig config, int index) {
    return Column(
//      alignment: Alignment.center,
      children: <Widget>[
        HeaderDragTarget(index),
        HeaderDraggableChip(config: config),
      ],
    );
  }

  // ColumnConfig to SortAscending
  static final Map<ColumnConfig, SortState> defaultColumnConfig = {
    ColumnConfig.TITLE: SortState.NONE, // This one is not sortable
    ColumnConfig.TOTAL_WORDS: SortState.ASCENDING,
    ColumnConfig.UNKNOWN_WORDS: SortState.ASCENDING,
    ColumnConfig.KNOWN_RATIO: SortState.DESCENDING,
    ColumnConfig.DIFFICULTY: SortState.ASCENDING,
  };
}






