import 'package:flutter/material.dart';
import 'obvious_words.dart';

class ObviousWordsContainer extends StatefulWidget {
  @override
  _ObviousWordsContainerState createState() => new _ObviousWordsContainerState();
}

class _ObviousWordsContainerState extends State<ObviousWordsContainer> {
  List<String> words = ['你好', '台北', '跑車'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text('Start review'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => ObviousWords()
        )),
      )
    );
  }
}
