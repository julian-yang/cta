import 'dart:collection';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chineseTextLoader/known_word_uploader/vocab_updater.dart';
import 'package:chineseTextLoader/known_word_uploader/vocabularies_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'word_frequency.dart';
import 'package:flutter/material.dart';

class ObviousWords extends StatefulWidget {
  final List<WordFrequency> obviousWordCandidates;
//  final List<WordFrequency> obviousWordCandidates = [WordFrequency(word: '風')];

  ObviousWords(this.obviousWordCandidates);

//  ObviousWords(List<WordFrequency> obviousWordCandidates);

  @override
  _ObviousWordsState createState() => new _ObviousWordsState();
}

class _ObviousWordsState extends State<ObviousWords> {
//  List<WordFrequency>
  LinkedHashMap<String, bool> reviewedWords = LinkedHashMap();
  List<List<String>> addedWords = [[]];
  int cardIndex = 0;

  Future<void> insertObviousToFirebase() async {
    List<String> selectedWords = reviewedWords.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    MergeVocabResult result = await insertObviousWords(selectedWords);
    setState(() {
      if (result.newWords.isNotEmpty) {
        addedWords.add(result.newWords);
        reviewedWords.clear();
      }
    });
    showDialog(
        context: context,
        child: SimpleDialog(title: Text('Result'), children: [
          Container(
              width: 400.0,
              height: 500.0,
              child: result.newWords.isNotEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(8),
                      children: result.newWords
                          .map((word) =>
                              Card(child: Column(children: [Text(word)])))
                          .toList())
                  : Center(child: Text('No new words added')))
        ]));
    Fluttertoast.showToast(
        msg: result.merged != null ? 'Save successful' : 'Save failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black38,
        textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    CardController controller; //Use this to trigger swap.

    return Scaffold(
        appBar: AppBar(title: Text('Obvious Words')),
        body: Scrollbar(
          child: ListView(children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        iconSize: 36,
                        icon: Icon(Icons.save),
                        onPressed: reviewedWords.containsValue(true)
                            ? () => insertObviousToFirebase()
                            : null,
                      )),
                  Container(
                      child: RichText(
                          text: TextSpan(
                              text:
                                  '${cardIndex + 1}/${widget.obviousWordCandidates.length}',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 24)))),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(iconSize: 36, icon: Icon(Icons.undo)),
                  )
                ]),
            Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: new TinderSwapCard(
                  orientation: AmassOrientation.BOTTOM,
                  totalNum: widget.obviousWordCandidates.length,
                  stackNum: 5,
                  swipeEdge: 4.0,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.width * 0.9,
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  minHeight: MediaQuery.of(context).size.width * 0.8,
                  cardBuilder: (context, index) => Card(
                    child: Center(
                        child: RichText(
                            text: TextSpan(
                                text: widget.obviousWordCandidates[index].word,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 48)))),
                  ),
                  cardController: controller = CardController(),
                  swipeUpdateCallback:
                      (DragUpdateDetails details, Alignment align) {
//                  showDialog(
//                      context: context,
//                      child: SimpleDialog(
//                          title: Text('swipeUpdateCallback'),
//                          children: <Widget>[
////                      Text()
//                          ]
//
//                  ));
                    /// Get swiping card's alignment
                    if (align.x < 0) {
                      //Card is LEFT swiping
                    } else if (align.x > 0) {
                      //Card is RIGHT swiping
                    }
                  },
                  swipeCompleteCallback:
                      (CardSwipeOrientation orientation, int index) {
                    /// Get orientation & index of swiped card!
                    if (orientation != CardSwipeOrientation.RECOVER) {
                      setState(() {
                        cardIndex = index + 1;
                        reviewedWords[widget.obviousWordCandidates[index]
                            .word] = orientation == CardSwipeOrientation.LEFT;
                      });
                    }
                  },
                )),
            Column(children: <Widget>[
              Text('Previous words:'),
              Wrap(
                  direction: Axis.horizontal,
                  runSpacing: 8,
                  spacing: 8,
                  children: reviewedWords.entries.map((entry) {
                    return RaisedButton(
                        onLongPress: () => {
                              setState(() => reviewedWords[entry.key] =
                                  !reviewedWords[entry.key])
                            },
                        child: RichText(
                            text: TextSpan(
                                text: '${entry.key}',
                                style: TextStyle(
                                    color:
                                        entry.value ? Colors.green : Colors.red,
                                    fontSize: 24))));
                  }).toList()),
            ])
          ]),
        ));
  }
}
