import 'package:chineseTextLoader/known_word_uploader/vocabularies_wrapper.dart';
import 'package:chineseTextLoader/known_word_uploader/word_frequency.dart';
import 'package:flutter/material.dart';
import 'obvious_words.dart';
import 'package:proto/vocab.pb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ObviousWordsContainer extends StatefulWidget {
  @override
  _ObviousWordsContainerState createState() =>
      new _ObviousWordsContainerState();
}

class _ObviousWordsContainerState extends State<ObviousWordsContainer> {
  Future<List<WordFrequency>> obviousCandidates;
  Future loadingCandidates = null;
  Set<String> selectedObviousWords = {};

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: <Widget>[
          buildTopButtonsBar(),
          buildObviousWordsTable()
        ]));
  }

  Widget buildObviousWordsTable() {
    return StreamBuilder<List<WordFrequency>>(
        stream: WordFrequency.getObviousWordsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
                child: CircularProgressIndicator(), width: 30, height: 30);
          }
          List<WordFrequency> obviousWords = snapshot.data;
          return Flexible(
              child: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
                PaginatedDataTable(
                header: Text('Total: ${obviousWords.length}'),
                columns: const <DataColumn>[
                  DataColumn(label: Text('Word')),
                  DataColumn(label: Text('Occurrences')),
                  DataColumn(label: Text('# of Articles')),
                ],
                sortAscending: true,
                rowsPerPage: 20,
                sortColumnIndex: 2,
                source: ObviousWordsDataTableSource(obviousWords)
//                  rows: obviousWords.map(wordFrequencyToDataRow).toList()),
//                ],
              )])));
//          Flexible(
//            child: ListView(
//                children: obviousWords.knownWords
//                    .map((word) => word.headWord)
//                    .map((word) => Text(word))
//                    .toList()),
//          );
        });
  }

  Widget buildTopButtonsBar() =>
      FutureBuilder(
          future: obviousCandidates,
          initialData: <WordFrequency>[],
          builder:
              (BuildContext context,
              AsyncSnapshot<List<WordFrequency>> snapshot) {
            List<Widget> children = [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              children = [
                SizedBox(
                    child: CircularProgressIndicator(), width: 30, height: 30),
              ];
            } else if (snapshot.hasError) {
              children = [
                Icon(Icons.error_outline),
                loadCandidatesButton(),
                startReviewButton(context, []),
                Text('Error: ${snapshot.error ?? 'unknown error'}')
              ];
            } else {
              children = [
                loadCandidatesButton(),
                startReviewButton(context, snapshot.data)
              ];
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: children)),
            );
          });

  Widget loadCandidatesButton() =>
      RaisedButton.icon(
          icon: Icon(Icons.sync),
          label: Text('Load candidates'),
          onPressed: () =>
          {
            setState(() {
              obviousCandidates = WordFrequency.getObviousWordCandidates();
            })
          });

  static Widget startReviewButton(BuildContext context,
      List<WordFrequency> candidates) =>
      RaisedButton(
        child: Text('Start review'),
        onPressed: candidates.isNotEmpty
            ? () =>
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ObviousWords(candidates)))
            : null,
      );


}

class ObviousWordsDataTableSource extends DataTableSource {
  final List<WordFrequency> _wordFrequencies;
  final Set<String> selectedObviousWords = {};

  ObviousWordsDataTableSource(this._wordFrequencies);

  DataRow wordFrequencyToDataRow(wordFrequency) =>
      DataRow(
          onSelectChanged: (selected) {
//        setState(() {
            if (selected) {
              selectedObviousWords.add(wordFrequency.word);
            } else {
              selectedObviousWords.remove(wordFrequency.word);
            }
//        });
          },
          selected: selectedObviousWords.contains(wordFrequency.word),
          cells: <DataCell>[
            DataCell(Text(wordFrequency.word)),
            DataCell(Text('${wordFrequency.occurences}')),
            DataCell(Text('${wordFrequency.urlToArticle.length}')),
          ]);

  @override
  DataRow getRow(int index) {
    return wordFrequencyToDataRow(_wordFrequencies[index]);
  }

  @override
  int get selectedRowCount =>
      selectedObviousWords.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _wordFrequencies.length;
}
