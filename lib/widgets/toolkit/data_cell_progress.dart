import 'package:flutter/material.dart';

import '../../database/database.dart';
import 'scrollable_data_cell.dart';

class DataCellProgress extends StatelessWidget {
  EntityItem entityItem;

  DataCellProgress(this.entityItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      value: entityItem.progress! / 100,
    );
  }
}
