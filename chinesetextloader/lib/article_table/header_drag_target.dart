import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../article_wrapper.dart';
import '../utils.dart';
import 'package:provider/provider.dart';
import 'column_config.dart';

class HeaderDragTarget extends StatefulWidget {
  final int index;

  HeaderDragTarget(this.index);

  @override
  _HeaderDragTargetState createState() => new _HeaderDragTargetState();
}

class _HeaderDragTargetState extends State<HeaderDragTarget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColumnConfigModel>(
        builder: (context, configModel, child) => DragTarget<ColumnConfig>(
            builder: (context, candidates, rejects) => DecoratedBox(
                decoration: BoxDecoration(
                  color: candidates.isNotEmpty ? Colors.red : Colors.orange,
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('target'),
                )),
            onWillAccept: (data) =>
                data != configModel.columns[widget.index]
                ,
            onAccept: (data) {
              configModel.rearrange(data, widget.index);
//              showDialog(context: context, child: Text('Accepted!'));
            }));
  }
}
