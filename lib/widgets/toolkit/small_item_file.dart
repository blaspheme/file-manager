import 'package:drift/drift.dart';
import 'package:file_manager/types/file_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/database.dart';
import '../../utils/file.dart';
import 'package:url_launcher/url_launcher.dart';

class SmallItemListView extends StatelessWidget {
  final List<RelationItemFile> relationItemFileList;

  const SmallItemListView(this.relationItemFileList, {super.key});

  @override
  Widget build(BuildContext context) {
    void edit(RelationItemFile relationItemFile) {
      Navigator.pushNamed(context, "item/file/edit",
          arguments: <String, RelationItemFile>{'file': relationItemFile});
    }

    void open(RelationItemFile relationItemFile) async {
      String uuid = relationItemFile.fileId;
      String ext = FilesVO.getItemVO(uuid).entityFile.fileType!;

      String absolutePath = await getAbsolutePath("file\\$uuid.$ext");
      launchUrl(Uri.file(absolutePath));
    }

    void download(RelationItemFile relationItemFile) {}

    void doDelete(RelationItemFile relationItemFile) async {
      await Provider.of<MyDatabase>(context, listen: false)
          .relationItemFiles
          .deleteWhere((tbl) =>
              tbl.itemId.equals(relationItemFile.itemId) &
              tbl.fileId.equals(relationItemFile.fileId));
    }

    void delete(RelationItemFile relationItemFile) async {
      showDialog(
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('确认删除'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    doDelete(relationItemFile);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
          context: context);
    }

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('文件')),
          DataColumn(label: Text('Order')),
          DataColumn(label: Text('描述')),
          DataColumn(label: Text('操作')),
        ],
        rows: relationItemFileList
            .map((item) => DataRow(cells: [
                  DataCell(_FileDisplay(item.fileId)),
                  DataCell(Text(item.fileOrder.toString())),
                  DataCell(
                    Tooltip(
                      message: item.description,
                      child: const Icon(Icons.info_outline_rounded),
                    ),
                  ),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          edit(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          open(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          download(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          delete(item);
                        },
                      ),
                    ],
                  )),
                ]))
            .toList(),
      ),
    );
  }
}

class _FileDisplay extends StatelessWidget {
  late final String fielId;
  late final String name;

  _FileDisplay(_fielId) {
    fielId = _fielId;
    name = FilesVO.getItemVO(_fielId).entityFile.fileName!;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Color.fromARGB(255, 195, 133, 201),
        ),
        onPressed: () {
          {
            Navigator.pushNamed(context, "file/show",
                arguments: <String, String>{'id': fielId});
          }
        },
        child: Text(name));
  }
}
