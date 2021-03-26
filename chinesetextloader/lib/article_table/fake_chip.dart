import 'package:flutter/material.dart';

class FakeChip extends StatelessWidget {
  final String _text;

  const FakeChip(
      this._text, {
        Key key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_text, style: TextStyle(fontSize: 16)),
          )),
    );
  }
}
