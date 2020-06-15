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
            dragStateModel.draggedColumn != null
                ? buildDragTargetPair(configModel, dragStateModel)
                : SizedBox.shrink());
  }

  Widget buildDragTargetPair(
      ColumnConfigModel configModel, DragStateModel dragStateModel) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildDragTarget(configModel, dragStateModel, rightBox: false),
      buildDragTarget(configModel, dragStateModel, rightBox: true),
    ]);
  }

  Widget buildDragTarget(
      ColumnConfigModel configModel, DragStateModel dragStateModel,
      {bool rightBox}) {
    return DragTarget<ColumnConfig>(
        builder: (context, candidates, rejects) =>
            dragStateModel.draggedColumn != null
                ? buildTargetBox(candidates, rejects, rightBox: rightBox)
                : SizedBox.shrink(),
        onWillAccept: (data) {
          int index = configModel.columns.indexOf(data);
          if (index == widget.index) {
            return false;
          }
          if (rightBox) {
            return index != widget.index + 1;
          } else {
            return index != widget.index - 1;
          }
        },
        onAccept: (data) {
          if (rightBox) {
          configModel.rearrange(data, widget.index + 1);
          } else {
            configModel.rearrange(data, widget.index);
          }
        });
  }

  Widget buildTargetBox(List<ColumnConfig> candidates, List rejects,
      {@required bool rightBox}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          // update color picker to include rejects
          color: pickColor(candidates, rejects),
          shape: BoxShape.rectangle,
          border: rightBox ? rightBoxBorder : leftBoxBorder),
    );
  }

  Color pickColor(List candidates, List rejects) {
    if (candidates.isNotEmpty) {
      return Colors.green[200];
    } else if (rejects.isNotEmpty) {
      return Colors.red[400];
    } else {
      return Colors.orange;
    }
  }

  static const Border leftBoxBorder = Border(right: border);
  static const Border rightBoxBorder = Border(left: border);

  static const BorderSide border = BorderSide(color: Colors.white, width: 2);
}
