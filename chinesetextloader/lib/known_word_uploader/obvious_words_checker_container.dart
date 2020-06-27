import 'dart:collection';

import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'word_frequency.dart';
import 'package:flutter/material.dart';

class ObviousWordsCheckerContainer extends StatefulWidget {
  final List<WordFrequency> obviousWordCandidates;

  ObviousWordsCheckerContainer(this.obviousWordCandidates);

  @override
  _ObviousWordsCheckerContainerState createState() => new _ObviousWordsCheckerContainerState();
}

class _ObviousWordsCheckerContainerState extends State<ObviousWordsCheckerContainer> {
//  List<WordFrequency>
  LinkedHashMap<String, bool> selectedWords = LinkedHashMap();
  int cardIndex = 0;

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
                    child: IconButton(iconSize: 36, icon: Icon(Icons.save)),
                  ),
                  Container(
                      child: RichText(
                          text: TextSpan(
                              text: '${cardIndex + 1}/${widget.obviousWordCandidates.length}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 24)))),
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
                        selectedWords[widget.obviousWordCandidates[index].word] =
                            orientation == CardSwipeOrientation.LEFT;
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
                  children: selectedWords.entries.map((entry) {
                    return RaisedButton(
                        onLongPress: () => {
                              setState(() => selectedWords[entry.key] =
                                  !selectedWords[entry.key])
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
