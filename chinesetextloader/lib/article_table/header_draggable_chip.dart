import 'package:flutter/material.dart';
import '../utils.dart';
import 'fake_chip.dart';
import 'package:provider/provider.dart';
import 'data_column_config.dart';

class HeaderDraggableChip extends StatelessWidget {
  const HeaderDraggableChip({
    Key key,
    @required this.config,
  }) : super(key: key);

  final DataColumnConfig config;

  @override
  Widget build(BuildContext context) {
    return Draggable<DataColumnConfig>(
        child: sortableHeader(config),
        feedback: FakeChip(config.name),
        childWhenDragging: Opacity(opacity: .5, child: FakeChip(config.name)),
        data: config);
  }

  Widget sortableHeader(DataColumnConfig config) {
    return Consumer<DataColumnConfigModel>(builder: (context, model, child) {
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
