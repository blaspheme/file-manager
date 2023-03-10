import 'package:drift/drift.dart' as drift;
import 'package:file_manager/types/author_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import 'toolkit/file_upload.dart';
import 'toolkit/image_widget.dart';

class AuthorEdit extends StatefulWidget {
  const AuthorEdit({super.key});

  @override
  State createState() => _AuthorForm();
}

class _AuthorForm extends State<AuthorEdit> {
  final TextEditingController name = TextEditingController();
  final TextEditingController nationality = TextEditingController();
  final TextEditingController birthDate = TextEditingController();
  final TextEditingController deathDate = TextEditingController();
  final TextEditingController description = TextEditingController();

  /// entityAuthor表的ID，已经存在的
  int entityAuthorId = 0;
  String imageURL = ""; // 图像路径

  setImageURL(String newImageURL, [String? ext]) {
    imageURL = newImageURL;
  }

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
    AuthorsVO authorsVO = AuthorsVO.getItemVO(queryId);

    setState(() {
      entityAuthorId = queryId;
      name.text = authorsVO.entityAuthor.name;
      imageURL = authorsVO.entityAuthor.imageUrl!;
      nationality.text = authorsVO.entityAuthor.nationality!;
      birthDate.text = authorsVO.entityAuthor.birthDate!;
      deathDate.text = authorsVO.entityAuthor.deathDate!;
      description.text = authorsVO.entityAuthor.description!;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> save() async {
      int? tmpEntityAuthorId; // 临时Id，随过程而变化
      if (entityAuthorId > 0) {
        tmpEntityAuthorId = entityAuthorId;
      }

      EntityAuthor entityAuthor = EntityAuthor(
          id: tmpEntityAuthorId,
          name: name.text,
          imageUrl: imageURL,
          nationality: nationality.text,
          birthDate: birthDate.text,
          deathDate: deathDate.text,
          description: description.text);

      await Provider.of<MyDatabase>(context, listen: false)
          .entityAuthors
          .insertOnConflictUpdate(entityAuthor);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Author Edit"),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: '名字',
            ),
          ),
          Row(
            children: [
              OpenFilePage(setImageURL, "author", "上传头像", ""),
              LocalFile(imageURL),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nationality,
                  decoration: const InputDecoration(
                    labelText: '国籍',
                  ),
                ),
              ),
              const SizedBox(width: 10), // 间距
              Expanded(
                child: TextField(
                  controller: birthDate,
                  decoration: const InputDecoration(
                    labelText: '出生日',
                  ),
                ),
              ),
              const SizedBox(width: 10), // 间距
              Expanded(
                child: TextField(
                  controller: deathDate,
                  decoration: const InputDecoration(
                    labelText: '死亡日',
                  ),
                ),
              )
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
