// import 'package:file_manager/types/FileItemList.dart';
import 'package:drift/drift.dart';
import 'package:file_manager/types/item_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';

class ItemList extends StatelessWidget {
  ItemList({super.key});
  final List<FileItemList> items = List<FileItemList>.generate(
    100,
    (i) => MessageItemList('Sender $i', 'Message body $i', 'dd'),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const title = 'Item List';
    var a = Provider.of<MyDatabase>(context).entityItems.select().get();
    print(a);

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, "item/edit",
                arguments: <String, String>{'type': 'add'});
          },
        ),
      ),
      body: ListView.builder(
        // Let the ListView know how many items it needs to build.
        itemCount: items.length,
        // Provide a builder function. This is where the magic happens.
        // Convert each item into a widget based on the type of item it is.
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            title: item.buildTitle(context),
            subtitle: item.buildSubtitle(context),
          );
        },
      ),
    );
  }
}
