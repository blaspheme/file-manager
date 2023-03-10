import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/author_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import 'select_file.dart';

class ItemFileEdit extends StatefulWidget {
  const ItemFileEdit({super.key});

  @override
  State createState() => _ItemFileForm();
}

class _ItemFileForm extends State<ItemFileEdit> {
  final TextEditingController order = TextEditingController();
  final TextEditingController description = TextEditingController();
  late RelationItemFile oldRelationItemFile;

  String fileId = ""; // 文件的UUID
  setFileId(String newFileId) => fileId = newFileId;

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    getDataFromCache(args["file"]);
    super.didChangeDependencies();
  }

  /// 从缓存获取数据
  getDataFromCache(RelationItemFile relationItemFile) async {
    setState(() {
      oldRelationItemFile = relationItemFile;
      fileId = relationItemFile.fileId;
      order.text = relationItemFile.fileOrder.toString();
      description.text = relationItemFile.description!;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> save() async {
      if (fileId.isEmpty) {
        return;
      }

      RelationItemFile relationItemFile = RelationItemFile(
          itemId: oldRelationItemFile.itemId,
          fileId: fileId,
          fileOrder: int.parse(order.text),
          description: description.text);

      await Provider.of<MyDatabase>(context, listen: false)
          .relationItemFiles
          .insertOne(relationItemFile, mode: drift.InsertMode.replace);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item下文件编辑"),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FileSelect(fileId, setFileId),
          TextField(
            controller: order,
            decoration: const InputDecoration(
              labelText: '顺序',
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
