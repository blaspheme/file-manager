import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/item_vo.dart';
import 'package:file_manager/widgets/select_tag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../utils/sql.dart';
import 'select_author.dart';
import 'toolkit/file_upload.dart';
import 'toolkit/image_widget.dart';

class ItemEdit extends StatefulWidget {
  const ItemEdit({super.key});

  @override
  State createState() => _ItemEditState();
}

class _ItemEditState extends State<ItemEdit> {
  final TextEditingController name = TextEditingController();
  final TextEditingController isbn10 = TextEditingController();
  final TextEditingController isbn13 = TextEditingController();
  final TextEditingController publisher = TextEditingController();
  final TextEditingController publishDate = TextEditingController();
  final TextEditingController description = TextEditingController();

  /// entityItems表的ID，已经存在的
  int entityItemId = 0;
  String imageURL = ""; // 图像路径
  int rankValue = 0; //评分
  int progressValue = 0; // 学习进度

  List<int> authorIdList = <int>[]; // 作者ID
  setAuthorIdList(List<int> newAuthorIdList) => authorIdList = newAuthorIdList;

  List<int> tagIdList = <int>[]; // Tag ID
  setTagIdList(List<int> newTagIdList) => tagIdList = newTagIdList;

  setImageURL(String newImageURL, [String? ext]) {
    imageURL = newImageURL;
  }

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    if (args["id"] > 0) {
      getDataFromCache(args["id"]);
      getFileData(args["id"]);
    }

    super.didChangeDependencies();
  }

  /// 从缓存获取数据
  getDataFromCache(int queryId) async {
    ItemsVO itemsVO = ItemsVO.getItemVO(queryId);

    setState(() {
      entityItemId = queryId; // 缓存ID
      name.text = itemsVO.entityItem.name;
      imageURL = itemsVO.entityItem.imageUrl!;
      isbn10.text = itemsVO.entityItem.isbn10!;
      isbn13.text = itemsVO.entityItem.isbn13!;
      publisher.text = itemsVO.entityItem.publisher!;
      publishDate.text = itemsVO.entityItem.publishDate!;
      description.text = itemsVO.entityItem.description!;
      rankValue = itemsVO.entityItem.rank;
      progressValue = itemsVO.entityItem.progress!;
      authorIdList = itemsVO.entityAuthorList.map((e) => e.id!).toList();
      tagIdList = itemsVO.entityTagList.map((e) => e.id!).toList();
    });
  }

  /// 获取相关文件数据
  getFileData(int queryId) {}

  @override
  Widget build(BuildContext context) {
    /// 保存按钮的点击事件
    Future<void> save() async {
      bool newFlag = true; // 新增标志，默认新增
      var thisDB = Provider.of<MyDatabase>(context, listen: false);
      int? tmpEntityItemId; // 临时Id，随过程而变化
      if (entityItemId > 0) {
        tmpEntityItemId = entityItemId;
        newFlag = false;
      }
      // EntityItem表更新和新增
      EntityItem newEntityItem = EntityItem(
        id: tmpEntityItemId,
        name: name.text,
        imageUrl: imageURL,
        isbn10: isbn10.text,
        isbn13: isbn13.text,
        publisher: publisher.text,
        publishDate: publishDate.text,
        progress: progressValue,
        rank: rankValue,
        description: description.text,
        updatedAt: DateTime.now(),
      );

      /// entityItems ，只有插入返回的才是新增ID，更新是错乱的
      tmpEntityItemId =
          await thisDB.entityItems.insertOnConflictUpdate(newEntityItem);

      List<int> oldAuthorList = []; // 旧的作者ID
      List<int> oldTagList = [];
      if (newFlag == false) {
        // 非新增，缓存内有数据，读取缓存数据
        ItemsVO itemsVO = ItemsVO.getItemVO(entityItemId);
        oldAuthorList = itemsVO.entityAuthorList.map((e) => e.id!).toList();
        oldTagList = itemsVO.entityTagList.map((e) => e.id!).toList();
        tmpEntityItemId = entityItemId; // update的情况下修正ItemId
      }

      await syncRelationItemAuthors(
          thisDB, tmpEntityItemId, authorIdList, oldAuthorList);
      await syncRelationItemTags(
          thisDB, tmpEntityItemId, tagIdList, oldTagList);

      Navigator.pop(context);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Item Edit"),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: '名称',
              ),
            ),
            AuthorSelect(authorIdList, setAuthorIdList), // 作者列表
            Row(
              children: [
                OpenFilePage(setImageURL, "book", "上传封面", ""),
                LocalFile(imageURL),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: isbn10,
                    decoration: const InputDecoration(
                      labelText: 'isbn10',
                    ),
                  ),
                ),
                const SizedBox(width: 10), // 间距
                Expanded(
                  child: TextField(
                    controller: isbn13,
                    decoration: const InputDecoration(
                      labelText: 'isbn13',
                    ),
                  ),
                ),
                const SizedBox(width: 10), // 间距
                Expanded(
                  child: TextField(
                    controller: publisher,
                    decoration: const InputDecoration(
                      labelText: '出版社',
                    ),
                  ),
                ),
                const SizedBox(width: 10), // 间距
                Expanded(
                  child: TextField(
                    controller: publishDate,
                    decoration: const InputDecoration(
                      labelText: '出版日期',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // 间距
            const Text("评分"),
            Slider(
              label: "Rank",
              min: 0,
              max: 10,
              value: rankValue.toDouble(),
              onChanged: (double value) {
                setState(() {
                  rankValue = value.round();
                });
              },
            ),
            const Text("学习进度"),
            Slider(
              label: "学习进度",
              min: 0,
              max: 100,
              value: progressValue.toDouble(),
              onChanged: (double value) {
                setState(() {
                  progressValue = value.round();
                });
              },
            ),
            TextField(
              controller: description,
              maxLines: 5, // 设置为 5 行
              decoration: const InputDecoration(
                labelText: '描述',
              ),
            ),
            TagSelect(tagIdList, setTagIdList), // Tag 列表
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: save,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => {Navigator.pop(context)},
                )
              ],
            )
          ],
        )));
  }
}
