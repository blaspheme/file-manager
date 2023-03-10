import 'package:flutter/material.dart';

import '../../database/database.dart';
import 'scrollable_data_cell.dart';

class DataCellTag extends StatelessWidget {
  List<EntityTag> entityTagList;

  DataCellTag(this.entityTagList, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableDataCell(Row(
      children: entityTagList.map((EntityTag tag) {
        return TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 232, 200, 70),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "tag/show",
                  arguments: <String, int>{'id': tag.id!});
            },
            child: Text(tag.tag));
      }).toList(),
    ));
  }
}
