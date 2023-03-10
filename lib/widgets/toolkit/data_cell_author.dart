import 'package:flutter/material.dart';

import '../../database/database.dart';
import 'scrollable_data_cell.dart';

class DataCellAuthor extends StatelessWidget {
  List<EntityAuthor> entityAuthorList;

  DataCellAuthor(this.entityAuthorList, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollableDataCell(Row(
      children: entityAuthorList.map((EntityAuthor author) {
        return TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 92, 10, 85),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "author/show",
                  arguments: <String, int>{'id': author.id!});
            },
            child: Text(author.name));
      }).toList(),
    ));
  }
}
