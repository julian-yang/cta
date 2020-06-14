import 'dart:collection';

import 'package:flutter/material.dart';
import '../article_wrapper.dart';

typedef CellCreator = Widget Function(BuildContext context,
    ArticleWrapper articleWrapper, DataColumnConfig config);
typedef PropertyExtractor = ArticleProperty Function(
    ArticleWrapper articleWrapper);
typedef ArticleComparator = int Function(ArticleWrapper a, ArticleWrapper b);

class DataColumnConfigModel extends ChangeNotifier {
  final List<DataColumnConfig> _columns;

  DataColumnConfigModel(this._columns);

  UnmodifiableListView<DataColumnConfig> get columns =>
      UnmodifiableListView(_columns);

  void rearrange(String columnName, int index) {
    int curIndex = 0;
    while (_columns[curIndex].name != columnName) {
      curIndex++;
    }
    if (curIndex < index) {
      // if the existing one is before target, we should insert then remove
      _columns.insert(index, _columns[curIndex]);
      _columns.removeAt(curIndex);
    } else {
      // else existing is AFTER target, so remove then insert.
      DataColumnConfig temp = _columns.removeAt(curIndex);
      _columns.insert(index, temp);
    }
    notifyListeners();
  }

  void updateSort(String name, bool sortAscending) {
    _columns.firstWhere((c) =>c.name == name)?.sortAscending = sortAscending;
    notifyListeners();
  }

  DataColumnConfig get(String name) {
    return _columns.firstWhere((c) => c.name == name);
  }
}

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
