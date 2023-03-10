import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/file_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import 'toolkit/file_upload.dart';

class FileEdit extends StatefulWidget {
  const FileEdit({super.key});

  @override
  State createState() => _FileForm();
}

class _FileForm extends State<FileEdit> {
  final TextEditingController fileName = TextEditingController();
  final TextEditingController description = TextEditingController();

  /// entityFile表的ID，已经存在的
  String entityFileId = "";
  String fileURL = ""; // 图像路径
  String fileExt = "";

  setImageURL(String newImageURL, [String? ext]) {
    fileURL = newImageURL;
    fileExt = ext!;
  }

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
    if ((args["id"] as String).isNotEmpty) {
      getDataFromCache(args["id"]);
    }
    super.didChangeDependencies();
  }

  /// 从缓存获取数据
  getDataFromCache(String queryId) async {
    FilesVO filesVO = FilesVO.getItemVO(queryId);

    setState(() {
      entityFileId = queryId;
      fileName.text = filesVO.entityFile.fileName!;
      fileExt = filesVO.entityFile.fileType!;
      description.text = filesVO.entityFile.description!;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> save() async {
      String? tmpEntityFileId; // 临时Id，随过程而变化
      if (entityFileId.isNotEmpty) {
        tmpEntityFileId = entityFileId;
      }

      EntityFile entityFile = EntityFile(
          id: tmpEntityFileId,
          fileName: fileName.text,
          fileType: fileExt,
          description: description.text);

      await Provider.of<MyDatabase>(context, listen: false)
          .entityFiles
          .insertOnConflictUpdate(entityFile);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("File Edit"),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: fileName,
            decoration: const InputDecoration(
              labelText: '名字',
            ),
          ),
          Row(
            children: [
              OpenFilePage(setImageURL, "file", "上传文件", entityFileId),
              Text(entityFileId),
            ],
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
