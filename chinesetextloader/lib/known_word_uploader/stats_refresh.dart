import 'package:chineseTextLoader/utils.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proto/article.pb.dart';
import 'dart:io';
import 'dart:convert';
import 'package:proto/vocab.pb.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'article_updater.dart';
import 'vocab_updater.dart';

class StatsRefresh extends StatefulWidget {
  @override
  _StatsRefreshState createState() => new _StatsRefreshState();
}

class _StatsRefreshState extends State<StatsRefresh> {
  bool _showProgress = false;
  List<ArticleComparison> _results = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ModalProgressHUD(
        inAsyncCall: _showProgress,
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
//                      child: ListView(
//                          padding: const EdgeInsets.all(8),
//                          children: _results.isNotEmpty ? _renderResults() : [
//                          ])
                  child: wrap2DScrollbar(_renderComparisonTable(_results))),
              ButtonBar(alignment: MainAxisAlignment.center, children: <Widget>[
                RaisedButton(
                    onPressed: () => onRefreshPressed(context),
                    child: Text('Refresh stats!')),
              ])
            ])));
  }

  void onRefreshPressed(context) async {
    setState(() {
      _showProgress = true;
    });
    List<ArticleComparison> result = await updateAllArticleStats();
    setState(() {
      _showProgress = false;
      _results = result;
    });
  }

  void onUpdateStatsPressed(context) async {}

  Widget _createUploadedDialog(List<String> existingWords) =>
      SimpleDialog(title: Text('Uploaded!'), children: <Widget>[
        Text('Existing words: '),
        Container(
            width: 400.0,
            height: 500.0,
            child: ListView(
                padding: const EdgeInsets.all(8),
                children: _createExistingWordCards(existingWords)))
      ]);

  List<Widget> _createExistingWordCards(List<String> existingWords) =>
      existingWords
          .map((word) => Card(child: Column(children: [Text(word)])))
          .toList();

  Widget _renderComparisonTable(List<ArticleComparison> results) {
    return DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('uniqueKnownRatio')),
          DataColumn(label: Text('knownRatio')),
          DataColumn(label: Text('knownWordCount')),
        ],
        rows: results.map((comparison) {
          Stats oldStats = comparison.oldArticle.stats;
          Stats newStats = comparison.newArticle.stats;
          return DataRow(cells: <DataCell>[
            DataCell(Container(
                width: 200, child: Text(comparison.newArticle.chineseTitle))),
            DataCell(_createDoubleField(
                oldStats.uniqueKnownRatio, newStats.uniqueKnownRatio)),
            DataCell(
                _createDoubleField(oldStats.knownRatio, newStats.knownRatio)),
            DataCell(
                _createField(oldStats.knownWordCount, newStats.knownWordCount)),
          ]);
        }).toList());
  }

  Widget _createField(num oldVal, num newVal) {
    return Text('$newVal ($oldVal)');
  }

  Widget _createDoubleField(double oldVal, double newVal) {
    String convertedOld = oldVal.toStringAsFixed(2);
    String convertedNew = newVal.toStringAsFixed(2);
//    return Text('$convertedNew ($convertedOld)');

    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
            text: convertedNew,
            style: TextStyle(color: pickColor(oldVal, newVal))),
        TextSpan(
            text: ' ($convertedNew)', style: TextStyle(color: Colors.black)),
      ],
    ));
  }

  Color pickColor(num oldVal, num newVal) {
    if (oldVal > newVal) {
      return Colors.green;
    } else if (oldVal < newVal) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }
}
