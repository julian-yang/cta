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
      // seems like an ok height for now, mainly due to article title.
      dataRowHeight: 80,
      columnSpacing: 30,
      columns: columnConfig.map((config) => config.column).toList(),
      rows: _articleSource.map(fromArticle).toList(),
    ));
  }

  static Widget wrap2DScrollbar(Widget child) => Scrollbar(
      child: SingleChildScrollView(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: child)));

  static DataRow fromArticle(ArticleWrapper articleWrapper) {
    return DataRow(
        cells: columnConfig
            .map((config) => config.valueCreator.call(articleWrapper))
            .toList());
  }

  static final List<DataColumnConfig> columnConfig = [
    DataColumnConfig(
        DataColumn(label: Text('Title')), DataColumnConfig.titleCell),
    DataColumnConfig(DataColumn(label: Text('Total'), numeric: true),
        DataColumnConfig.propertyCell((a) => a.totalWords)),
    DataColumnConfig(DataColumn(label: Text('Unknown'), numeric: true),
        DataColumnConfig.propertyCell((a) => a.unknownCount)),
    DataColumnConfig(DataColumn(label: Text('Ratio'), numeric: true),
        DataColumnConfig.propertyCell((a) => a.ratio)),
    DataColumnConfig(DataColumn(label: Text('Diff'), numeric: true),
        DataColumnConfig.propertyCell((a) => a.averageWordDifficulty)),
  ];
}

typedef CellCreator = DataCell Function(ArticleWrapper articleWrapper);
typedef PropertyExtractor = String Function(ArticleWrapper articleWrapper);

class DataColumnConfig {
  final DataColumn column;
  final CellCreator valueCreator;

  DataColumnConfig(this.column, this.valueCreator);

  static DataCell titleCell(ArticleWrapper articleWrapper) => DataCell(
      Container(width: 125, child: Text(articleWrapper.article.chineseTitle)));

  static CellCreator propertyCell(PropertyExtractor extractor) =>
      (articleWrapper) => DataCell(Container(
          width: 40,
          alignment: Alignment.centerRight,
          child: Text(extractor.call(articleWrapper))));
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
