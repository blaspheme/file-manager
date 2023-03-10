import 'package:flutter/material.dart';

import '../../types/item_vo.dart';
import 'data_cell_progress.dart';
import 'data_cell_tag.dart';
import 'date_cell_item.dart';

class SmallItemListView extends StatelessWidget {
  final List<ItemsVO> _entityItemList;

  const SmallItemListView(this._entityItemList, {super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('进度')),
          DataColumn(label: Text('Tags')),
        ],
        rows: _entityItemList
            .map((item) => DataRow(cells: [
                  DataCell(DataCellItem(item.entityItem)),
                  DataCell(Text(item.entityItem.rank.toString())),
                  DataCell(DataCellProgress(item.entityItem)),
                  DataCell(DataCellTag(item.entityTagList)),
                ]))
            .toList(),
      ),
    );
  }
}
