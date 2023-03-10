import 'package:drift/drift.dart' as drift;

import 'package:file_manager/types/tag_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../types/item_vo.dart';
import 'toolkit/small_items_list.dart';

class TagShow extends StatefulWidget {
  const TagShow({super.key});

  @override
  State createState() => _TagShowState();
}

class _TagShowState extends State<TagShow> {
  late List<ItemsVO> _entityItemList = <ItemsVO>[];

  /// entityTags表的ID，已经存在的
  int entityTagId = 0;
  late TagsVO tagsVO;

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    if (args["id"] > 0) {
      getDataFromCache(args["id"]);
      getDataFromDb(args["id"], context);
    }
    super.didChangeDependencies();
  }

  void getDataFromCache(int queryId) {
    setState(() {
      entityTagId = queryId; // 缓存ID
      tagsVO = TagsVO.getItemVO(queryId);
    });
  }

  void getDataFromDb(int queryId, BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    var result = await (thisDB.relationItemTags.select()
          ..where((tbl) => tbl.tagId.equals(queryId)))
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
    getDataFromCache(entityTagId);
    getDataFromDb(entityTagId, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(tagsVO.entityTag.tag),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, "tag/edit",
                    arguments: <String, int>{'id': entityTagId});
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
          Text(tagsVO.entityTag.description!),
          SmallItemListView(_entityItemList),
        ]),
      ),
    );
  }
}
