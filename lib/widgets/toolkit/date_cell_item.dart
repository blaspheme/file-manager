import 'package:flutter/material.dart';

import '../../database/database.dart';
import 'scrollable_data_cell.dart';

class DataCellItem extends StatelessWidget {
  EntityItem entityItem;

  DataCellItem(this.entityItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableDataCell(
      Row(children: [
        Tooltip(
          message: entityItem.description.toString(),
          child: const Icon(Icons.info_outline_rounded),
        ),
        TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 68, 161, 207),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "item/show",
                  arguments: <String, int>{'id': entityItem.id!});
            },
            child: Text(entityItem.name)),
      ]),
    );
  }
}
