import 'package:flutter/material.dart';
import 'column_config.dart';

class DragStateModel extends ChangeNotifier {
  ColumnConfig _draggedColumn;

  ColumnConfig get draggedColumn => _draggedColumn;

  set draggedColumn(ColumnConfig value) {
    _draggedColumn = value;
    notifyListeners();
  }
}