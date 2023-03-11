import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_manager/types/author_vo.dart';
import 'package:file_manager/types/item_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../types/file_vo.dart';
import '../types/tag_vo.dart';
import 'toolkit/data_cell_author.dart';
import 'toolkit/data_cell_progress.dart';
import 'toolkit/data_cell_tag.dart';
import 'toolkit/date_cell_item.dart';
import 'toolkit/scrollable_data_cell.dart';

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<StatefulWidget> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  late List<ItemsVO> _entityItemList = <ItemsVO>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getData(context);
  }

  void getData(BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await AuthorsVO.init(thisDB);
    await TagsVO.init(thisDB);
    await ItemsVO.init(thisDB);
    await FilesVO.init(thisDB);

    setState(() {
      // _entityItemList = ItemsVO.getItemVOList().toList();
      _entityItemList =
          ItemsVO.getItemVOListByIds(ItemsVO.getItemVOIds()).toList();
    });
  }

  Iterable<DropDownValueModel> get dropDownList {
    return _entityItemList.map((ItemsVO itemsVO) {
      return DropDownValueModel(
          name: itemsVO.entityItem.name,
          value: itemsVO.entityItem.id.toString());
    });
  }

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const title = 'Item List';

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, "item/edit",
                arguments: <String, int>{'id': 0});
          },
        ),
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          getData(context);
        },
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: SizedBox(
          width: double.infinity,
          child: Column(children: [
            Row(
              children: [
                Expanded(
                    child: DropDownTextField(
                  controller: SingleValueDropDownController(),
                  textFieldDecoration:
                      const InputDecoration(hintText: "Items查询..."),
                  clearOption: true,
                  enableSearch: true,
                  dropdownColor: Colors.amber[50],
                  searchDecoration:
                      const InputDecoration(hintText: "查询 Items..."),
                  validator: (value) {
                    if (value == null) {
                      return "Required field";
                    } else {
                      return null;
                    }
                  },
                  dropDownItemCount: 6,
                  dropDownList: dropDownList.toList(),
                  onChanged: (val) {
                    Navigator.pushNamed(context, "item/show",
                        arguments: <String, int>{'id': int.parse(val.value)});
                  },
                ))
              ],
            ),
            SingleChildScrollView(
              child: ScrollableDataCell(DataTable(
                columns: const [
                  DataColumn(label: Text('名称')),
                  DataColumn(label: Text('进度')),
                  DataColumn(label: Text('作者')),
                  DataColumn(label: Text('Tag')),
                  DataColumn(label: Text('评分')),
                ],
                rows: _entityItemList
                    .map((item) => DataRow(cells: [
                          DataCell(DataCellItem(item.entityItem)),
                          DataCell(DataCellProgress(item.entityItem)),
                          DataCell(DataCellAuthor(item.entityAuthorList)),
                          DataCell(DataCellTag(item.entityTagList)),
                          DataCell(Text(item.entityItem.rank.toString())),
                        ]))
                    .toList(),
              )),
            )
          ]),
        ),
      ),
    );
  }
}
