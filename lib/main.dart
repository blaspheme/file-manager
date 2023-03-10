import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database.dart';
import 'widgets/author_show.dart';
import 'widgets/file_edit.dart';
import 'widgets/file_show.dart';
import 'widgets/item_edit.dart';
import 'widgets/item_file_edit.dart';
import 'widgets/item_list.dart';
import 'widgets/item_show.dart';
import 'widgets/tag_edit.dart';
import 'widgets/author_edit.dart';
import 'widgets/tag_show.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<MyDatabase>(
        create: (context) => MyDatabase(),
        dispose: (context, db) => db.close(),
      ),
    ],
    child: _APP(),
  ));
}

class _APP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "item/list": (context) => const ItemList(),
        "item/show": (context) => const ItemShow(),
        "item/edit": (context) => const ItemEdit(),
        "item/file/edit": (context) => const ItemFileEdit(),
        "author/edit": (context) => const AuthorEdit(),
        "author/show": (context) => const AuthorShow(),
        "tag/edit": (context) => const TagEdit(),
        "tag/show": (context) => const TagShow(),
        "file/show": (context) => const FileShow(),
        "file/edit": (context) => const FileEdit(),
      },
      initialRoute: "item/list", //初始化路由
    );
  }
}
