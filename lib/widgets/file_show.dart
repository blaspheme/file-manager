import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/file_vo.dart';

import 'package:file_manager/types/tag_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../types/item_vo.dart';
import 'toolkit/small_items_list.dart';

class FileShow extends StatefulWidget {
  const FileShow({super.key});

  @override
  State createState() => _FileShowState();
}

class _FileShowState extends State<FileShow> {
  late List<ItemsVO> _entityItemList = <ItemsVO>[];

  /// entityFiles表的ID，已经存在的
  String entityFileId = "";
  late FilesVO filesVO;

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    if ((args["id"] as String).isNotEmpty) {
      getDataFromCache(args["id"]);
      getDataFromDb(args["id"], context);
    }
    super.didChangeDependencies();
  }

  void getDataFromCache(String queryId) {
    setState(() {
      entityFileId = queryId; // 缓存ID
      filesVO = FilesVO.getItemVO(queryId);
    });
  }

  void getDataFromDb(String queryId, BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    var result = await (thisDB.relationItemFiles.select()
          ..where((tbl) => tbl.fileId.equals(queryId)))
        .get();

    List<int> tmpItemId = result.map((e) => e.itemId).toList();
    Iterable<ItemsVO> tmpItemsVoList = ItemsVO.getItemVOListByIds(tmpItemId);
    setState(() {
      _entityItemList = tmpItemsVoList.toList();
    });
  }

  void doRefresh(BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await TagsVO.init(thisDB);
    getDataFromCache(entityFileId);
    getDataFromDb(entityFileId, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(filesVO.entityFile.fileName!),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, "file/edit",
                    arguments: <String, String>{'id': entityFileId});
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
          const Text("描述:"),
          Text(filesVO.entityFile.description!),
          SmallItemListView(_entityItemList),
        ]),
      ),
    );
  }
}
