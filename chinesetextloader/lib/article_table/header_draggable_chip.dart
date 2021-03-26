import 'package:flutter/material.dart';
import '../utils.dart';
import 'fake_chip.dart';
import 'package:provider/provider.dart';
import 'drag_state_model.dart';
import 'column_config.dart';

class HeaderDraggableChip extends StatelessWidget {
  const HeaderDraggableChip(
    this._config, {
    Key key,
  }) : super(key: key);

  final ColumnConfig _config;

  @override
  Widget build(BuildContext context) {
    return Consumer<DragStateModel>(builder: (context, dragStateModel, child) {
      return Draggable<ColumnConfig>(
        child: showActionChip(dragStateModel)
            ? sortableHeader(_config)
            : FakeChip(_config.name),
        feedback: FakeChip(_config.name),
        childWhenDragging: Opacity(opacity: .5, child: FakeChip(_config.name)),
        data: _config,
        onDragStarted: () => dragStateModel.draggedColumn = _config,
        onDraggableCanceled: (velocity, offset) =>
            clearDragState(dragStateModel),
        onDragEnd: (draggableDetails) => clearDragState(dragStateModel),
        onDragCompleted: () => clearDragState(dragStateModel),
      );
    });
  }

  void clearDragState(DragStateModel model) => model.draggedColumn = null;

  bool showActionChip(DragStateModel dragStateModel) {
    return dragStateModel.draggedColumn == null ||
        dragStateModel.draggedColumn == _config;
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
