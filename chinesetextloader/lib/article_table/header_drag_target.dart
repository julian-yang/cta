import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../article_wrapper.dart';
import '../utils.dart';
import 'package:provider/provider.dart';
import 'column_config.dart';
import 'drag_state_model.dart';

class HeaderDragTarget extends StatefulWidget {
  final int index;

  HeaderDragTarget(this.index);

  @override
  _HeaderDragTargetState createState() => new _HeaderDragTargetState();
}

class _HeaderDragTargetState extends State<HeaderDragTarget> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ColumnConfigModel, DragStateModel>(
        builder: (context, configModel, dragStateModel, child) =>
            DragTarget<ColumnConfig>(
                builder: (context, candidates, rejects) =>
                    dragStateModel.draggedColumn != null
                        ? buildTargetBox(candidates)
                        : SizedBox.shrink(),
                onWillAccept: (data) {
                  int index = configModel.columns.indexOf(data);
                  return index != widget.index && index != widget.index - 1;
                },
                onAccept: (data) {
                  configModel.rearrange(data, widget.index);
                }));
  }

  Widget buildTargetBox(List<ColumnConfig> candidates) {
    return DecoratedBox(
        decoration: BoxDecoration(
          color: candidates.isNotEmpty ? Colors.red : Colors.orange,
          shape: BoxShape.rectangle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('target'),
        ));
  }
}
