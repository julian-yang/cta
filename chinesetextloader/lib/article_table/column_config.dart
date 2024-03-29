import 'dart:collection';

import 'package:flutter/material.dart';
import '../article_wrapper.dart';

typedef CellCreator = Widget Function(BuildContext context,
    ArticleWrapper articleWrapper, ColumnConfig config);
typedef PropertyExtractor = dynamic Function(ArticleWrapper articleWrapper);
typedef ArticleComparator = int Function(ArticleWrapper a, ArticleWrapper b);

class ColumnConfigModel extends ChangeNotifier {
  final List<ColumnConfig> _columns;
  final Map<ColumnConfig, SortState> _columnSortAscending;

  ColumnConfigModel(this._columnSortAscending)
      : _columns = List.from(_columnSortAscending.keys) {}

  UnmodifiableListView<ColumnConfig> get columns =>
      UnmodifiableListView(_columns);

  void rearrange(ColumnConfig config, int index) {
    int curIndex = 0;
    while (_columns[curIndex] != config) {
      curIndex++;
    }
    if (curIndex < index) {
      // if the existing one is before target, we should insert then remove
      _columns.insert(index, _columns[curIndex]);
      _columns.removeAt(curIndex);
    } else {
      // else existing is AFTER target, so remove then insert.
      ColumnConfig temp = _columns.removeAt(curIndex);
      _columns.insert(index, temp);
    }
    notifyListeners();
  }

  void toggleSort(ColumnConfig config) {
    _columnSortAscending[config] = _columnSortAscending[config].toggle;
    notifyListeners();
  }

  SortState getSortState(ColumnConfig config) {
    return _columnSortAscending[config];
  }
}

class ColumnConfig {
  final double width;
  final String name;
  final PropertyExtractor displayValueExtractor;
  final PropertyExtractor compareValueExtractor;
  final AlignmentGeometry alignment;

  const ColumnConfig({
    @required this.name,
    @required this.displayValueExtractor,
    @required this.compareValueExtractor,
    @required this.alignment,
    @required this.width,
  });

  CellCreator get valueCreator => propertyCell(displayValueExtractor);

  ArticleComparator get comparator => createComparator(compareValueExtractor);

  static CellCreator propertyCell(PropertyExtractor extractor) =>
      (context, articleWrapper, config) => Container(
          width: config.width,
          alignment: config.alignment,
          child: Text('${extractor.call(articleWrapper)}'));

  // Sorts ascending.
  static ArticleComparator createComparator(PropertyExtractor extractor) =>
      (ArticleWrapper a, ArticleWrapper b) =>
          extractor.call(a).compareTo(extractor.call(b));

  static ArticleProperty extractTitle(ArticleWrapper a) =>
      ArticleProperty(a.article.chineseTitle, a.article.chineseTitle);

  static const TITLE = ColumnConfig(
    name: 'Title',
    displayValueExtractor: ArticleWrapper.getArticleTitle,
    compareValueExtractor: ArticleWrapper.getArticleTitle,
    alignment: Alignment.centerLeft,
    width: 125,
  );
  static const KNOWN_RATIO = ColumnConfig(
    name: 'Known Ratio',
    displayValueExtractor: ArticleWrapper.getKnownRatioAsPercentage,
    compareValueExtractor: ArticleWrapper.getKnownRatio,
    alignment: Alignment.center,
    width: 90,
  );
  static const TOTAL_WORDS = ColumnConfig(
    name: 'Total',
    displayValueExtractor: ArticleWrapper.getTotalWords,
    compareValueExtractor: ArticleWrapper.getTotalWords,
    alignment: Alignment.center,
    width: 80,
  );
  static const UNKNOWN_WORDS = ColumnConfig(
    name: 'Unknown',
    displayValueExtractor: ArticleWrapper.getUnknownWords,
    compareValueExtractor: ArticleWrapper.getUnknownWords,
    alignment: Alignment.center,
    width: 120,
  );
  static const DIFFICULTY = ColumnConfig(
    name: 'Difficulty',
    displayValueExtractor: ArticleWrapper.getAverageWordDifficultyStr,
    compareValueExtractor: ArticleWrapper.getAverageWordDifficulty,
    alignment: Alignment.center,
    width: 120,
  );
}

enum SortState { NONE, ASCENDING, DESCENDING }

extension Sort on SortState {
  bool get sortable {
    switch (this) {
      case SortState.NONE:
        return false;
      case SortState.ASCENDING:
      case SortState.DESCENDING:
        return true;
    }
  }

  SortState get toggle {
    switch (this) {
      case SortState.NONE:
        return SortState.NONE;
      case SortState.ASCENDING:
        return SortState.DESCENDING;
      case SortState.DESCENDING:
        return SortState.ASCENDING;
    }
  }

}
