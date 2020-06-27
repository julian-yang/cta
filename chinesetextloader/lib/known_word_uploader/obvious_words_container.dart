import 'package:chineseTextLoader/known_word_uploader/word_frequency.dart';
import 'package:flutter/material.dart';
import 'obvious_words.dart';

class ObviousWordsContainer extends StatefulWidget {
  @override
  _ObviousWordsContainerState createState() =>
      new _ObviousWordsContainerState();
}

class _ObviousWordsContainerState extends State<ObviousWordsContainer> {
  Future<List<WordFrequency>> obviousCandidates;
  Future loadingCandidates = null;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: <Widget>[
      FutureBuilder(
          future: obviousCandidates,
          initialData: <WordFrequency>[],
          builder: (BuildContext context,
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
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: children),
            );
          })
    ]));
  }

  Widget loadCandidatesButton() => RaisedButton.icon(
      icon: Icon(Icons.sync),
      label: Text('Load candidates'),
      onPressed: () => {
            setState(() {
              obviousCandidates = WordFrequency.getObviousWordCandidates();
            })
          });

  static Widget startReviewButton(
          BuildContext context, List<WordFrequency> candidates) =>
      RaisedButton(
        child: Text('Start review'),
        onPressed: candidates.isNotEmpty
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ObviousWords(candidates)))
            : null,
      );
}
