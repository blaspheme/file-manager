import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/file_vo.dart';
import 'package:file_manager/types/item_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import 'toolkit/data_cell_author.dart';
import 'toolkit/data_cell_progress.dart';
import 'toolkit/data_cell_tag.dart';
import 'toolkit/display_field.dart';
import 'toolkit/image_widget.dart';
import 'toolkit/small_item_file.dart';

class ItemShow extends StatefulWidget {
  const ItemShow({super.key});

  @override
  State createState() => _ItemShowState();
}

class _ItemShowState extends State<ItemShow> {
  /// entityItems表的ID，已经存在的
  int entityItemId = 0;
  late ItemsVO itemsVO;
  List<RelationItemFile> relationItemFileList = <RelationItemFile>[];

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    if (args["id"] > 0) {
      getDataFromCache(args["id"]);
      getFileData(args["id"], context);
    }
    super.didChangeDependencies();
  }

  getDataFromCache(int queryId) {
    // String tmpImgPath = await getAbsolutePath(_.entityItem.imageUrl!);
    setState(() {
      entityItemId = queryId; // 缓存ID
      itemsVO = ItemsVO.getItemVO(queryId);
    });
  }

  void getFileData(int queryId, BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    var result = await (thisDB.relationItemFiles.select()
          ..where((tbl) => tbl.itemId.equals(queryId))
          ..orderBy([
            (tbl) => drift.OrderingTerm(
                expression: tbl.fileOrder, mode: drift.OrderingMode.asc)
          ]))
        .get();
    setState(() {
      relationItemFileList = result;
    });
  }

  void doRefresh(BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await ItemsVO.init(thisDB);
    await FilesVO.init(thisDB);
    getDataFromCache(entityItemId);
    getFileData(entityItemId, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(itemsVO.entityItem.name),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, "item/edit",
                    arguments: <String, int>{'id': entityItemId});
              },
            ),
          ],
        ),
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          doRefresh(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              LocalFile(itemsVO.entityItem.imageUrl!),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DisplayField('ISBN 10: ', itemsVO.entityItem.isbn10!),
                  DisplayField('ISBN 13: ', itemsVO.entityItem.isbn13!),
                  DisplayField('出版社: ', itemsVO.entityItem.publisher!),
                  DisplayField('出版日期: ', itemsVO.entityItem.publishDate!),
                  DisplayField('评分: ', itemsVO.entityItem.rank.toString()),
                  DisplayField('描述: ', itemsVO.entityItem.description!),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Text("学习进度:"),
              Expanded(
                child: DataCellProgress(itemsVO.entityItem),
              )
            ],
          ),
          const Text("作者:"),
          DataCellAuthor(itemsVO.entityAuthorList),
          const Text("Tags:"),
          DataCellTag(itemsVO.entityTagList),
          const Text("相关文件:"),
          SmallItemListView(relationItemFileList),
          Row(
            children: [
              TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 68, 161, 207),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "item/file/edit",
                        arguments: <String, RelationItemFile>{
                          'file': RelationItemFile(
                              itemId: itemsVO.entityItem.id!,
                              fileId: "",
                              fileOrder: 0,
                              description: "")
                        });
                  },
                  child: const Text("新增文件"))
            ],
          ),
        ]),
      ),
    );
  }
}
