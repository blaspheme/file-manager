import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database.dart';
import 'widgets/item_edit.dart';
import 'widgets/item_list.dart';

void main() {
  runApp(
    Provider<MyDatabase>(
      create: (context) => MyDatabase(),
      child: _APP(),
      dispose: (context, db) => db.close(),
    ),
  );

  // runApp(_APP());
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
        "item/list": (context) => ItemList(),
        "item/edit": (context) => ItemEdit(),
      },
      initialRoute: "item/list", //初始化路由
    );
  }
}
