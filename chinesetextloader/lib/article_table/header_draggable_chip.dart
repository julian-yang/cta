import 'package:flutter/material.dart';
import '../utils.dart';
import 'fake_chip.dart';
import 'package:provider/provider.dart';
import 'column_config.dart';

class HeaderDraggableChip extends StatelessWidget {
  const HeaderDraggableChip({
    Key key,
    @required this.config,
  }) : super(key: key);

  final ColumnConfig config;

  @override
  Widget build(BuildContext context) {
    return Draggable<ColumnConfig>(
        child: sortableHeader(config),
        feedback: FakeChip(config.name),
        childWhenDragging: Opacity(opacity: .5, child: FakeChip(config.name)),
        data: config);
  }

  Widget sortableHeader(ColumnConfig config) {
    return Consumer<ColumnConfigModel>(builder: (context, model, child) {
      return ActionChip(
          avatar: Icon(model.getSortState(config) == SortState.ASCENDING
              ? Icons.arrow_upward
              : Icons.arrow_downward),
          label: Text(config.name),
          onPressed: () {
            model.toggleSort(config);
          });
    });
  }
}
