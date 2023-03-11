import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../types/file_vo.dart';

class FileSelect extends StatefulWidget {
  String fileId; // 传参
  Function setFileId;

  FileSelect(this.fileId, this.setFileId, {super.key});

  @override
  State createState() => _FileSelectState();
}

class _FileSelectState extends State<FileSelect> {
  SingleValueDropDownController singleValueDropDownController =
      SingleValueDropDownController();
  final List<EntityFile> _filesList = <EntityFile>[];

  @override
  void initState() {
    super.initState();
    getData();
  }

  ///初始化数据
  void getData() {
    var resultList = FilesVO.getEntityFileList();
    setState(() {
      _filesList.clear();

      // 重新构建下拉框数据
      for (var result in resultList) {
        if (result.id != widget.fileId) {
          _filesList.add(result);
        } else {
          singleValueDropDownController.setDropDown(
              DropDownValueModel(name: result.fileName!, value: result.id));
        }
      }
    });
  }

  /// 刷新数据
  void doRefresh() async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await FilesVO.deleteEmptyRecord(thisDB);
    await FilesVO.init(thisDB);
    getData();
  }

  Iterable<DropDownValueModel> get dropDownList {
    return _filesList.map((EntityFile file) {
      return DropDownValueModel(name: file.fileName!, value: file.id);
    });
  }

  /// 先在数据库创建数据，获取UUID之后再跳转编辑详情
  addNewFile() async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await thisDB.entityFiles.insertOne((EntityFile(createdAt: DateTime.now())));

    /// 获取最新插入的数据
    EntityFile lastRecord = await (thisDB.entityFiles.select()
          ..orderBy([
            (t) => drift.OrderingTerm(
                expression: t.createdAt, mode: drift.OrderingMode.desc)
          ])
          ..limit(1))
        .getSingle();
    await FilesVO.init(thisDB); // 刷新缓存
    Navigator.pushNamed(context, "file/edit",
        arguments: <String, String>{'id': lastRecord.id!});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropDownTextField(
                controller: singleValueDropDownController,
                textFieldDecoration:
                    const InputDecoration(hintText: "Files..."),
                clearOption: true,
                enableSearch: true,
                dropdownColor: Colors.amber[50],
                searchDecoration:
                    const InputDecoration(hintText: "查询 Files..."),
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
                  widget.setFileId(val.value);
                },
              ),
            ),
            TextButton(onPressed: addNewFile, child: const Text('新增文件')),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                doRefresh();
              },
            ),
          ],
        ),
        widget.fileId.isEmpty ? const Text("没有选择文件") : const Text("选择了文件"),
      ],
    );
  }
}
