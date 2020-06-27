import 'dart:collection';

import 'package:flutter_tindercard/flutter_tindercard.dart';

import 'package:flutter/material.dart';

class ObviousWords extends StatefulWidget {
  @override
  _ObviousWordsState createState() => new _ObviousWordsState();
}

class _ObviousWordsState extends State<ObviousWords> {
  List<String> words = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '你好',
    '台北',
    '跑車',
  ];
  LinkedHashMap<String, bool> selectedWords = LinkedHashMap();
  int currentIndex = 0;

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
                              text: '${currentIndex + 1}/${words.length}',
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
//            swipeUp: true,
//            swipeDown: true,
                  orientation: AmassOrientation.BOTTOM,
                  totalNum: words.length,
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
                                text: words[index],
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
                        currentIndex = index + 1;
                        selectedWords[words[index]] =
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
