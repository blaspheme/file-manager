import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/author_vo.dart';
import 'package:file_manager/types/item_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import 'toolkit/display_field.dart';
import 'toolkit/image_widget.dart';
import 'toolkit/small_items_list.dart';

class AuthorShow extends StatefulWidget {
  const AuthorShow({super.key});

  @override
  State createState() => _AuthorShowState();
}

class _AuthorShowState extends State<AuthorShow> {
  late List<ItemsVO> _entityItemList = <ItemsVO>[];

  /// entityAuthors表的ID，已经存在的
  int entityAuthorId = 0;
  late AuthorsVO authorsVO;

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    if (args["id"] > 0) {
      getDataFromCache(args["id"]);
      getDataFromDb(args["id"], context);
    }
    super.didChangeDependencies();
  }

  void getDataFromCache(int queryId) async {
    setState(() {
      entityAuthorId = queryId; // 缓存ID
      authorsVO = AuthorsVO.getItemVO(queryId);
    });
  }

  void getDataFromDb(int queryId, BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    var result = await (thisDB.relationItemAuthors.select()
          ..where((tbl) => tbl.authorId.equals(queryId)))
        .get();

    List<int> tmpItemId = result.map((e) => e.itemId).toList();
    Iterable<ItemsVO> tmpItemsVoList = ItemsVO.getItemVOListByIds(tmpItemId);
    setState(() {
      _entityItemList = tmpItemsVoList.toList();
    });
  }

  void doRefresh(BuildContext context) async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await AuthorsVO.init(thisDB);
    getDataFromCache(entityAuthorId);
    getDataFromDb(entityAuthorId, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(authorsVO.entityAuthor.name),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, "author/edit",
                    arguments: <String, int>{'id': entityAuthorId});
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
              LocalFile(authorsVO.entityAuthor.imageUrl!),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DisplayField('国籍: ', authorsVO.entityAuthor.nationality!),
                  DisplayField('生日: ', authorsVO.entityAuthor.birthDate!),
                  DisplayField('死亡日: ', authorsVO.entityAuthor.deathDate!),
                ],
              )
            ],
          ),
          const Text("描述"),
          Text(authorsVO.entityAuthor.description!),
          SmallItemListView(_entityItemList),
        ]),
      ),
    );
  }
}
