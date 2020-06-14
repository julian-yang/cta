import 'package:flutter/material.dart';
import '../utils.dart';
import 'fake_chip.dart';
import 'package:provider/provider.dart';
import 'data_column_config.dart';

class HeaderDraggableChip extends StatelessWidget {
  const HeaderDraggableChip({
    Key key,
    @required this.configName,
  }) : super(key: key);

  final String configName;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
        child: sortableHeader(configName),
        feedback: FakeChip(configName),
        childWhenDragging: Opacity(opacity: .5, child: FakeChip(configName)),
        data: configName);
  }

  Widget sortableHeader(String configName) {
    return Consumer<DataColumnConfigModel>(builder: (context, model, child) {
      DataColumnConfig config = model.get(configName);
      return ActionChip(
          avatar: Icon(
              config.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          label: Text(config.name),
          onPressed: () {
            model.updateSort(configName, !config.sortAscending);
            // TODO: maybe this will break in the future? May need to use consumer instead.
//            config.sortAscending = !config.sortAscending;
          });
    });
  }
}
