import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/tag_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';

class TagEdit extends StatefulWidget {
  const TagEdit({super.key});

  @override
  State createState() => _TagForm();
}

class _TagForm extends State<TagEdit> {
  final TextEditingController tag = TextEditingController();
  final TextEditingController description = TextEditingController();

  /// entityTag表的ID，已经存在的
  int entityTagId = 0;

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    if (args["id"] > 0) {
      getDataFromCache(args["id"]);
    }

    super.didChangeDependencies();
  }

  /// 从缓存获取数据
  getDataFromCache(int queryId) async {
    TagsVO tagsVO = TagsVO.getItemVO(queryId);

    setState(() {
      entityTagId = queryId;
      tag.text = tagsVO.entityTag.tag;
      description.text = tagsVO.entityTag.description!;
    });
  }

  @override
  Widget build(BuildContext context) {
    void save() async {
      int? tmpEntityTagId; // 临时Id，随过程而变化
      if (entityTagId > 0) {
        tmpEntityTagId = entityTagId;
      }

      EntityTag entityTag = EntityTag(
          id: tmpEntityTagId, tag: tag.text, description: description.text);

      await Provider.of<MyDatabase>(context, listen: false)
          .entityTags
          .insertOnConflictUpdate(entityTag);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tag Edit"),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: tag,
            decoration: const InputDecoration(
              labelText: 'Tag',
            ),
          ),
          TextField(
            controller: description,
            maxLines: 5, // 设置为 5 行
            decoration: const InputDecoration(
              labelText: '描述',
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: save,
              ),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () => {Navigator.pop(context)},
              ),
            ],
          )
        ],
      )),
    );
  }
}
